# v0.8.6 Configurable Persistence Storage

## Status

- Version: `v0.8.6`
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
- Target: Configurable MongoDB and MySQL persistent storage sources
- Affected project areas: server, spec
- Resulting runtime/displayed versions: server `0.11.0` (unchanged because this delivery changes deployment configuration only)

## Task Contract

- Goal: Restore operator control over MongoDB and MySQL persistent storage
  locations without changing or deleting the existing named-volume defaults.
- Context: Dependency isolation replaced legacy host-path mounts with fixed named
  volumes, leaving `MONGO_DATA_PATH` and `MYSQL_DATA_PATH` present only as
  unconsumed local legacy settings.
- Constraints: Preserve the existing `cashlenx-mongodb-data` and
  `cashlenx-mysql-data` volume defaults, accept explicit absolute host bind
  paths, keep stop operations persistence-safe, preserve current local values,
  do not migrate or delete data, and do not start shared containers.
- Done when: Both dependency Compose projects render their existing named volume
  by default and an absolute bind mount when its data path is configured; start
  validation rejects unsafe or relative paths by key name; local environment
  files adopt the new structure without losing values; documentation and
  validation evidence describe the no-migration boundary.

## Delivered Result

- Summary: Connected `MONGO_DATA_PATH` and `MYSQL_DATA_PATH` to their dependency
  mounts, added configurable named-volume identities, and kept the existing
  named volumes as the empty-path defaults.
- Changed behavior: An empty data path uses `MONGO_DATA_VOLUME_NAME` or
  `MYSQL_DATA_VOLUME_NAME`; an absolute Unix, UNC, or Windows host path renders
  as a bind mount. Dependency start rejects relative paths, filesystem roots,
  parent traversal, and invalid volume names by key name. Stop continues to run
  Compose `down` without volume removal and never removes bind-path content.
- Compatibility: The default named volumes remain `cashlenx-mongodb-data` and
  `cashlenx-mysql-data`; API, schema, ports, container/project names, and runtime
  versions remain unchanged. Existing `.env` and `.env.local` absolute path
  values are now active instead of ignored legacy assignments. Production and
  testing files had no data paths and therefore retain the named-volume mode.
- Migration/rollback: No data is copied, rewritten, or deleted. Switching the
  source can make records in the previous source temporarily unavailable until
  the operator switches back or performs a reviewed database-native migration.
  Rollback restores the fixed Compose mounts and leaves all named volumes and
  host directories untouched.
- Implementation refs: `cashlenx-server` commit `0333fcb`.

## Validation

- Commands and results: Every Server lifecycle script and the dependency smoke
  passed `bash -n`; `test/scripts/dependency-lifecycle-smoke.sh` passed;
  `go test ./...` passed; MongoDB and MySQL Compose catalogs passed with the
  tracked example and all four local Server environment files; default named
  volumes, custom volume identities, Unix bind paths, and Windows bind paths
  rendered or passed lifecycle validation as expected. Server and Spec
  `git diff --check`, local environment structure/ignore checks, environment
  synchronization, Spec English checks, and the Server AGENTS source-snapshot
  comparison passed.
- Negative/auth/compatibility evidence when applicable: Dependency starts
  rejected relative paths, filesystem roots, and invalid volume names before
  Docker `up`, reporting only the relevant key. The example retained the exact
  previous named-volume identities. Local `.env` and `.env.local` rendered both
  database mounts as bind sources; `.env.production` and `.env.testing` rendered
  both as named volumes. Existing local keys and values were preserved while
  the new keys were placed into the current example structure.
- Known limits: Selecting a new path or volume is not a data migration. The
  operator must verify ownership, permissions, capacity, backup, and any
  required data copy for that host location. The previously reported invalid
  local `TIMEZONE` values remain preserved and continue to block start until the
  operator selects region-based IANA values. No container was started or
  stopped.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
