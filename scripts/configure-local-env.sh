#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
workspace_dir="$(cd "$spec_dir/.." && pwd -P)"

if [[ "${1:-}" == --workspace-dir ]]; then
  [[ $# -eq 2 ]] || { echo "Usage: scripts/configure-local-env.sh [--workspace-dir PATH]" >&2; exit 2; }
  workspace_dir="$(cd "$2" && pwd -P)"
elif [[ $# -ne 0 ]]; then
  echo "Usage: scripts/configure-local-env.sh [--workspace-dir PATH]" >&2
  exit 2
fi

"$spec_dir/scripts/sync-env.sh" --profile local --workspace-dir "$workspace_dir"

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
    END {
      if (!replaced) print key "=" value
    }
  ' "$file" > "$temp_file"
  mv "$temp_file" "$file"
}

current_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '$0 ~ "^" key "=" { sub("^[^=]*=", ""); print; exit }' "$file"
}

ensure_secret() {
  local file="$1"
  local key="$2"
  local value
  value="$(current_value "$file" "$key")"
  if [[ -z "$value" || "$value" == CHANGE_ME* ]]; then
    set_key "$file" "$key" "$(openssl rand -hex 32)"
  fi
}

app_env="$workspace_dir/cashlenx-app/.env.local"
server_env="$workspace_dir/cashlenx-server/.env.local"
website_env="$workspace_dir/cashlenx-website/.env.local"

set_key "$app_env" APP_ENV dev
set_key "$app_env" API_SCHEME http
set_key "$app_env" API_DOMAIN 127.0.0.1
set_key "$app_env" API_PORT 10063
set_key "$app_env" API_VERSION api/v1
set_key "$app_env" CONTAINER_FRONTEND docker
set_key "$app_env" APP_PROJECT_NAME cashlenx-app
set_key "$app_env" DOCKER_NETWORK_NAME cashlenx-network
set_key "$app_env" WEB_BIND_ADDRESS 127.0.0.1
set_key "$app_env" WEB_PORT 10064

set_key "$server_env" ENV dev
set_key "$server_env" SERVER_PORT 10063
set_key "$server_env" TIMEZONE Asia/Singapore
set_key "$server_env" API_VERSION v1
set_key "$server_env" DB_TYPE mongodb
set_key "$server_env" CORS_ORIGINS 'http://localhost:*,http://127.0.0.1:*,http://cashlenx-app-acceptance:8080'
set_key "$server_env" CONTAINER_FRONTEND docker
set_key "$server_env" SERVER_PROJECT_NAME cashlenx-server
set_key "$server_env" MONGO_PROJECT_NAME cashlenx-mongodb
set_key "$server_env" MYSQL_PROJECT_NAME cashlenx-mysql
set_key "$server_env" MONGO_DATA_VOLUME_NAME cashlenx-mongodb-local-data
set_key "$server_env" MYSQL_DATA_VOLUME_NAME cashlenx-mysql-local-data
set_key "$server_env" DOCKER_NETWORK_NAME cashlenx-network
set_key "$server_env" SERVER_BIND_ADDRESS 127.0.0.1
set_key "$server_env" MONGO_BIND_ADDRESS 127.0.0.1
set_key "$server_env" MYSQL_BIND_ADDRESS 127.0.0.1
ensure_secret "$server_env" MONGO_ROOT_PASSWORD
ensure_secret "$server_env" JWT_SECRET
ensure_secret "$server_env" ADMIN_PASSWORD
ensure_secret "$server_env" MYSQL_ROOT_PASSWORD
ensure_secret "$server_env" MYSQL_PASSWORD

set_key "$website_env" CONTAINER_FRONTEND docker
set_key "$website_env" WEBSITE_PROJECT_NAME cashlenx-website
set_key "$website_env" DOCKER_NETWORK_NAME cashlenx-network
set_key "$website_env" WEBSITE_BIND_ADDRESS 127.0.0.1
set_key "$website_env" WEBSITE_PORT 11065

chmod 600 "$app_env" "$server_env" "$website_env" 2>/dev/null || true

echo "Local Docker environment configured in .env.local for App, Server, MongoDB, MySQL compatibility, and Website."
echo "Existing non-placeholder secrets were preserved; no secret values were printed."
