# v0.8.5 Timezone Contract

## Status

- Version: `v0.8.5`
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
- Target: One unambiguous application and container timezone contract
- Affected project areas: server, spec
- Resulting runtime/displayed versions: server `0.11.0` (unchanged because this delivery narrows deployment configuration only)

## Task Contract

- Goal: Ensure the single `TIMEZONE` value has the same meaning in the Go
  application and every Compose-managed Server or database container.
- Context: Compose passes `TIMEZONE` through to container `TZ` without timezone
  validation, while the Server runtime also accepted custom `UTC+/-offset`
  values that can have different POSIX container semantics.
- Constraints: Accept `UTC` and unambiguous region-based IANA names, reject
  abbreviations and fixed-offset forms, keep `TIMEZONE` as the only
  operator-facing key, do not expose configured values in validation errors,
  and do not inspect or modify owner-managed environment variants.
- Done when: API, MongoDB, and MySQL start entry points reject unsupported
  timezone forms by key name; API startup also rejects unknown IANA names; the
  Go timezone loader no longer implements custom offsets; positive and negative
  tests pass; current operations facts and the tracked example describe the same
  contract.

## Delivered Result

- Summary: Restricted the shared `TIMEZONE` source to `UTC` or a region-based
  IANA name, added the same format guard to all three start entry points, and
  made API startup verify the selected name through Go's timezone database.
- Changed behavior: Fixed offsets such as `UTC+8`, ambiguous abbreviations such
  as `CST`, and POSIX-sign forms such as `Etc/GMT+8` now stop API, MongoDB, and
  MySQL lifecycle starts before Compose creates the managed service. Unknown
  region-shaped names also stop API startup. Validation reports only the
  `TIMEZONE` key and never echoes its configured value. Non-start Go callers
  safely fall back to UTC after logging the invalid key.
- Compatibility: API, schema, persistence, ports, images, and displayed runtime
  versions remain unchanged. Previously accepted custom offset and ambiguous
  timezone values become invalid configuration.
- Migration/rollback: Operators using an unsupported value must replace it with
  `UTC` or a region-based IANA timezone such as `Asia/Shanghai`. Rollback restores
  the permissive loader and removes lifecycle validation without touching data.
- Implementation refs: `cashlenx-server` commit `d30193b`.

## Validation

- Commands and results: All lifecycle scripts and the focused lifecycle smoke
  passed `bash -n`; `test/scripts/dependency-lifecycle-smoke.sh` passed; focused
  `util` and `cmd/open_cmd` tests passed; `go test ./...` passed; all three
  Compose projects passed `config --quiet`; and an `Asia/Shanghai` override
  rendered as `TZ=Asia/Shanghai` for the API, MongoDB, and MySQL services.
  Server and Spec `git diff --check`, Spec English checks, environment template
  synchronization, and the Server AGENTS source-snapshot comparison passed.
- Negative/auth/compatibility evidence when applicable: Go tests accepted
  `UTC`, `Asia/Shanghai`, and `America/New_York`; rejected `UTC+8`,
  `UTC-5:30`, `GMT+8`, `CST`, `Etc/GMT+8`, and `Mars/Olympus`; and verified the
  fallback path. Fake-Docker lifecycle tests proved every start rejects the
  unsupported syntactic forms before `up` and does not expose configured values.
  Existing `.env` values were preserved, and owner-managed environment variants
  were not inspected or modified.
- Known limits: Dependency start scripts validate the portable region-based
  IANA name shape because Compose itself has no timezone database. Exact name
  existence is enforced by API startup; MongoDB and MySQL images interpret the
  same standard `TZ` value with their bundled timezone data. Civil-time rules
  can differ if those images carry different tzdata releases. No shared
  environment was started or stopped.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
