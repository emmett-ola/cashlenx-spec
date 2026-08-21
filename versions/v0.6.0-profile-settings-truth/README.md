# v0.6.0 Profile And Settings Truth

## Status

- Version: `v0.6.0`
- State: Closed
- Work Level: High-impact
- Execution Owner: AI
- Validation Owner: AI
- Validated At: `2026-08-21`
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: `2026-08-21`
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

- Summary: Added durable extended profile fields across the API and both
  databases, connected the app's phone/location/birth-date editors, synchronized
  language/currency/theme preferences with the existing user configuration
  contract, and replaced hard-coded About metadata with package metadata.
- Changed behavior: Authenticated users now read and write profile phone,
  location, and ISO birth date through `/user/profile`; configuration is loaded
  from `/user/configuration` at authenticated-shell startup and written after
  settings changes. Local preferences remain the offline fallback. Demo profile
  and configuration changes persist in the isolated session store and reset on
  the next demo session.
- Compatibility: Additive optional profile fields and configuration integration;
  existing clients remain valid.
- Migration/rollback: MySQL migration `015` adds nullable `phone_number`,
  `location`, and `birth_date` columns and includes a down migration. MongoDB
  accepts the additive optional fields without a data rewrite. No environment
  was deployed; rollback is repository revert plus migration `015` rollback
  before depending on new profile writes.
- Implementation refs: `cashlenx-server` commit `8d4d2c9` (`feat: persist
  profile and settings truth`); `cashlenx-app` commit `9d53ab7` (`feat:
  synchronize profile and user settings`). Resulting server version: `0.11.0`.
  Resulting app version: `0.6.0+6`.

## Validation

- Commands and results: `go test ./...` passed; focused disposable MongoDB and
  MySQL smokes passed and each verified authenticated extended-profile update/
  read, configuration update/read, and the existing budget ledger workflow;
  `flutter analyze` passed with no issues; `flutter test` passed all 43 tests.
  Existing controller authorization tests cover rejection of unauthenticated
  user profile and configuration requests.
- Known limits: The profile PATCH-like request still uses non-nullable strings,
  so an empty value means "leave unchanged" rather than an explicit clear;
  nullable clearing semantics are backlog. Offline configuration writes remain
  local and surface the server error, but no durable retry queue exists. No
  retained database was migrated and no deployment was authorized.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow and deployment states recorded.
- [x] Durable facts synchronized.
- [x] Implementation refs recorded.
