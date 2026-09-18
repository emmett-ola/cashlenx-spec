#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
workspace_dir="$(cd "$spec_dir/.." && pwd -P)"
projects=(cashlenx-app cashlenx-server cashlenx-website)
profile=""
mode="sync"

usage() {
  cat <<'EOF'
Usage: scripts/sync-env.sh [--profile local|testing|production] [--check] [--workspace-dir PATH]

Without --profile, the backward-compatible target is .env. Named profiles target
.env.local, .env.testing, or .env.production. Sync creates a missing target from
.env.example or appends missing keys without replacing configured values. Check
is read-only and reports structural differences using key names only.
EOF
}

while (($#)); do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || { echo "--profile requires a value" >&2; exit 2; }
      profile="$2"
      shift 2
      ;;
    --check)
      mode="check"
      shift
      ;;
    --workspace-dir)
      [[ $# -ge 2 ]] || { echo "--workspace-dir requires a path" >&2; exit 2; }
      workspace_dir="$(cd "$2" && pwd -P)"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$profile" in
  "") target_name=".env" ;;
  local|testing|production) target_name=".env.$profile" ;;
  *) echo "Invalid profile: $profile (expected local, testing, or production)" >&2; exit 2 ;;
esac

list_duplicate_keys() {
  awk -F= '
    /^[A-Za-z_][A-Za-z0-9_]*=/ { count[$1]++ }
    END { for (key in count) if (count[key] > 1) print key }
  ' "$1" | sort
}

sync_project() {
  local project="$1"
  local project_dir="$workspace_dir/$project"
  local example_file="$project_dir/.env.example"
  local env_file="$project_dir/$target_name"
  local project_root
  local resolved_env
  local added=0
  local failed=0
  local duplicates

  [[ -f "$example_file" ]] || {
    echo "$project: missing .env.example" >&2
    return 1
  }

  duplicates="$(list_duplicate_keys "$example_file")"
  if [[ -n "$duplicates" ]]; then
    while IFS= read -r key; do
      echo "$project: duplicate key in .env.example: $key" >&2
    done <<< "$duplicates"
    return 1
  fi

  if [[ ! -e "$env_file" && ! -L "$env_file" ]]; then
    if [[ "$mode" == check ]]; then
      echo "$project: missing $target_name" >&2
      return 1
    fi
    cp "$example_file" "$env_file"
    chmod 600 "$env_file" 2>/dev/null || true
    echo "$project: created $target_name from .env.example"
    return 0
  fi

  [[ -f "$env_file" ]] || {
    echo "$project: $target_name must resolve to a regular file" >&2
    return 1
  }
  project_root="$(cd "$project_dir" && pwd -P)"
  resolved_env="$(realpath "$env_file")"
  case "$resolved_env" in
    "$project_root"/*) ;;
    *) echo "$project: $target_name must resolve inside its repository" >&2; return 1 ;;
  esac

  duplicates="$(list_duplicate_keys "$env_file")"
  if [[ -n "$duplicates" ]]; then
    while IFS= read -r key; do
      echo "$project: duplicate key in $target_name: $key" >&2
    done <<< "$duplicates"
    return 1
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue
    key="${line%%=*}"
    if ! grep -q "^${key}=" "$env_file"; then
      if [[ "$mode" == check ]]; then
        echo "$project: missing key in $target_name: $key" >&2
        failed=1
        continue
      fi
      [[ -w "$env_file" ]] || {
        echo "$project: $target_name is not writable; missing key: $key" >&2
        return 1
      }
      if [[ $added -eq 0 ]]; then
        printf '\n# Added from .env.example; review before deployment.\n' >> "$env_file"
      fi
      printf '%s\n' "$line" >> "$env_file"
      echo "$project: added missing key to $target_name: $key"
      added=$((added + 1))
    fi
  done < "$example_file"

  if [[ $failed -ne 0 ]]; then
    return 1
  fi

  if [[ "$mode" == check ]]; then
    echo "$project: $target_name is structurally synchronized"
  else
    chmod 600 "$env_file" 2>/dev/null || true
    echo "$project: synchronized $target_name; existing values preserved"
  fi
}

result=0
for project in "${projects[@]}"; do
  sync_project "$project" || result=1
done
exit "$result"
