#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT

for project in cashlenx-app cashlenx-server cashlenx-website; do
  mkdir -p "$fixture_dir/$project"
  cat > "$fixture_dir/$project/.env.example" <<'EOF'
PUBLIC_SETTING=public-default
SECRET_SETTING=CHANGE_ME_fixture_secret
EOF
done

run_sync() {
  bash "$spec_dir/scripts/sync-env.sh" --workspace-dir "$fixture_dir" "$@"
}

if output="$(run_sync --profile local --check 2>&1)"; then
  echo "Expected check to reject missing local profiles" >&2
  exit 1
fi
grep -F 'missing .env.local' <<< "$output" >/dev/null
if grep -F 'CHANGE_ME_fixture_secret' <<< "$output" >/dev/null; then
  echo "Check output exposed a configured value" >&2
  exit 1
fi

run_sync --profile local >/dev/null
run_sync --profile local --check >/dev/null
for project in cashlenx-app cashlenx-server cashlenx-website; do
  test -f "$fixture_dir/$project/.env.local"
done

app_env="$fixture_dir/cashlenx-app/.env.local"
sed -i 's/^SECRET_SETTING=.*$/SECRET_SETTING=fixture-preserved-value/' "$app_env"
sed -i '/^PUBLIC_SETTING=/d' "$app_env"
if output="$(run_sync --profile local --check 2>&1)"; then
  echo "Expected check to report a missing key" >&2
  exit 1
fi
grep -F 'missing key in .env.local: PUBLIC_SETTING' <<< "$output" >/dev/null
if grep -F 'fixture-preserved-value' <<< "$output" >/dev/null; then
  echo "Check output exposed a configured value" >&2
  exit 1
fi

run_sync --profile local >/dev/null
grep -Fx 'SECRET_SETTING=fixture-preserved-value' "$app_env" >/dev/null
grep -Fx 'PUBLIC_SETTING=public-default' "$app_env" >/dev/null
before="$(sha256sum "$app_env" | awk '{print $1}')"
run_sync --profile local >/dev/null
after="$(sha256sum "$app_env" | awk '{print $1}')"
test "$before" = "$after"

printf '%s\n' 'PUBLIC_SETTING=duplicate' >> "$app_env"
if output="$(run_sync --profile local --check 2>&1)"; then
  echo "Expected duplicate keys to be rejected" >&2
  exit 1
fi
grep -F 'duplicate key in .env.local: PUBLIC_SETTING' <<< "$output" >/dev/null
sed -i '$d' "$app_env"

outside_env="$fixture_dir/outside.env"
cp "$app_env" "$outside_env"
rm -f "$app_env"
ln -s "$outside_env" "$app_env" 2>/dev/null || true
if [[ -L "$app_env" ]]; then
  if output="$(run_sync --profile local --check 2>&1)"; then
    echo "Expected an outside-repository symlink to be rejected" >&2
    exit 1
  fi
  grep -F '.env.local must resolve inside its repository' <<< "$output" >/dev/null
  rm -f "$app_env"
  cp "$outside_env" "$app_env"
fi

configure_output="$(bash "$spec_dir/scripts/configure-local-env.sh" --workspace-dir "$fixture_dir")"
server_env="$fixture_dir/cashlenx-server/.env.local"
grep -Fx 'API_PORT=10063' "$app_env" >/dev/null
grep -Fx 'WEB_PORT=10064' "$app_env" >/dev/null
grep -Fx 'SERVER_PORT=10063' "$server_env" >/dev/null
for secret_key in MONGO_ROOT_PASSWORD JWT_SECRET ADMIN_PASSWORD MYSQL_ROOT_PASSWORD MYSQL_PASSWORD; do
  secret_value="$(awk -F= -v key="$secret_key" '$1 == key { sub("^[^=]*=", ""); print; exit }' "$server_env")"
  [[ -n "$secret_value" && "$secret_value" != CHANGE_ME* ]]
  if grep -F "$secret_value" <<< "$configure_output" >/dev/null; then
    echo "Local configuration output exposed $secret_key" >&2
    exit 1
  fi
done
server_before="$(sha256sum "$server_env" | awk '{print $1}')"
bash "$spec_dir/scripts/configure-local-env.sh" --workspace-dir "$fixture_dir" >/dev/null
server_after="$(sha256sum "$server_env" | awk '{print $1}')"
test "$server_before" = "$server_after"

for profile in testing production; do
  run_sync --profile "$profile" >/dev/null
  run_sync --profile "$profile" --check >/dev/null
done

if output="$(run_sync --profile staging 2>&1)"; then
  echo "Expected an invalid profile to be rejected" >&2
  exit 1
fi
grep -F 'Invalid profile: staging' <<< "$output" >/dev/null

echo "Environment profile synchronization smoke checks passed."
