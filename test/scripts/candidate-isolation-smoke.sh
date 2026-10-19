#!/usr/bin/env bash
set -euo pipefail
spec_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/evidence" "$fixture/artifacts"
cat > "$fixture/bin/docker" <<'DOCKER'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$DOCKER_CALLS"
exit 99
DOCKER
chmod +x "$fixture/bin/docker"
export DOCKER_CALLS="$fixture/docker-calls"
if env -u APP_SOURCE -u SERVER_SOURCE -u WEBSITE_SOURCE -u CANDIDATE_ARTIFACTS -u EVIDENCE_ROOT PATH="$fixture/bin:$PATH" bash "$spec_dir/scripts/whole-product-acceptance.sh" > "$fixture/missing.log" 2>&1; then exit 1; fi
[[ ! -e "$DOCKER_CALLS" ]]
for key in app server website; do
  mkdir -p "$fixture/$key/docker/dependencies"
  git -C "$fixture/$key" init -q
  touch "$fixture/$key/docker/images.env" "$fixture/$key/docker/dependencies/images.env"
  git -C "$fixture/$key" add .
  git -C "$fixture/$key" -c user.name=Fixture -c user.email=fixture@example.invalid commit -qm fixture
  echo '{"revision":"incorrect","artifact":"tampered.image.tar","artifact_sha256":"incorrect"}' > "$fixture/artifacts/cashlenx-$key-test.image.tar.json"
done
if APP_SOURCE="$fixture/app" SERVER_SOURCE="$fixture/server" WEBSITE_SOURCE="$fixture/website" CANDIDATE_ARTIFACTS="$fixture/artifacts" EVIDENCE_ROOT="$fixture/evidence" PATH="$fixture/bin:$PATH" bash "$spec_dir/scripts/whole-product-acceptance.sh" > "$fixture/tamper.log" 2>&1; then exit 1; fi
[[ ! -e "$DOCKER_CALLS" ]]
echo 'Explicit candidate inputs and source-tamper rejection passed before container mutation.'
