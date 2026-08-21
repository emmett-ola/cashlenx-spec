# v0.4.0 Transaction Discovery Parity

## Status

- Version: `v0.4.0`
- State: Closed
- Work Level: Standard
- Execution Owner: AI
- Validation Owner: AI
- Validated At: `2026-08-21`
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: `2026-08-21`
- Target: Complete before `v0.5.0`
- Affected project areas: `cashlenx-spec`, `cashlenx-app`

## Task Contract

- Goal: Complete the live-design transaction discovery and filter feedback
  experience.
- Context: Flutter supports type, category, and search filters but lacks the
  design's date range, active chips, result summary, and filtered-empty recovery.
- Constraints: Preserve API/demo data sources, localized date handling, newest
  first ordering, and transaction detail navigation. Invalid or reversed date
  ranges must not silently produce misleading results.
- Done when: Inclusive date filtering, removable filter chips, localized result
  summary, and clear-filter recovery work at mobile widths with focused positive
  and negative tests.

## Delivered Result

- Summary: Completed transaction discovery parity with inclusive server-backed
  date ranges, active filter feedback, result summaries, and empty-state
  recovery while retaining search.
- Changed behavior: Authenticated date selection calls `/cash/range`; demo mode
  filters its isolated store; type, category, date, and search filters produce
  removable chips and a localized filtered result count; clearing a filtered
  empty state restores the list.
- Compatibility: Additive UI behavior; no API or schema change.
- Migration/rollback: No data migration; revert the app commit.
- Implementation refs: `cashlenx-app` commit `68e17b8` (`feat: complete
  transaction discovery filters`). Runtime/displayed app version: `0.4.0+4`.

## Validation

- Commands and results: `flutter analyze` passed with no issues; focused
  transaction tests passed (5 tests); final `flutter test` passed (37 tests),
  all on `2026-08-21`.
- Known limits: Search remains an accepted product enhancement beyond the live
  prototype. Open-ended ranges use `2000-01-01` and `2100-12-31` as explicit
  transport bounds for the existing two-ended API.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow and deployment states recorded.
- [x] Durable facts synchronized.
- [x] Implementation refs recorded.
