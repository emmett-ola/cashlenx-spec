#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
fixture_dir="$(mktemp -d)"
state_dir="$fixture_dir/coordinator-state"
runtime_dir="$fixture_dir/runtime-state"
log_file="$fixture_dir/lifecycle.log"
trap 'rm -rf "$fixture_dir"' EXIT

mkdir -p "$state_dir" "$runtime_dir"
for project in cashlenx-app cashlenx-server cashlenx-website; do
  mkdir -p "$fixture_dir/$project/scripts"
done
mkdir -p "$fixture_dir/cashlenx-server/scripts/dependencies/mongodb"
mkdir -p "$fixture_dir/cashlenx-server/scripts/dependencies/mysql"

cat > "$fixture_dir/cashlenx-app/.env.example" <<'EOF'
CONTAINER_FRONTEND=docker
DOCKER_NETWORK_NAME=fixture-network
APP_PROJECT_NAME=fixture-app-project
CONTAINER_NAME=fixture-app
WEB_PORT=10064
API_PORT=10063
EOF
cat > "$fixture_dir/cashlenx-server/.env.example" <<'EOF'
CONTAINER_FRONTEND=docker
DOCKER_NETWORK_NAME=fixture-network
DB_TYPE=mongodb
SERVER_PROJECT_NAME=fixture-server-project
MONGO_PROJECT_NAME=fixture-mongodb-project
MYSQL_PROJECT_NAME=fixture-mysql-project
BACKEND_CONTAINER_NAME=fixture-server
MONGO_CONTAINER_NAME=fixture-mongodb
MYSQL_CONTAINER_NAME=fixture-mysql
SERVER_PORT=10063
MONGO_PORT=10062
MYSQL_PORT=10061
JWT_SECRET=fixture-jwt-secret
ADMIN_PASSWORD=fixture-admin-password
MONGO_ROOT_PASSWORD=fixture-mongo-password
MYSQL_ROOT_PASSWORD=fixture-mysql-root-password
MYSQL_PASSWORD=fixture-mysql-password
EOF
cat > "$fixture_dir/cashlenx-website/.env.example" <<'EOF'
CONTAINER_FRONTEND=docker
DOCKER_NETWORK_NAME=fixture-network
WEBSITE_PROJECT_NAME=fixture-website-project
WEBSITE_CONTAINER_NAME=fixture-website
WEBSITE_PORT=11065
EOF

stub="$fixture_dir/lifecycle-stub.sh"
cat > "$stub" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
action="$(basename "$0" .sh)"
case "$PWD/$0" in
  */dependencies/*) component=database ;;
  */cashlenx-server/*) component=server ;;
  */cashlenx-app/*) component=app ;;
  */cashlenx-website/*) component=website ;;
esac
printf '%s:%s\n' "$component" "$action" >> "$FAKE_LIFECYCLE_LOG"
marker="$FAKE_RUNTIME_STATE/$component"
case "$action" in
  status)
    if [[ -f "$marker" && "${FAKE_UNHEALTHY_COMPONENT:-}" == "$component" ]]; then
      echo 'container_state=running'
      echo 'health=unhealthy'
      exit 1
    elif [[ -f "$marker" ]]; then
      echo 'container_state=running'
      echo 'health=healthy'
    else
      echo 'container_state=missing'
      exit 1
    fi
    ;;
  start)
    [[ "${FAKE_FAIL_COMPONENT:-}" != "$component" ]] || exit 1
    : > "$marker"
    ;;
  stop) rm -f "$marker" ;;
esac
EOF
chmod +x "$stub"

for project in cashlenx-app cashlenx-server cashlenx-website; do
  for action in build start status doctor logs stop; do
    cp "$stub" "$fixture_dir/$project/scripts/$action.sh"
  done
done
for database in mongodb mysql; do
  for action in build start status doctor logs stop; do
    cp "$stub" "$fixture_dir/cashlenx-server/scripts/dependencies/$database/$action.sh"
  done
done

run_lifecycle() {
  FAKE_LIFECYCLE_LOG="$log_file" FAKE_RUNTIME_STATE="$runtime_dir" \
    FAKE_FAIL_COMPONENT="${FAKE_FAIL_COMPONENT:-}" FAKE_UNHEALTHY_COMPONENT="${FAKE_UNHEALTHY_COMPONENT:-}" \
    bash "$spec_dir/scripts/environment-lifecycle.sh" "$@" \
      --workspace-dir "$fixture_dir" --state-dir "$state_dir"
}

for profile in local testing production; do
  bash "$spec_dir/scripts/sync-env.sh" --profile "$profile" --workspace-dir "$fixture_dir" >/dev/null
  run_lifecycle preflight --profile "$profile" --database mongodb >/dev/null
done

: > "$log_file"
run_lifecycle build --profile local --database mongodb >/dev/null
expected_build=$'database:build\nserver:build\napp:build\nwebsite:build'
test "$(cat "$log_file")" = "$expected_build"

: > "$log_file"
run_lifecycle start --profile local --database mongodb >/dev/null
grep -Fx 'database' "$state_dir/local-mongodb.state" >/dev/null
grep -Fx 'server' "$state_dir/local-mongodb.state" >/dev/null
grep -Fx 'app' "$state_dir/local-mongodb.state" >/dev/null
grep -Fx 'website' "$state_dir/local-mongodb.state" >/dev/null
for component in database server app website; do test -f "$runtime_dir/$component"; done

run_lifecycle status --profile local --database mongodb >/dev/null
run_lifecycle doctor --profile local --database mongodb >/dev/null
run_lifecycle logs --profile local --database mongodb >/dev/null

: > "$log_file"
run_lifecycle stop --profile local --database mongodb >/dev/null
expected_stop=$'website:stop\napp:stop\nserver:stop\ndatabase:stop'
test "$(cat "$log_file")" = "$expected_stop"
test ! -e "$state_dir/local-mongodb.state"
for component in database server app website; do test ! -f "$runtime_dir/$component"; done

: > "$runtime_dir/app"
: > "$log_file"
run_lifecycle start --profile local --database mongodb >/dev/null
if grep -Fx 'app' "$state_dir/local-mongodb.state" >/dev/null; then
  echo "Pre-existing App was incorrectly claimed by the coordinator" >&2
  exit 1
fi
run_lifecycle stop --profile local --database mongodb >/dev/null
test -f "$runtime_dir/app"
rm -f "$runtime_dir/app"

: > "$log_file"
if output="$(FAKE_FAIL_COMPONENT=server run_lifecycle start --profile local --database mongodb 2>&1)"; then
  echo "Expected Server start failure" >&2
  exit 1
fi
grep -F 'rolling back resources started by this run' <<< "$output" >/dev/null
test ! -f "$runtime_dir/database"
test ! -e "$state_dir/local-mongodb.state"
grep -Fx 'database:stop' "$log_file" >/dev/null

: > "$log_file"
if output="$(FAKE_UNHEALTHY_COMPONENT=database run_lifecycle start --profile local --database mongodb 2>&1)"; then
  echo "Expected dependency health-gate failure" >&2
  exit 1
fi
grep -F 'health gate failed' <<< "$output" >/dev/null
grep -F 'value-free status/doctor diagnostics' <<< "$output" >/dev/null
test ! -f "$runtime_dir/database"
test ! -e "$state_dir/local-mongodb.state"

: > "$runtime_dir/app"
: > "$log_file"
if output="$(FAKE_UNHEALTHY_COMPONENT=app run_lifecycle start --profile local --database mongodb 2>&1)"; then
  echo "Expected a pre-existing degraded App to be rejected" >&2
  exit 1
fi
grep -F 'existing degraded container' <<< "$output" >/dev/null
test -f "$runtime_dir/app"
test ! -f "$runtime_dir/database"
test ! -f "$runtime_dir/server"
test ! -e "$state_dir/local-mongodb.state"
rm -f "$runtime_dir/app"

server_env="$fixture_dir/cashlenx-server/.env.local"
sed -i 's/^DB_TYPE=mongodb$/DB_TYPE=mysql/' "$server_env"
run_lifecycle preflight --profile local --database mysql >/dev/null
if output="$(run_lifecycle preflight --profile local --database mongodb 2>&1)"; then
  echo "Expected database selection mismatch" >&2
  exit 1
fi
grep -F 'DB_TYPE does not match' <<< "$output" >/dev/null

app_env="$fixture_dir/cashlenx-app/.env.local"
sed -i 's/^DOCKER_NETWORK_NAME=.*$/DOCKER_NETWORK_NAME=other-network/' "$app_env"
if output="$(run_lifecycle preflight --profile local --database mysql 2>&1)"; then
  echo "Expected network mismatch" >&2
  exit 1
fi
grep -F 'DOCKER_NETWORK_NAME differs' <<< "$output" >/dev/null
if grep -F 'other-network' <<< "$output" >/dev/null; then
  echo "Preflight output exposed a configured value" >&2
  exit 1
fi

sed -i 's/^DOCKER_NETWORK_NAME=.*$/DOCKER_NETWORK_NAME=fixture-network/' "$app_env"
sed -i 's/^APP_PROJECT_NAME=.*$/APP_PROJECT_NAME=fixture-server-project/' "$app_env"
if output="$(run_lifecycle preflight --profile local --database mysql 2>&1)"; then
  echo "Expected project identity collision" >&2
  exit 1
fi
grep -F 'duplicate project identity' <<< "$output" >/dev/null

echo "Environment lifecycle coordination smoke checks passed."
