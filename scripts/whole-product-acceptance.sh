#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# Explicit clean candidate inputs only; never fall back to an owner's workspace.
: "${APP_SOURCE:?Set APP_SOURCE to the candidate worktree}"
: "${SERVER_SOURCE:?Set SERVER_SOURCE to the candidate worktree}"
: "${WEBSITE_SOURCE:?Set WEBSITE_SOURCE to the candidate worktree}"
: "${CANDIDATE_ARTIFACTS:?Set CANDIDATE_ARTIFACTS to packaged images}"
: "${EVIDENCE_ROOT:?Set EVIDENCE_ROOT}"
for source_dir in "$APP_SOURCE" "$SERVER_SOURCE" "$WEBSITE_SOURCE"; do
  [[ -z "$(git -C "$source_dir" status --porcelain)" ]] || { echo 'Candidate source must be clean.' >&2; exit 1; }
done
for cmd in docker jq openssl curl python3 sha256sum; do command -v "$cmd" >/dev/null; done
mkdir -p "$EVIDENCE_ROOT"
EVIDENCE_ROOT="$(cd "$EVIDENCE_ROOT" && pwd -P)"
private_dir="$(mktemp -d)"
trap 'rm -rf "$private_dir"' EXIT
project="cashlenx-rc-$(date +%s)-$$-$RANDOM"
export MONGO_IMAGE MYSQL_IMAGE GO_TEST_IMAGE NGINX_IMAGE
source "$SERVER_SOURCE/docker/dependencies/images.env"
source "$SERVER_SOURCE/docker/images.env"
source "$WEBSITE_SOURCE/docker/images.env"
# Resolve image IDs from packages, check source identities and archive hashes.
for component in app server website; do
  metadata="$(find "$CANDIDATE_ARTIFACTS" -maxdepth 1 -name "cashlenx-$component-*.image.tar.json" -print -quit)"
  [[ -n "$metadata" ]] || { echo "Missing $component package." >&2; exit 1; }
  source_key="${component^^}_SOURCE"
  [[ "$(jq -r .revision "$metadata")" == "$(git -C "${!source_key}" rev-parse HEAD)" ]] || exit 1
  artifact="$(jq -r .artifact "$metadata")"
  [[ "$artifact" == "$(basename "$artifact")" ]] || exit 1
  [[ "$(sha256sum "$CANDIDATE_ARTIFACTS/$artifact" | awk '{print $1}')" == "$(jq -r .artifact_sha256 "$metadata")" ]] || exit 1
  image_id="$(jq -r .image_id "$metadata")"
  [[ "$image_id" =~ ^sha256:[0-9a-f]{64}$ ]] || exit 1
  [[ "$(docker image inspect --format '{{.Id}}' "$image_id")" == "$image_id" ]] || exit 1
  printf -v "${component^^}_IMAGE" '%s' "$image_id"
  export "${component^^}_IMAGE"
done
export APP_SOURCE SERVER_SOURCE WEBSITE_SOURCE
export DATABASE_ENV="$private_dir/database.env" SERVER_ENV="$private_dir/server.env"
export BROWSER_ENV="$private_dir/browser.env" INTEGRATION_ENV="$private_dir/integration.env"
export TLS_DIR="$private_dir/tls" BROWSER_IMAGE="$project-browser"
export BROWSER_EVIDENCE="$EVIDENCE_ROOT/browser"
mkdir -p "$TLS_DIR" "$BROWSER_EVIDENCE"
touch "$DATABASE_ENV" "$SERVER_ENV" "$BROWSER_ENV" "$INTEGRATION_ENV" "$private_dir/compose.env"
rc() { docker compose --env-file "$private_dir/compose.env" -p "$project" -f "$spec_dir/docker/rehearsal.compose.yml" "$@"; }
cleaned=false
cleanup() {
  rc --profile '*' down --volumes --remove-orphans >/dev/null 2>&1 || return 1
  [[ -z "$(docker ps -aq --filter "label=com.docker.compose.project=$project")" ]] || return 1
  [[ -z "$(docker volume ls -q --filter "label=com.docker.compose.project=$project")" ]] || return 1
  [[ -z "$(docker network ls -q --filter "label=com.docker.compose.project=$project")" ]] || return 1
  cleaned=true
}
finish() {
  result=$?
  if ((result != 0)); then echo "Failed rehearsal stage: ${stage:-preflight}" >&2; fi
  cleanup || result=1
  [[ -z "${BROWSER_EVIDENCE:-}" ]] || rm -rf "$BROWSER_EVIDENCE"
  rm -rf "$private_dir"
  if ((result != 0)); then echo 'Isolated rehearsal failed; raw runtime output and disposable secrets were removed.' >&2; fi
  exit "$result"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
wait_for() {
  local tries="$1"; shift
  for ((try=0; try<tries; try++)); do
    if "$@" >"$private_dir/probe.log" 2>&1; then return 0; fi
    sleep 2
  done
  echo 'Disposable service readiness timed out.' >&2; return 1
}
mongo() { rc exec -T "$db_service" sh -ec 'test "$(cat /proc/1/comm)" = mongod; exec mongosh --quiet --username root --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --eval "$1" cashlenx' sh "$1"; }
mysql_query() { rc exec -T "$db_service" sh -ec 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --host=127.0.0.1 -uroot --batch --skip-column-names cashlenx -e "$1"' sh "$1"; }
ledger() {
  if [[ "$profile" == mongodb ]]; then mongo 'printjson(db.schema_migrations.find({}, {_id:1,name:1,checksum:1,dirty:1}).sort({_id:1}).toArray())';
  else mysql_query 'SELECT version, dirty FROM schema_migrations ORDER BY version'; fi
}
health() { curl --fail --silent --max-time 5 "$api_url/open/health" >/dev/null; }
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$TLS_DIR/key.pem" -out "$TLS_DIR/cert.pem" -days 1 -subj /CN=localhost >/dev/null 2>&1
cat > "$TLS_DIR/default.conf" <<'NGINX'
server {
  listen 8443 ssl;
  ssl_certificate /etc/nginx/conf.d/cert.pem;
  ssl_certificate_key /etc/nginx/conf.d/key.pem;
  location /api/ { proxy_pass http://127.0.0.1:10063; }
  location / { proxy_pass http://127.0.0.1:8080; }
}
NGINX
for profile in mongodb mysql; do
  echo "Running isolated $profile rehearsal."
  stage="$profile: database startup"
  password="$(openssl rand -hex 24)"
  export ADMIN_USERNAME=gate_admin ADMIN_PASSWORD="Gate_$(openssl rand -hex 24)"
  cat > "$DATABASE_ENV" <<ENV
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD=$password
MONGO_INITDB_DATABASE=cashlenx
MYSQL_ROOT_PASSWORD=$password
MYSQL_ROOT_HOST=%
MYSQL_DATABASE=cashlenx
ENV
  cat > "$SERVER_ENV" <<ENV
ENV=test
SERVER_HOST=0.0.0.0
API_VERSION=v1
SCHEMA_VALIDATION=true
DB_TYPE=$profile
DB_NAME=cashlenx
MONGO_DB_URI=mongodb://root:$password@mongodb:27017/cashlenx?authSource=admin&retryWrites=false
MYSQL_DB_URI=root:$password@tcp(mysql:3306)
JWT_SECRET=$(openssl rand -hex 32)
ADMIN_USERNAME=$ADMIN_USERNAME
ADMIN_PASSWORD=$ADMIN_PASSWORD
CORS_ORIGINS=http://127.0.0.1:8080
SMTP_ENABLED=false
METRICS_ENABLED=false
RATE_LIMIT_ENABLED=false
ENV
  cat > "$INTEGRATION_ENV" <<ENV
MONGO_TEST_URI=mongodb://root:$password@mongodb:27017/?authSource=admin&retryWrites=false
MYSQL_TEST_DSN=root:$password@tcp(mysql:3306)/migration_integration?parseTime=true&multiStatements=true
ENV
  cat > "$BROWSER_ENV" <<ENV
APP_URL=http://127.0.0.1:8080
API_URL=http://127.0.0.1:10063/api/v1
ADMIN_USERNAME=$ADMIN_USERNAME
ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV
  db_service="$profile"
  rc --profile "$profile" up -d "$profile" web website >"$private_dir/start.log" 2>&1
  if [[ "$profile" == mongodb ]]; then wait_for 90 mongo 'quit(db.runCommand({ping:1}).ok ? 0 : 1)';
  else wait_for 120 mysql_query 'SELECT 1'; mysql_query 'CREATE DATABASE migration_integration' >/dev/null; fi
  stage="$profile: migration integration"
  # Tagged tests cover fresh, existing/upgrade, repeat, checksum/history and dirty-state recovery.
  if [[ "$profile" == mongodb ]]; then test_pattern='TestMongo.*Integration'; else test_pattern=TestMySQLMigrationRunnerIntegration; fi
  rc run --rm integration go test -mod=readonly -tags=integration -run "$test_pattern" -v ./migrations >"$private_dir/integration.log" 2>&1
  grep -q '^--- PASS:' "$private_dir/integration.log"
  ! grep -q '^--- SKIP:' "$private_dir/integration.log"
  grep -E '^(=== RUN|--- PASS:|PASS|ok[[:space:]])' "$private_dir/integration.log" > "$EVIDENCE_ROOT/$profile-migrations.txt"
  echo "$profile migration integration passed."
  stage="$profile: image startup and ingress"
  rc up -d api ingress >"$private_dir/api.log" 2>&1
  api_url="http://$(rc port web 10063)/api/v1"
  wait_for 90 health
  curl --fail --silent --insecure "https://$(rc port web 8443)/api/v1/open/health" >/dev/null
  curl --fail --silent "http://$(rc port web 8080)" | grep -q '<html'
  curl --fail --silent "http://$(rc port website 8080)" | grep -q '<html'
  ledger > "$EVIDENCE_ROOT/$profile-ledger-before.txt"
  stage="$profile: API smoke"
  BASE_URL="$api_url" SMOKE_USERNAME="gate_${RANDOM}" SMOKE_PASSWORD="Smoke_$(openssl rand -hex 20)" SMOKE_NEW_PASSWORD="Smoke_$(openssl rand -hex 20)" bash "$SERVER_SOURCE/test/scripts/api-smoke.sh" >"$private_dir/api-smoke.log" 2>&1
  stage="$profile: budget/profile compatibility"
  BASE_URL="$api_url" bash "$spec_dir/test/scripts/budget-acceptance.sh" >"$private_dir/budget.log" 2>&1 || { cat "$private_dir/budget.log" >&2; exit 1; }
  echo "$profile API and budget/profile/configuration acceptance passed."
  export BROWSER_EVIDENCE="$EVIDENCE_ROOT/$profile-browser"
  mkdir -p "$BROWSER_EVIDENCE"
  stage="$profile: browser journey"
  rc build browser >"$private_dir/browser-build.log" 2>&1
  rc run --rm browser >"$private_dir/browser.log" 2>&1
  # Browser artifacts can contain session tokens. Retain only aggregate counts.
  jq '{stats:{expected:.stats.expected,unexpected:.stats.unexpected,skipped:.stats.skipped},errors:(.errors|length)}' "$BROWSER_EVIDENCE/result.json" > "$EVIDENCE_ROOT/$profile-browser.json"
  jq -e '.stats.unexpected == 0 and .stats.expected > 0 and .stats.skipped == 0 and .errors == 0' "$EVIDENCE_ROOT/$profile-browser.json" >/dev/null
  rm -rf "$BROWSER_EVIDENCE"
  echo "$profile browser acceptance passed."
  stage="$profile: restart and repeat"
  rc restart api >/dev/null 2>&1
  wait_for 90 health
  ledger > "$EVIDENCE_ROOT/$profile-ledger-after.txt"
  cmp "$EVIDENCE_ROOT/$profile-ledger-before.txt" "$EVIDENCE_ROOT/$profile-ledger-after.txt"
  # Rehearse repository-owned encrypted backups on this disposable database only.
  export REHEARSAL_PROJECT="$project" REHEARSAL_PRIVATE="$private_dir"
  export REHEARSAL_SPEC="$spec_dir" REHEARSAL_PROFILE="$profile"
  stage="$profile: data protection"
  bash "$spec_dir/scripts/rehearsal-data-protection.sh" >"$private_dir/protection.log" 2>&1 || { grep '^rehearsal_protection_error_line=' "$private_dir/protection.log" >&2 || true; exit 1; }
  stage="$profile: dependency failure and persistence"
  rc stop "$profile" >/dev/null 2>&1
  if [[ "$profile" == mongodb ]]; then ! mongo 'quit(db.runCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; else ! mysql_query 'SELECT 1' >/dev/null 2>&1; fi
  rc start "$profile" >/dev/null 2>&1
  if [[ "$profile" == mongodb ]]; then wait_for 90 mongo 'quit(db.runCommand({ping:1}).ok ? 0 : 1)'; else wait_for 120 mysql_query 'SELECT 1'; fi
  ledger > "$private_dir/persisted-ledger"
  cmp "$EVIDENCE_ROOT/$profile-ledger-before.txt" "$private_dir/persisted-ledger"
  rc restart api >/dev/null 2>&1
  wait_for 90 health
  rc stop -t 30 api >/dev/null 2>&1
  [[ "$(docker inspect --format '{{.State.ExitCode}}' "$(rc ps -aq api)")" != 137 ]]
  cleanup
  jq -n --arg database "$profile" '{database:$database,result:"passed",migration_integration:"passed",api_smoke:"passed",budget_profile_configuration:"passed",browser:"passed",tls_ingress:"passed",restart_repeat_persistence:"passed",encrypted_backup_restore_corruption_retention:"passed",dependency_failure:"passed",graceful_shutdown:"passed",isolated_teardown:"passed"}' > "$EVIDENCE_ROOT/$profile.json"
  echo "$profile rehearsal passed and isolated resources removed."
done
jq -s '{result:"passed",profiles:.,secrets_recorded:false,deployment_state:"Disposable rehearsal only"}' "$EVIDENCE_ROOT/mongodb.json" "$EVIDENCE_ROOT/mysql.json" > "$EVIDENCE_ROOT/manifest.json"
echo 'Whole-product isolated acceptance passed.'
