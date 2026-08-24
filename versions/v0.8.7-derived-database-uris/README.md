# v0.8.7 Derived Database URIs

## Status

- Version: `v0.8.7`
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
- Target: Single-definition database connection values
- Affected project areas: server, spec
- Resulting runtime/displayed versions: server `0.11.0` (unchanged because this delivery changes deployment configuration only)

## Task Contract

- Goal: Ensure every derived MongoDB/MySQL URI reuses the atomic username,
  password, port, and database settings instead of repeating fallback constants.
- Context: Local URIs already support `${NAME}` references, but the Server
  Compose override rebuilt Docker URIs with duplicated usernames, weak password
  defaults, ports, and database names.
- Constraints: Keep local and container host differences explicit, preserve the
  evaluated values of equivalent local URI literals, preserve non-equivalent
  custom URI overrides, allow image builds with placeholders, block Server start
  when the selected Docker URI is absent or its referenced credentials are
  unsafe, and never print configured values.
- Done when: Tracked examples define local and Docker URIs from atomic variables;
  Compose consumes only the Docker URI variables with no credential or port
  constants; equivalent local literals are migrated to reference expressions;
  positive, negative, Compose, and package checks pass.

## Delivered Result

- Summary: Defined both direct and Docker-specific MongoDB/MySQL URIs as
  reference expressions over the same atomic credentials, ports, and database
  name, then reduced Compose to direct Docker-URI injection.
- Changed behavior: Compose no longer reconstructs connection strings with
  duplicated usernames, weak password defaults, ports, or database names. API
  start requires the selected Docker URI to be present and validates referenced
  atomic credentials; image build continues to allow empty or placeholder
  values. Direct runtime uses `localhost`, while container runtime uses
  `host.docker.internal`.
- Compatibility: All four current local environment files had URI literals that
  were exactly equivalent to their atomic values, so they were rewritten as
  references without changing their evaluated connection strings. Non-empty,
  non-equivalent custom URI values remain migration-preserved. API, schema,
  persistence, ports, and runtime versions remain unchanged.
- Migration/rollback: Empty Docker URI values were upgraded to derived
  expressions. Equivalent direct URI literals were normalized to the tracked
  expressions. Rollback restores Compose fallback construction and the previous
  local text without requiring data or schema changes.
- Implementation refs: `cashlenx-server` commit `43143b9`.

## Validation

- Commands and results: Every lifecycle script and the dependency lifecycle
  smoke passed `bash -n`; `test/scripts/dependency-lifecycle-smoke.sh` passed;
  `go test ./...` passed; all four local Server environment files passed Compose
  rendering; their direct and Docker URI fields were confirmed as reference
  expressions; and each rendered container URI matched the value constructed
  from that file's atomic settings. Server and Spec `git diff --check`, local
  environment synchronization, Spec English checks, and the Server AGENTS
  source-snapshot comparison passed.
- Negative/auth/compatibility evidence when applicable: A scan confirmed
  `docker/service.yml` contains no database username, password, port, database,
  or weak-credential fallback constants. Lifecycle tests proved an empty
  selected Docker URI blocks start by key name but still permits image build.
  Current equivalent literals retained the same evaluated values after
  normalization, and no configured values were printed during migration or
  validation.
- Known limits: Runtime-context hostnames are intentionally separate constants:
  direct execution uses `localhost`, while the API container uses
  `host.docker.internal`. A non-equivalent full URI override remains supported,
  but its operator owns consistency with the atomic keys. Previously reported
  invalid local `TIMEZONE` values remain preserved and continue to block start.
  No container was started or stopped.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
