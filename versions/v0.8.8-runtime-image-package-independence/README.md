# v0.8.8 Runtime Image Package Independence

## Status

- Version: `v0.8.8`
- State: Closed
- Work Level: Standard
- Execution Owner: AI
- Validation Owner: AI
- Validated At: `2026-08-24`
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: `2026-08-24`
- Target: Server image builds without Alpine package-repository availability
- Affected project areas: server, spec
- Resulting runtime/displayed versions: server `0.11.0` (unchanged because this delivery repairs the image build only)

## Task Contract

- Goal: Make the Server image build succeed when Alpine APK indexes are
  temporarily unavailable, without losing health checks or IANA timezone
  support.
- Context: `apk add --no-cache curl tzdata` failed after both Alpine repository
  index downloads returned temporary errors, causing misleading package-not-
  found messages and cancelling the otherwise successful Go build stage.
- Constraints: Preserve the selected Go and Alpine base image values, API and
  container behavior, configurable timezone contract, health timing, image
  labels, and build/start/stop interfaces; do not start shared services.
- Done when: Dockerfile contains no APK installation step; Go embeds timezone
  data; Compose health uses a verified base-image utility; package, Compose,
  Dockerfile, and actual `scripts/build.sh` checks pass.

## Delivered Result

- Summary: Removed both Alpine package-install steps, embedded the IANA timezone
  database in the Go binary, and changed the API healthcheck from installed
  `curl` to the Alpine base image's BusyBox `wget` applet.
- Changed behavior: Server image construction no longer downloads Alpine APK
  indexes or installs `git`, `curl`, or `tzdata`. Health requests retain a
  three-second command timeout and fail on an unreachable or non-successful HTTP
  response. Region-based timezone validation remains available without OS
  timezone packages.
- Compatibility: The configured `golang:1.23-alpine` and `alpine:3.18` image
  values, binary entrypoint, API paths, health interval/retries/start period,
  environment contract, source-revision label, and runtime version remain
  unchanged. The produced binary grows by the standard embedded timezone
  database instead of relying on the runtime filesystem package.
- Migration/rollback: No runtime or data migration is required. Rollback
  restores APK installation and the curl health command; existing images and
  containers are not modified automatically.
- Implementation refs: `cashlenx-server` commit `b6f39e0`.

## Validation

- Commands and results: Focused `util` and `controller` tests passed;
  `go test ./...` passed; `docker build --check .` reported no warnings; Server
  Compose rendering passed and selected `wget` rather than `curl`; and the
  originally failing `bash ./scripts/build.sh` completed successfully twice,
  including a final post-commit image build. The final image label matched
  `b6f39e0`. Server and Spec `git diff --check`, Spec English checks, and the
  Server AGENTS source-snapshot comparison passed.
- Negative/auth/compatibility evidence when applicable: The selected
  `alpine:3.18` base was directly verified to provide a working BusyBox `wget`.
  The final runtime image had no `curl` command or installed `tzdata` package,
  while its Server binary contained the embedded `Asia/Shanghai` zone entry.
  A tracked-file scan found no remaining `apk add` or curl health dependency.
- Known limits: A fully uncached build still requires access to the selected
  Docker registries and Go module sources; this delivery removes only the Alpine
  package-index dependency that caused the reported failure. A custom
  `RUNTIME_IMAGE` must provide a compatible `sh` and `wget`. The Alpine base
  version was intentionally not changed. No API or database service was
  started; runtime image checks used disposable removed containers only.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
