# v0.8.1 Environment Example And Selection

## Status

- Version: `v0.8.1`
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
- Target: Repository-local environment template and selection repair
- Affected project areas: app, server, website, spec
- Resulting runtime/displayed versions: app `0.7.0+7`, server `0.11.0`, website `0.1.0` (unchanged because this delivery changes configuration tooling only)

## Task Contract

- Goal: Track one readable `.env.example` per runtime repository and provide a
  consistent, safe `ENV_FILE` interface for container lifecycle scripts.
- Context: The repositories tracked `.env.sample`, exposed many defaulted
  settings as mandatory-looking active values, and lifecycle scripts always
  selected `.env`.
- Constraints: Existing local environment files must not be renamed, deleted,
  inspected, or overwritten. Selected files must remain inside their repository.
  Build may use placeholders; start must reject placeholders and legacy weak
  secrets without printing values; stop must remain available with incomplete
  values. Docker build-context hardening is deferred.
- Done when: Git tracks only `.env.example`, templates use a layered minimum,
  lifecycle scripts support repository-local `ENV_FILE`, Compose and App build
  inputs follow the selected file, current references are migrated, and scoped
  validation passes.

## Delivered Result

- Summary: Replaced the tracked sample convention with one layered
  `.env.example` per runtime repository and added a consistent, repository-local
  environment selection contract to all lifecycle scripts.
- Changed behavior: `ENV_FILE` now selects interpolation, runtime injection, and
  the App Flutter build asset. Missing, external, and symlink paths are rejected.
  Start rejects active placeholders, missing required Server secrets, and known
  legacy weak values without printing values; build permits placeholders and
  stop does not validate values. Server build-image defaults remain owned by
  `docker/images.env`, while optional environment settings remain discoverable
  as commented overrides.
- Compatibility: No API, schema, persistence, image name, service name, port, or
  runtime/displayed version change.
- Migration/rollback: Existing ignored files remain valid. Operators may keep
  using `.env` or select an existing repository-local variant with `ENV_FILE`.
  Rollback restores the former template name and fixed `.env` selection without
  changing persisted data.
- Implementation refs: `cashlenx-app` commit `63569be`; `cashlenx-server`
  commit `17ad69e`; `cashlenx-website` commit `2e072dd`.

## Validation

- Commands and results: `bash -n` passed for all nine lifecycle scripts;
  missing-file, repository-external path, placeholder, and legacy weak-value
  negative checks failed as expected; all three selected-file Compose configs
  rendered successfully; App build/runtime, Server runtime, and Website port
  mappings resolved from `.env.example`; `docker build --check` passed for the
  App Dockerfile; template catalog coverage and Git ignore matrices passed;
  Server `go test ./...` passed; current-reference scans, source-snapshot checks,
  spec language checks, and repository `git diff --check` passed.
- Negative/auth/compatibility evidence when applicable: Every lifecycle script
  contains explicit symlink and canonical repository-boundary rejection. Stop
  scripts contain no value validator and retain persistence-safe Compose down
  behavior. The synchronization script appended only the missing `ENV` key to
  the ignored Server `.env`; all existing values were preserved, and owner-managed
  `.env.testing` and `.env.production` files were not read or modified.
- Known limits at close: Docker build contexts were unchanged. That deferred
  work was later delivered through Jira item `CLX-27`; current behavior is
  documented in `../../system/operations.md`. No shared-environment lifecycle
  command was executed by this delivery.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
