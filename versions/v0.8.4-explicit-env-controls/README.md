# v0.8.4 Explicit Environment Controls

## Status

- Version: `v0.8.4`
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
- Target: Active environment assignments and explicit capability controls
- Affected project areas: app, server, website, spec
- Resulting runtime/displayed versions: app `0.7.0+7`, server `0.11.0`, website `0.1.0` (unchanged because this delivery changes deployment configuration only)

## Task Contract

- Goal: Make configuration activation explicit: keep every example assignment
  active, control optional capabilities with booleans, select database-container
  lifecycle through dependency scripts, and use one timezone setting.
- Context: Many operational settings and all MySQL/SMTP values were commented
  out. The Server exposed separate `TIMEZONE` and `TZ` values even though both
  represented timezone selection.
- Constraints: Preserve existing environment key compatibility where practical,
  do not add database enable flags, do not let irrelevant placeholders block API
  startup, do not print configured values, and do not overwrite existing ignored
  environment values or inspect owner-managed environment variants.
- Done when: No tracked example contains a commented assignment; optional Server
  capabilities have active lowercase boolean controls; Server validation follows
  the selected database and enabled capabilities; all Server/database containers
  derive `TZ` from `TIMEZONE`; catalog, Compose, negative, and package checks pass.

## Delivered Result

- Summary: Activated every assignment in the App, Server, and Website examples;
  added the complete database resource catalog; kept MySQL and disabled SMTP
  values visible; made Server startup validation database- and enable-aware; and
  mapped one `TIMEZONE` setting to the API, MongoDB, and MySQL containers.
- Changed behavior: Operators now change values directly instead of uncommenting
  assignments. `SMTP_ENABLED=false` suppresses SMTP credential validation, while
  enabling it requires the runtime's minimal SMTP fields. API startup validates
  only its selected database; explicit dependency scripts retain ownership of
  database-container validation. Invalid non-lowercase booleans are rejected.
  The Server runtime image now includes IANA timezone data.
- Compatibility: API, schema, persistence, container/project/volume names, ports,
  and runtime/displayed versions remain unchanged. Existing `TZ` values become
  obsolete because `TIMEZONE` becomes the single source.
- Migration/rollback: Existing regular `.env` values are preserved and missing
  active keys are appended. Owner-managed variants must be updated manually.
  Rollback restores commented template entries and the separate Compose `TZ`
  source without touching containers or persistent data.
- Implementation refs: `cashlenx-app` commit `71d46a4`; `cashlenx-server`
  commit `7ed5f95`; `cashlenx-website` commit `d356f4e`.

## Validation

- Commands and results: All three Compose catalogs rendered from `.env.example`;
  active-key coverage passed for App 22, Server 84, and Website 17 assignments;
  Server runtime-loader coverage passed for all 34 loaded keys; all examples had
  zero commented assignments; API, MongoDB, and MySQL rendered `TZ=UTC` from
  `TIMEZONE`; `docker build --check .`, lifecycle `bash -n`, the fake-Docker
  lifecycle smoke, `go test ./...`, all repository `git diff --check` checks,
  Spec English checks, and App/Server AGENTS source-snapshot hashes passed.
- Negative/auth/compatibility evidence when applicable: The lifecycle smoke
  proved default MongoDB API startup ignores MySQL and disabled SMTP placeholders,
  MySQL API selection accepts configured MySQL application credentials, enabled
  SMTP rejects its placeholder password, and `SMTP_ENABLED=ture` is rejected by
  key name before Compose start. Build and stop credential behavior remains
  unchanged. Synchronization preserved all existing values: App and Website
  `.env` hashes were unchanged, while Server `.env` received only 15 previously
  missing keys. Owner-managed environment variants were not read or modified.
- Known limits: Explicit examples are catalogs, not a complete runtime schema;
  application-level parsers still own numeric, duration, and enum handling. No
  shared-environment lifecycle command is in scope.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
