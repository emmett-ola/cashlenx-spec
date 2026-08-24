# v0.8.0 Deployment Script Lifecycle

## Status

- Version: `v0.8.0`
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
- Started: 2026-08-24
- Target: Repository-local container lifecycle consolidation
- Affected project areas: app, server, website, spec
- Resulting runtime/displayed versions: app `0.7.0+7`, server `0.11.0`, website `0.1.0` (unchanged because the delivery changes deployment tooling only)

## Task Contract

- Goal: Give every deployable project exactly three container entry scripts:
  `build.sh`, `start.sh`, and `stop.sh`.
- Context: Health checks were split into separate scripts, the server deployment
  directory mixed runtime, CI, documentation, interactive, and smoke tooling,
  and there was no uniform non-destructive stop entry point.
- Constraints: `start.sh` must use an existing image without rebuilding;
  `stop.sh` must remove project containers and networks while preserving images,
  bind-mounted data, named volumes, and independently managed databases; active
  CI and smoke coverage must remain functional; no environment deployment is
  authorized by this delivery.
- Done when: All three runtime `scripts/` directories contain only the three
  named executable shell scripts, Compose health waiting is integrated into
  startup, stop behavior is persistence-safe, active test tooling and CI paths
  are valid, and current operations/testing documentation is synchronized.

## Delivered Result

- Summary: Consolidated every deployable project's runtime entry points to
  exactly `build.sh`, `start.sh`, and `stop.sh`; integrated health waiting into
  startup; and removed obsolete deployment helpers without dropping active
  server smoke coverage.
- Changed behavior: `start.sh` now starts or updates from an existing image with
  Compose `--no-build --wait`; server startup no longer force-recreates a healthy
  container. `stop.sh` removes the owning Compose project's containers and
  network without removing images or volumes. Server smoke checks now live under
  `test/scripts/`, and CI invokes its race/coverage command directly.
- Compatibility: No API, schema, application behavior, image name, Compose
  service name, or persistent-volume contract changes are planned.
- Migration/rollback: No data migration. Roll back the repository commits to
  restore the former script layout; persisted database volumes and server log
  directories remain untouched by both forward and rollback operations.
- Implementation refs: `cashlenx-app` commit `76e65f8`; `cashlenx-server`
  commit `9225978`; `cashlenx-website` commit `ba69186`.

## Validation

- Commands and results: `bash -n` passed for all nine lifecycle scripts and the
  relocated API smoke script; PowerShell parsing passed for both relocated smoke
  scripts; `docker compose config --quiet` passed from each runtime project;
  `go test ./...` passed for the server; repository-local `git diff --check`
  passed; script-inventory, lifecycle-contract, stale-reference, CI-path, and
  source-snapshot assertions passed.
- Negative/auth/compatibility evidence when applicable: Each `stop.sh` Compose
  command was asserted not to contain `--volumes`, `-v`, or `--rmi`. The server
  dependency Compose files and named volumes `cashlenx-mongodb-data` and
  `cashlenx-mysql-data` were not modified or targeted. Existing image names,
  service names, ports, APIs, and schemas remain unchanged.
- Known limits: Container startup and shutdown will not be executed against a
  shared environment without separate deployment authorization.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
