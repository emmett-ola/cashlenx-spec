#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
workspace_dir="$(cd "$spec_dir/.." && pwd -P)"
state_dir="$spec_dir/.state/environment-lifecycle"
profile=""
database=""
include_website=true
phase="${1:-}"
[[ -n "$phase" ]] && shift

usage() {
  cat <<'EOF'
Usage: scripts/environment-lifecycle.sh PHASE --profile PROFILE --database DATABASE [options]

PHASE is one of: preflight, build, start, status, doctor, logs, stop.
PROFILE is one of: local, testing, production.
DATABASE is one of: mongodb, mysql.

Options:
  --without-website     Exclude the product website.
  --workspace-dir PATH Use an alternate three-repository workspace.
  --state-dir PATH     Use an alternate coordinator state directory.
EOF
}

while (($#)); do
  case "$1" in
    --profile) [[ $# -ge 2 ]] || { echo "--profile requires a value" >&2; exit 2; }; profile="$2"; shift 2 ;;
    --database) [[ $# -ge 2 ]] || { echo "--database requires a value" >&2; exit 2; }; database="$2"; shift 2 ;;
    --without-website) include_website=false; shift ;;
    --workspace-dir) [[ $# -ge 2 ]] || { echo "--workspace-dir requires a path" >&2; exit 2; }; workspace_dir="$(cd "$2" && pwd -P)"; shift 2 ;;
    --state-dir) [[ $# -ge 2 ]] || { echo "--state-dir requires a path" >&2; exit 2; }; mkdir -p "$2"; state_dir="$(cd "$2" && pwd -P)"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$phase" in preflight|build|start|status|doctor|logs|stop) ;; *) usage >&2; exit 2 ;; esac
case "$profile" in local|testing|production) ;; *) echo "Invalid or missing profile" >&2; exit 2 ;; esac
case "$database" in mongodb|mysql) ;; *) echo "Invalid or missing database" >&2; exit 2 ;; esac

env_name=".env.$profile"
app_dir="$workspace_dir/cashlenx-app"
server_dir="$workspace_dir/cashlenx-server"
website_dir="$workspace_dir/cashlenx-website"
mkdir -p "$state_dir"
state_file="$state_dir/$profile-$database.state"

value_for() {
  local file="$1"
  local key="$2"
  awk -F= -v key="$key" '$1 == key { sub("^[^=]*=", ""); print; exit }' "$file"
}

require_key() {
  local file="$1"
  local key="$2"
  local value
  value="$(value_for "$file" "$key")"
  if [[ -z "$value" ]]; then
    echo "Preflight failed: missing or empty key $key" >&2
    return 1
  fi
  printf '%s' "$value"
}

reject_placeholder() {
  local file="$1"
  local key="$2"
  local value
  value="$(value_for "$file" "$key")"
  if [[ -z "$value" || "$value" == CHANGE_ME* ]]; then
    echo "Preflight failed: unresolved required key $key" >&2
    return 1
  fi
}

preflight() {
  local app_env="$app_dir/$env_name"
  local server_env="$server_dir/$env_name"
  local website_env="$website_dir/$env_name"
  local app_network server_network website_network
  local app_frontend server_frontend website_frontend
  local app_port server_port website_port database_port
  local db_type
  local identity
  local seen="|"

  for directory in "$app_dir" "$server_dir" "$website_dir"; do
    [[ -d "$directory" ]] || { echo "Preflight failed: missing repository directory" >&2; return 1; }
  done

  bash "$spec_dir/scripts/sync-env.sh" --profile "$profile" --check --workspace-dir "$workspace_dir" >/dev/null

  for script in \
    "$app_dir/scripts/build.sh" "$app_dir/scripts/start.sh" "$app_dir/scripts/status.sh" "$app_dir/scripts/doctor.sh" "$app_dir/scripts/logs.sh" "$app_dir/scripts/stop.sh" \
    "$server_dir/scripts/build.sh" "$server_dir/scripts/start.sh" "$server_dir/scripts/status.sh" "$server_dir/scripts/doctor.sh" "$server_dir/scripts/logs.sh" "$server_dir/scripts/stop.sh" \
    "$server_dir/scripts/dependencies/$database/build.sh" "$server_dir/scripts/dependencies/$database/start.sh" "$server_dir/scripts/dependencies/$database/status.sh" "$server_dir/scripts/dependencies/$database/doctor.sh" "$server_dir/scripts/dependencies/$database/logs.sh" "$server_dir/scripts/dependencies/$database/stop.sh"; do
    [[ -f "$script" ]] || { echo "Preflight failed: missing lifecycle entry point" >&2; return 1; }
  done
  if [[ "$include_website" == true ]]; then
    for action in build start status doctor logs stop; do
      [[ -f "$website_dir/scripts/$action.sh" ]] || { echo "Preflight failed: missing Website lifecycle entry point" >&2; return 1; }
    done
  fi

  app_network="$(require_key "$app_env" DOCKER_NETWORK_NAME)"
  server_network="$(require_key "$server_env" DOCKER_NETWORK_NAME)"
  [[ "$app_network" == "$server_network" ]] || { echo "Preflight failed: DOCKER_NETWORK_NAME differs between repositories" >&2; return 1; }
  if [[ "$include_website" == true ]]; then
    website_network="$(require_key "$website_env" DOCKER_NETWORK_NAME)"
    [[ "$app_network" == "$website_network" ]] || { echo "Preflight failed: DOCKER_NETWORK_NAME differs between repositories" >&2; return 1; }
  fi

  app_frontend="$(require_key "$app_env" CONTAINER_FRONTEND)"
  server_frontend="$(require_key "$server_env" CONTAINER_FRONTEND)"
  [[ "$app_frontend" == "$server_frontend" ]] || { echo "Preflight failed: CONTAINER_FRONTEND differs between repositories" >&2; return 1; }
  if [[ "$include_website" == true ]]; then
    website_frontend="$(require_key "$website_env" CONTAINER_FRONTEND)"
    [[ "$app_frontend" == "$website_frontend" ]] || { echo "Preflight failed: CONTAINER_FRONTEND differs between repositories" >&2; return 1; }
  fi

  db_type="$(require_key "$server_env" DB_TYPE)"
  [[ "$db_type" == "$database" ]] || { echo "Preflight failed: DB_TYPE does not match the selected database" >&2; return 1; }

  app_port="$(require_key "$app_env" WEB_PORT)"
  server_port="$(require_key "$server_env" SERVER_PORT)"
  if [[ "$database" == mongodb ]]; then
    database_port="$(require_key "$server_env" MONGO_PORT)"
  else
    database_port="$(require_key "$server_env" MYSQL_PORT)"
  fi
  website_port=""
  if [[ "$include_website" == true ]]; then website_port="$(require_key "$website_env" WEBSITE_PORT)"; fi
  for port in "$app_port" "$server_port" "$database_port" ${website_port:+"$website_port"}; do
    [[ "$port" =~ ^[0-9]+$ && "$port" -ge 0 && "$port" -le 65535 ]] || { echo "Preflight failed: invalid published port" >&2; return 1; }
    [[ "$port" == 0 || "$seen" != *"|port:$port|"* ]] || { echo "Preflight failed: duplicate published port" >&2; return 1; }
    [[ "$port" == 0 ]] || seen+="port:$port|"
  done

  seen="|"
  for identity in \
    "$(require_key "$app_env" CONTAINER_NAME)" \
    "$(require_key "$server_env" BACKEND_CONTAINER_NAME)" \
    "$([[ "$database" == mongodb ]] && require_key "$server_env" MONGO_CONTAINER_NAME || require_key "$server_env" MYSQL_CONTAINER_NAME)" \
    $([[ "$include_website" == true ]] && require_key "$website_env" WEBSITE_CONTAINER_NAME || true); do
    [[ "$seen" != *"|$identity|"* ]] || { echo "Preflight failed: duplicate container identity" >&2; return 1; }
    seen+="$identity|"
  done

  seen="|"
  for identity in \
    "$(require_key "$app_env" APP_PROJECT_NAME)" \
    "$(require_key "$server_env" SERVER_PROJECT_NAME)" \
    "$([[ "$database" == mongodb ]] && require_key "$server_env" MONGO_PROJECT_NAME || require_key "$server_env" MYSQL_PROJECT_NAME)" \
    $([[ "$include_website" == true ]] && require_key "$website_env" WEBSITE_PROJECT_NAME || true); do
    [[ "$identity" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || { echo "Preflight failed: invalid project identity" >&2; return 1; }
    [[ "$seen" != *"|$identity|"* ]] || { echo "Preflight failed: duplicate project identity" >&2; return 1; }
    seen+="$identity|"
  done

  reject_placeholder "$server_env" JWT_SECRET
  reject_placeholder "$server_env" ADMIN_PASSWORD
  if [[ "$database" == mongodb ]]; then
    reject_placeholder "$server_env" MONGO_ROOT_PASSWORD
  else
    reject_placeholder "$server_env" MYSQL_ROOT_PASSWORD
    reject_placeholder "$server_env" MYSQL_PASSWORD
  fi

  echo "Preflight passed for profile=$profile database=$database; configured values were not printed."
}

run_component() {
  local component="$1"
  local action="$2"
  case "$component" in
    database) (cd "$server_dir" && ENV_FILE="$env_name" bash "scripts/dependencies/$database/$action.sh") ;;
    server) (cd "$server_dir" && ENV_FILE="$env_name" bash "scripts/$action.sh") ;;
    app) (cd "$app_dir" && ENV_FILE="$env_name" bash "scripts/$action.sh") ;;
    website) (cd "$website_dir" && ENV_FILE="$env_name" bash "scripts/$action.sh") ;;
  esac
}

components() {
  printf '%s\n' database server app
  [[ "$include_website" == true ]] && printf '%s\n' website
}

rollback_started() {
  [[ -f "$state_file" ]] || return 0
  mapfile -t started < "$state_file"
  for ((index=${#started[@]} - 1; index >= 0; index--)); do
    run_component "${started[$index]}" stop >/dev/null 2>&1 || true
  done
  rm -f "$state_file"
}

diagnose_component() {
  local component="$1"
  echo "$component: value-free status/doctor diagnostics" >&2
  run_component "$component" status >&2 || true
  run_component "$component" doctor >&2 || true
}

case "$phase" in
  preflight)
    preflight
    ;;
  build)
    preflight
    while IFS= read -r component; do run_component "$component" build; done < <(components)
    ;;
  start)
    preflight
    if [[ -s "$state_file" ]]; then
      echo "Start refused: this profile/database already has coordinator state; run status or stop first" >&2
      exit 1
    fi
    : > "$state_file"
    while IFS= read -r component; do
      status_output=""
      if status_output="$(run_component "$component" status 2>&1)"; then
        echo "$component: already healthy; left unmanaged by this run"
        continue
      fi
      if grep -E '^container_state=' <<< "$status_output" | grep -Fv '=missing' >/dev/null; then
        echo "$component: an existing degraded container was detected; refusing to mutate it" >&2
        diagnose_component "$component"
        rollback_started
        exit 1
      fi
      if ! run_component "$component" start; then
        echo "$component: start failed; rolling back resources started by this run" >&2
        diagnose_component "$component"
        rollback_started
        exit 1
      fi
      printf '%s\n' "$component" >> "$state_file"
      if ! run_component "$component" status >/dev/null; then
        echo "$component: health gate failed; rolling back resources started by this run" >&2
        diagnose_component "$component"
        rollback_started
        exit 1
      fi
      echo "$component: started and health-gated"
    done < <(components)
    ;;
  status|doctor|logs)
    preflight
    result=0
    while IFS= read -r component; do run_component "$component" "$phase" || result=1; done < <(components)
    exit "$result"
    ;;
  stop)
    if [[ ! -s "$state_file" ]]; then
      echo "No resources are recorded for this coordinator run; nothing was stopped."
      rm -f "$state_file"
      exit 0
    fi
    preflight
    result=0
    mapfile -t started < "$state_file"
    for ((index=${#started[@]} - 1; index >= 0; index--)); do
      run_component "${started[$index]}" stop || result=1
    done
    rm -f "$state_file"
    exit "$result"
    ;;
esac
