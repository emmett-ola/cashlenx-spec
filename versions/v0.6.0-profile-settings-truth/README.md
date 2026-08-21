# v0.6.0 Profile And Settings Truth

## Status

- Version: `v0.6.0`
- State: Ready
- Work Level: Standard
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
- Affected project areas: `cashlenx-spec`, `cashlenx-app`

## Task Contract

- Goal: Align profile/settings presentation while ensuring every editable or
  displayed value truthfully represents persisted or explicitly local state.
- Context: The prototype displays mock phone, location, birth date, and account
  statistics. Flutter currently renders some unsupported fields as editable but
  saves only API-supported nickname/avatar/gender and app-local currency. The
  About panel also hard-codes `1.0.0` while the package is on the `v0.x` line.
- Constraints: Preserve fixed avatar presets, local currency, theme and language
  persistence, API-supported profile fields, and demo isolation. Do not add
  backend fields without a separate contract version.
- Done when: Unsupported fields cannot be mistaken for saved data, settings and
  profile geometry match the live design where truthful, package version/build
  metadata is displayed, and focused tests pass.

## Delivered Result

- Summary: Pending.
- Changed behavior: Pending.
- Compatibility: No API or schema change.
- Migration/rollback: No data migration; revert the app commit.
- Implementation refs: Pending.

## Validation

- Commands and results: Pending.
- Known limits: Backend persistence remains limited to the documented fields.

## Close Gate

- [ ] Done condition satisfied.
- [ ] Relevant validation passed and known limits recorded.
- [ ] Workflow and deployment states recorded.
- [ ] Durable facts synchronized.
- [ ] Implementation refs recorded.
