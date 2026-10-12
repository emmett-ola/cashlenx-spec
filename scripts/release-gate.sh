#!/usr/bin/env bash
set -euo pipefail

spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
workspace_dir="$(cd "$spec_dir/.." && pwd -P)"
source "$spec_dir/scripts/lib/workspace-paths.sh"
database_scope="unchanged"
jira_preflight_reference=""
affected_components=(app server website)

usage() {
  cat <<'EOF'
Usage: scripts/release-gate.sh [options]

Options:
  --affected-components <csv>  Changed repositories: app,server,website.
  --database <scope>           unchanged, mongodb, mysql, or all.
  --jira-preflight-reference   Jira blocker-scan evidence reference.
EOF
}

while (($#)); do
  case "$1" in
    --affected-components)
      IFS=',' read -r -a affected_components <<<"${2:?missing affected component list}"
      shift 2
      ;;
    --database)
      database_scope="${2:?missing database scope}"
      shift 2
      ;;
    --jira-preflight-reference)
      jira_preflight_reference="${2:?missing Jira preflight reference}"
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

[[ -n "$jira_preflight_reference" ]] || {
  echo "--jira-preflight-reference is required." >&2
  exit 1
}
case "$database_scope" in
  unchanged|mongodb|mysql|all) ;;
  *) echo "Invalid database scope: $database_scope" >&2; exit 1 ;;
esac

declare -A selected=()
for component in "${affected_components[@]}"; do
  case "$component" in
    app|server|website) selected["$component"]=1 ;;
    *) echo "Invalid affected component: $component" >&2; exit 1 ;;
  esac
done
(( ${#selected[@]} > 0 )) || { echo "At least one affected component is required." >&2; exit 1; }

if [[ "$database_scope" == "unchanged" && -n "${selected[server]:-}" ]]; then
  echo "Server releases must select an explicit database validation scope." >&2
  exit 1
fi
if [[ "$database_scope" != "unchanged" ]]; then
  echo "The Bash dual-database rehearsal has not yet replaced the legacy PowerShell harness." >&2
  echo "Use --database unchanged only when the release introduces no Server or persistence change." >&2
  exit 1
fi

for command in git docker jq awk sed find cmp flutter dart; do
  command -v "$command" >/dev/null || { echo "$command is required." >&2; exit 1; }
done
docker version >/dev/null

sha256_file() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | awk '{ sub(/^\\/, "", $1); print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

read_env_value() {
  local file="$1"
  local key="$2"
  awk -F= -v key="$key" '$1 == key { sub("^[^=]*=", ""); print; exit }' "$file"
}

version="$(tr -d '[:space:]' < "$spec_dir/release/VERSION")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]] || {
  echo "Invalid semantic product version: $version" >&2
  exit 1
}

run_id="$(date -u +%Y%m%dT%H%M%SZ)-$(printf '%08x' "$((RANDOM * RANDOM))")"
gate_root="$spec_dir/.artifacts/release-gates/$run_id"
worktree_root="$spec_dir/.release-validation-worktrees/$run_id"
candidate_root="$gate_root/release-candidate"
artifact_root="$candidate_root/artifacts"
mkdir -p "$gate_root" "$worktree_root" "$artifact_root"

repo_keys=(app server website spec)
declare -A repo_names=(
  [app]=cashlenx-app
  [server]=cashlenx-server
  [website]=cashlenx-website
  [spec]=cashlenx-spec
)
declare -A expected_branches=(
  [app]=develop
  [server]=develop
  [website]=develop
  [spec]=main
)
declare -A repo_paths=()
declare -A commits=()
declare -A trees=()
declare -A upstreams=()
declare -A validation_paths=()

cleanup() {
  local key
  for key in "${repo_keys[@]}"; do
    if [[ -n "${validation_paths[$key]:-}" ]]; then
      git -C "${repo_paths[$key]}" worktree remove --force "${validation_paths[$key]}" >/dev/null 2>&1 || true
    fi
  done
  rmdir "$worktree_root" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for key in "${repo_keys[@]}"; do
  path="$(resolve_workspace_repo_dir "$workspace_dir" "$key")"
  repo_paths[$key]="$path"
  [[ -d "$path/.git" ]] || { echo "Missing Git repository: $path" >&2; exit 1; }
  [[ -z "$(git -C "$path" status --porcelain)" ]] || {
    echo "${repo_names[$key]} must be clean before the release gate." >&2
    exit 1
  }
  branch="$(git -C "$path" branch --show-current)"
  [[ "$branch" == "${expected_branches[$key]}" ]] || {
    echo "${repo_names[$key]} is on $branch; expected ${expected_branches[$key]}." >&2
    exit 1
  }
  upstream="$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')"
  read -r ahead behind < <(git -C "$path" rev-list --left-right --count "HEAD...$upstream")
  [[ "$ahead" == 0 && "$behind" == 0 ]] || {
    echo "${repo_names[$key]} must be synchronized with $upstream." >&2
    exit 1
  }
  commits[$key]="$(git -C "$path" rev-parse HEAD)"
  trees[$key]="$(git -C "$path" rev-parse 'HEAD^{tree}')"
  upstreams[$key]="$upstream"
  if [[ -n "${selected[$key]:-}" && -n "$(git -C "$path" tag --list "v$version")" ]]; then
    echo "Immutable tag v$version already exists in ${repo_names[$key]}." >&2
    exit 1
  fi
  validation_path="$worktree_root/${repo_names[$key]}"
  git -C "$path" worktree add --detach "$validation_path" "${commits[$key]}" >/dev/null
  validation_paths[$key]="$validation_path"
done

if [[ -n "${selected[app]:-}" ]]; then
  app_version="$(awk '/^version:/ { print $2; exit }' "${validation_paths[app]}/pubspec.yaml")"
  [[ "${app_version%%+*}" == "$version" ]] || {
    echo "App product version is ${app_version%%+*}; expected $version." >&2
    exit 1
  }
fi
if [[ -n "${selected[server]:-}" ]]; then
  server_version="$(sed -n 's/^const Version = "\([^"]*\)"$/\1/p' "${validation_paths[server]}/model/version.go")"
  [[ "$server_version" == "$version" ]] || { echo "Server version mismatch." >&2; exit 1; }
fi
if [[ -n "${selected[website]:-}" ]]; then
  website_version="$(jq -r '.version' "${validation_paths[website]}/package.json")"
  [[ "$website_version" == "$version" ]] || { echo "Website version mismatch." >&2; exit 1; }
fi

cmp -s "${validation_paths[server]}/docs/openapi.yaml" "${validation_paths[app]}/server/docs/openapi.yaml" || {
  echo "App and Server OpenAPI copies differ." >&2
  exit 1
}
for component in "${affected_components[@]}"; do
  grep -Fq "[$version]" "${validation_paths[$component]}/CHANGELOG.md" || {
    echo "${repo_names[$component]} changelog does not contain [$version]." >&2
    exit 1
  }
done
grep -Fq "[$version]" "${validation_paths[spec]}/CHANGELOG.md" || {
  echo "Spec changelog does not contain [$version]." >&2
  exit 1
}
release_note="${validation_paths[spec]}/release/notes/$version.md"
[[ -f "$release_note" ]] && grep -Fq "$version" "$release_note" || {
  echo "Missing or invalid release note for $version." >&2
  exit 1
}

if [[ -n "${selected[app]:-}" ]]; then
  app_images="${validation_paths[app]}/docker/images.env"
  flutter_version="$(read_env_value "$app_images" FLUTTER_VERSION)"
  flutter_revision="$(read_env_value "$app_images" FLUTTER_REVISION)"
  dart_version="$(read_env_value "$app_images" DART_VERSION)"
  flutter_machine="$(flutter --version --machine)"
  [[ "$(jq -r '.frameworkVersion' <<<"$flutter_machine")" == "$flutter_version" ]] || {
    echo "Local Flutter does not match the tracked toolchain version $flutter_version." >&2
    exit 1
  }
  [[ "$(jq -r '.frameworkRevision' <<<"$flutter_machine")" == "$flutter_revision" ]] || {
    echo "Local Flutter does not match the tracked framework revision $flutter_revision." >&2
    exit 1
  }
  [[ "$(jq -r '.dartSdkVersion' <<<"$flutter_machine")" == "$dart_version" ]] || {
    echo "Local Dart does not match the tracked toolchain version $dart_version." >&2
    exit 1
  }
  (
    cd "${validation_paths[app]}"
    flutter pub get --enforce-lockfile
    flutter analyze
    flutter test
  )
fi

if [[ -n "${selected[server]:-}" ]]; then
  server_images="${validation_paths[server]}/docker/images.env"
  go_image="$(read_env_value "$server_images" GO_TEST_IMAGE)"
  go_version="$(read_env_value "$server_images" GO_VERSION)"
  docker run --rm \
    --volume "${validation_paths[server]}:/workspace" \
    --workdir /workspace \
    "$go_image" sh -c \
    "go mod download && go mod verify && test \"\$(go env GOVERSION)\" = go$go_version && go build -mod=readonly ./... && go test -mod=readonly -race ./..."
fi

if [[ -n "${selected[website]:-}" ]]; then
  website_images="${validation_paths[website]}/docker/images.env"
  bun_image="$(read_env_value "$website_images" BUN_BUILD_IMAGE)"
  bun_version="$(read_env_value "$website_images" BUN_VERSION)"
  docker run --rm \
    --volume "${validation_paths[website]}:/workspace" \
    --volume /workspace/node_modules \
    --tmpfs /workspace/dist \
    --workdir /workspace \
    "$bun_image" sh -c \
    "test \"\$(bun --version)\" = $bun_version && bun --no-env-file install --frozen-lockfile && scripts/audit-dependencies.sh && bun --no-env-file run build"
fi

pass_one="$candidate_root/.pass-1"
pass_two="$candidate_root/.pass-2"
mkdir -p "$pass_one" "$pass_two"
for component in "${affected_components[@]}"; do
  component_path="${validation_paths[$component]}"
  for pass_path in "$pass_one" "$pass_two"; do
    output_path="$pass_path/$component"
    mkdir -p "$output_path"
    env \
      RELEASE_OUTPUT_DIR="$output_path" \
      PRODUCT_VERSION="$version" \
      GIT_COMMIT="${commits[$component]}" \
      ENV_FILE=.env.example \
      bash "$component_path/scripts/package-image.sh" "$output_path"
  done
  first_metadata="$(find "$pass_one/$component" -maxdepth 1 -name '*.image.tar.json' -print -quit)"
  second_metadata="$(find "$pass_two/$component" -maxdepth 1 -name '*.image.tar.json' -print -quit)"
  [[ -n "$first_metadata" && -n "$second_metadata" ]] || { echo "Missing $component package metadata." >&2; exit 1; }
  for field in image_id image_ref artifact_sha256 version revision; do
    first_value="$(jq -r ".$field" "$first_metadata")"
    second_value="$(jq -r ".$field" "$second_metadata")"
    [[ "$first_value" == "$second_value" ]] || { echo "$component replay mismatch: $field" >&2; exit 1; }
  done
  artifact_name="$(jq -r '.artifact' "$first_metadata")"
  cp "$pass_one/$component/$artifact_name" "$artifact_root/"
  cp "$pass_one/$component/$artifact_name.sha256" "$artifact_root/"
  cp "$first_metadata" "$artifact_root/"
done

for key in "${affected_components[@]}" spec; do
  archive_name="${repo_names[$key]}-$version-${commits[$key]:0:12}.source.zip"
  first_archive="$pass_one/$archive_name"
  second_archive="$pass_two/$archive_name"
  git -C "${repo_paths[$key]}" archive --format=zip --output="$first_archive" "${commits[$key]}"
  git -C "${repo_paths[$key]}" archive --format=zip --output="$second_archive" "${commits[$key]}"
  [[ "$(sha256_file "$first_archive")" == "$(sha256_file "$second_archive")" ]] || {
    echo "Source archive replay mismatch: ${repo_names[$key]}" >&2
    exit 1
  }
  cp "$first_archive" "$artifact_root/"
done
cp "$release_note" "$artifact_root/release-notes-$version.md"
(
  cd "$artifact_root"
  find . -maxdepth 1 -type f ! -name SHA256SUMS -print | sort | while IFS= read -r file; do
    printf '%s  %s\n' "$(sha256_file "$file")" "${file#./}"
  done > SHA256SUMS
)

browser_root="$gate_root/browser"
EVIDENCE_ROOT="$browser_root" bash "$spec_dir/scripts/whole-product-acceptance.sh"
browser_manifest="$(find "$browser_root" -name manifest.txt -print -quit)"
[[ -n "$browser_manifest" ]] || { echo "Whole-product browser manifest was not created." >&2; exit 1; }

repositories_json='{}'
for key in "${repo_keys[@]}"; do
  affected=false
  [[ -n "${selected[$key]:-}" ]] && affected=true
  repositories_json="$(jq \
    --arg key "$key" \
    --arg branch "${expected_branches[$key]}" \
    --arg upstream "${upstreams[$key]}" \
    --arg commit "${commits[$key]}" \
    --arg tree "${trees[$key]}" \
    --argjson affected "$affected" \
    '. + {($key): {branch:$branch,upstream:$upstream,commit:$commit,tree:$tree,affected:$affected}}' \
    <<<"$repositories_json")"
done
affected_json="$(printf '%s\n' "${affected_components[@]}" | jq -R . | jq -s .)"
jq -n \
  --arg run_id "$run_id" \
  --arg version "$version" \
  --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg jira "$jira_preflight_reference" \
  --arg database "$database_scope" \
  --arg browser_path "${browser_manifest#"$gate_root/"}" \
  --arg browser_sha "$(sha256_file "$browser_manifest")" \
  --argjson affected_components "$affected_json" \
  --argjson repositories "$repositories_json" \
  '{schema_version:2,run_id:$run_id,result:"passed",release_ready:true,version:$version,affected_components:$affected_components,completed_at:$completed_at,repositories:$repositories,validations:{jira_preflight:("passed: "+$jira),repository_static_and_unit:"passed",reproducible_candidate:"passed",whole_product_browser:"passed"},database:{scope:$database,classification:"No database change required"},evidence:{browser:{path:$browser_path,sha256:$browser_sha}},requested_delivery_actions:[],performed_delivery_actions:[],deployment_state:"Not deployed",secrets_recorded:false}' \
  > "$gate_root/manifest.json"
printf '%s  manifest.json\n' "$(sha256_file "$gate_root/manifest.json")" > "$gate_root/manifest.json.sha256"
rm -rf "$pass_one" "$pass_two"

echo "Release gate passed: $gate_root/manifest.json"
echo "manifest_sha256=$(sha256_file "$gate_root/manifest.json")"
