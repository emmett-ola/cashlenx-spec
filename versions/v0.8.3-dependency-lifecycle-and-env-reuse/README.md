# v0.8.3 Dependency Lifecycle And Environment Reuse

## Status

- Version: `v0.8.3`
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
- Target: Explicit database dependency lifecycle and single-definition values
- Affected project areas: server, spec
- Resulting runtime/displayed versions: server `0.11.0` (unchanged because API and product behavior are unaffected)

## Task Contract

- Goal: Give MongoDB and MySQL explicit, independent lifecycle entry points and
  let database URIs reuse credentials defined once in the selected environment
  file.
- Context: Root Server scripts already manage only the API, while database
  dependencies use manually invoked flat Compose files. Example URIs repeat
  usernames, passwords, and database names, increasing configuration drift.
- Constraints: Root scripts must never implicitly start or stop a dependency
  from `DB_TYPE`. Each dependency must preserve its named volume on stop, use
  the repository-local `ENV_FILE` boundary, reject unsafe start values without
  printing them, and remain stoppable with incomplete credentials. Existing
  ignored environment values must not be overwritten.
- Done when: MongoDB and MySQL each own Compose/assets plus build/start/stop
  scripts in database-specific directories; URI references expand in Compose
  and direct Server dotenv loading; lifecycle isolation and negative credential
  paths pass focused tests; current docs and spec facts are synchronized.

## Delivered Result

- Summary: Moved each database Compose project, initialization assets, and guide
  into its own dependency directory; added build/start/stop scripts for MongoDB
  and MySQL; changed example database URIs to reuse earlier atomic values; and
  removed the canonical MySQL bootstrap's repeated database-name literal.
- Changed behavior: Dependency build pulls the configured upstream image,
  dependency start validates only the selected database's required credentials
  and waits for health, and dependency stop removes its container and network
  while preserving its image and named volume. Root Server scripts continue to
  manage only the API. Root API startup no longer treats the MySQL dependency's
  root password as an API-owned connection requirement.
- Compatibility: Existing containers and named data volumes keep their project
  and volume names. Old flat dependency Compose paths are replaced by supported
  lifecycle scripts; API, schema, persistence data, and root Server lifecycle
  behavior remain unchanged.
- Migration/rollback: Operators switch direct dependency Compose commands to the
  database-specific scripts and may manually adopt URI references in existing
  ignored environment files. Rollback restores the flat Compose paths and
  literal example URIs without touching named volumes.
- Implementation refs: `cashlenx-server` commit `e84c177`.

## Validation

- Commands and results: `go test ./...` passed; `bash -n` passed for the nine
  API/dependency lifecycle scripts and the focused lifecycle smoke script; the
  fake-Docker lifecycle smoke passed; API, MongoDB, and MySQL Compose configs
  rendered successfully; Compose expanded the referenced MongoDB URI to the
  expected value; the Go dotenv expansion contract test passed; stale current
  path scans, Server and Spec `git diff --check`, the Spec English check, and
  the Server AGENTS source-snapshot hash check passed.
- Negative/auth/compatibility evidence when applicable: The lifecycle smoke
  proved missing and repository-external files are rejected, placeholder or
  missing dependency credentials are rejected before Compose start, only key
  names are reported, dependency stop remains available with incomplete values,
  and root Server start never invokes a dependency Compose project. Environment
  synchronization preserved all existing values; SHA-256 checks confirmed all
  three ignored `.env` files were unchanged, and owner-managed environment
  variants were not read or modified.
- Known limits: Dependency build means pulling an upstream image because neither
  database has a project Dockerfile. Lifecycle scripts do not orchestrate the
  API and database together. No shared-environment command is in scope.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
