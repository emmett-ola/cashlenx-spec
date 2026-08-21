# v0.6.0 Profile And Settings Truth

## Status

- Version: `v0.6.0`
- State: Ready
- Work Level: High-impact
- Execution Owner: AI
- Validation Owner: AI
- Validated At: Pending
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: Pending closure of `v0.5.0`
- Target: Complete before `v0.7.0`
- Affected project areas: `cashlenx-spec`, `cashlenx-app`, `cashlenx-server`

## Task Contract

- Goal: Align profile/settings presentation while ensuring every editable or
  displayed value truthfully represents persisted or explicitly local state.
- Context: The prototype displays mock phone, location, birth date, and account
  statistics. Flutter currently renders some unsupported fields as editable but
  saves only API-supported nickname/avatar/gender and app-local currency. The
  About panel also hard-codes `1.0.0` while the package is on the `v0.x` line.
- Constraints: Preserve fixed avatar presets and demo isolation. Reconcile
  offline/local currency, theme, and language with the existing server
  configuration contract. New optional profile fields require versioned API,
  OpenAPI/CLI, MongoDB, MySQL, authorization, and compatibility evidence.
- Done when: Every editable profile/settings value persists through its truthful
  real or demo data source, settings and profile geometry match the live design,
  package version/build metadata is displayed, and focused tests pass.

## Delivered Result

- Summary: Pending.
- Changed behavior: Pending.
- Compatibility: Additive optional profile fields and configuration integration;
  existing clients remain valid.
- Migration/rollback: Pending additive schema and app rollback evidence.
- Implementation refs: Pending.

## Validation

- Commands and results: Pending.
- Known limits: Pending implementation and triggered migration/security evidence.

## Close Gate

- [ ] Done condition satisfied.
- [ ] Relevant validation passed and known limits recorded.
- [ ] Workflow and deployment states recorded.
- [ ] Durable facts synchronized.
- [ ] Implementation refs recorded.
