#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace_dir="$(cd "$spec_dir/.." && pwd)"
projects=(cashlenx-app cashlenx-server cashlenx-website)

sync_project() {
  local project="$1"
  local project_dir="$workspace_dir/$project"
  local example_file="$project_dir/.env.example"
  local env_file="$project_dir/.env"
  local added=0

  [[ -f "$example_file" ]] || {
    echo "$project: missing .env.example" >&2
    return 1
  }

  if [[ ! -f "$env_file" ]]; then
    cp "$example_file" "$env_file"
    echo "$project: created .env from .env.example"
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue
    key="${line%%=*}"
    if ! grep -q "^${key}=" "$env_file"; then
      if [[ $added -eq 0 ]]; then
        printf '\n# Added from .env.example; review before deployment.\n' >> "$env_file"
      fi
      printf '%s\n' "$line" >> "$env_file"
      echo "$project: added missing key $key"
      added=$((added + 1))
    fi
  done < "$example_file"

  echo "$project: synchronized; existing values preserved"
}

for project in "${projects[@]}"; do
  sync_project "$project"
done
