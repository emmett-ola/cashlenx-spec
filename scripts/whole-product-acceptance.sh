#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
workspace_dir="$(cd "$spec_dir/.." && pwd -P)"
app_dir="$workspace_dir/cashlenx-app"
server_dir="$workspace_dir/cashlenx-server"
acceptance_env="$app_dir/.env.acceptance.local"
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$(git -C "$app_dir" rev-parse --short=8 HEAD)"
evidence_root="${EVIDENCE_ROOT:-$spec_dir/.artifacts/browser}"
evidence_dir="$evidence_root/$run_id"

# Repository environment files are the sole configuration source for this
# acceptance run. Release packaging and rehearsal processes intentionally use
# the same variable names, so clear inherited overrides before selecting the
# local and acceptance-specific files below.
unset COMPOSE_PROJECT_NAME ENV_FILE
while IFS= read -r key; do
  [[ -n "$key" ]] && unset "$key"
done < <(
  awk -F= '/^[A-Za-z_][A-Za-z0-9_]*=/ { print $1 }' \
    "$app_dir/.env.example" \
    "$server_dir/.env.example" \
    "$workspace_dir/cashlenx-website/.env.example" | sort -u
)

read_key() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '$0 ~ "^" key "=" { sub("^[^=]*=", ""); print; exit }' "$file"
}

set_key() {
  local file="$1"
  local key="$2"
  local value="$3"
  local temp_file
  temp_file="$(mktemp "${file}.tmp.XXXXXX")"
  awk -v key="$key" -v value="$value" '
    BEGIN { replaced = 0 }
    $0 ~ "^" key "=" {
      if (!replaced) {
        print key "=" value
        replaced = 1
      }
      next
    }
    { print }
    END { if (!replaced) print key "=" value }
  ' "$file" > "$temp_file"
  mv "$temp_file" "$file"
}

cleanup() {
  if [[ -f "$acceptance_env" ]]; then
    (cd "$app_dir" && ENV_FILE=.env.acceptance.local bash scripts/stop.sh) || true
    rm -f "$acceptance_env"
  fi
}
trap cleanup EXIT

"$spec_dir/scripts/configure-local-env.sh"
mkdir -p "$evidence_dir"
cp "$app_dir/.env" "$acceptance_env"
set_key "$acceptance_env" APP_PROJECT_NAME cashlenx-app-acceptance
set_key "$acceptance_env" CONTAINER_NAME cashlenx-app-acceptance
set_key "$acceptance_env" IMAGE_TAG acceptance-local
set_key "$acceptance_env" WEB_PORT 10074
set_key "$acceptance_env" API_DOMAIN cashlenx-server
set_key "$acceptance_env" API_PORT 10063
set_key "$acceptance_env" API_VERSION api/v1

(cd "$server_dir" && bash scripts/dependencies/mongodb/status.sh && bash scripts/start.sh && bash scripts/status.sh)
(cd "$app_dir" && ENV_FILE=.env.acceptance.local bash scripts/build.sh)
(cd "$app_dir" && ENV_FILE=.env.acceptance.local bash scripts/start.sh)
(cd "$app_dir" && ENV_FILE=.env.acceptance.local bash scripts/status.sh)

export ADMIN_USERNAME="$(read_key "$server_dir/.env" ADMIN_USERNAME)"
export ADMIN_PASSWORD="$(read_key "$server_dir/.env" ADMIN_PASSWORD)"
export APP_URL=http://127.0.0.1:8080
export API_URL=http://cashlenx-server:10063/api/v1
export APP_CONTAINER_NAME=cashlenx-app-acceptance
export BROWSER_EVIDENCE_DIR="$evidence_dir"

(cd "$app_dir" && bash scripts/browser-acceptance.sh)

result_sha="$(sha256sum "$evidence_dir/result.json" | awk '{ sub(/^\\/, "", $1); print $1 }')"
printf '%s\n' \
  "run_id=$run_id" \
  "app_revision=$(git -C "$app_dir" rev-parse HEAD)" \
  "server_revision=$(git -C "$server_dir" rev-parse HEAD)" \
  "result_sha256=$result_sha" \
  "secrets_recorded=false" > "$evidence_dir/manifest.txt"

echo "Whole-product browser acceptance passed."
echo "evidence_run=$run_id"
echo "result_sha256=$result_sha"
