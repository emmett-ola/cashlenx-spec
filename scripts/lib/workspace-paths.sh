#!/usr/bin/env bash

workspace_repo_short_name() {
  case "$1" in
    app|server|website|spec) printf '%s\n' "$1" ;;
    *) echo "Unknown workspace repository key: $1" >&2; return 2 ;;
  esac
}

workspace_repo_remote_name() {
  case "$1" in
    app) printf '%s\n' cashlenx-app ;;
    server) printf '%s\n' cashlenx-server ;;
    website) printf '%s\n' cashlenx-website ;;
    spec) printf '%s\n' cashlenx-spec ;;
    *) echo "Unknown workspace repository key: $1" >&2; return 2 ;;
  esac
}

resolve_workspace_repo_dir() {
  local workspace_root="$1"
  local repository_key="$2"
  local short_name
  local remote_name
  local short_path
  local remote_path

  short_name="$(workspace_repo_short_name "$repository_key")"
  remote_name="$(workspace_repo_remote_name "$repository_key")"
  short_path="$workspace_root/$short_name"
  remote_path="$workspace_root/$remote_name"

  if [[ -d "$short_path" ]]; then
    printf '%s\n' "$short_path"
    return 0
  fi
  if [[ -d "$remote_path" ]]; then
    printf '%s\n' "$remote_path"
    return 0
  fi

  echo "Missing workspace repository: expected $short_path or $remote_path" >&2
  return 1
}
