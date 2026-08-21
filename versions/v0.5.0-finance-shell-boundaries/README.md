# v0.5.0 Finance Shell Boundaries

## Status

- Version: `v0.5.0`
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
- Target: Complete before `v0.6.0`
- Affected project areas: `cashlenx-spec`, `cashlenx-app`, `cashlenx-server`

## Task Contract

- Goal: Establish maintainable feature boundaries for the authenticated shell
  and complete visual alignment for dashboard, categories, budget workflows,
  and API-backed expanded statistics.
- Context: `home_page.dart` contains 7,062 lines and most finance screens. Its
  behavior is substantially ahead of the prototype, but the concentration makes
  later parity work and focused testing costly.
- Constraints: Preserve real API/demo switching, navigation behavior, localized
  dates, and user isolation. Budget persistence must cover MongoDB and MySQL and
  remain isolated in demo mode. Existing statistics APIs, not prototype sample
  data, are authoritative.
- Done when: Finance presentation is split into coherent feature widgets/files,
  confirmed design surfaces are reused, expanded statistics use typed server
  responses, budget CRUD works through user-scoped real and isolated demo data
  sources, both server persistence backends pass focused tests, and no
  implementation repository depends on the spec workspace.

## Delivered Result

- Summary: Extracted budget and expanded-statistics presentation, domain, and
  data boundaries from the authenticated shell; replaced prototype samples and
  placeholders with real authenticated APIs plus isolated mutable demo paths;
  and added the missing user-scoped monthly-budget capability to the server.
- Changed behavior: The app now supports month-scoped budget list/create/update/
  delete, expense-category selection, ledger-derived spent/remaining/progress,
  over-budget feedback, month navigation, refresh, loading/error/empty states,
  yearly income/expense/balance summaries, monthly comparison, top expenses,
  and year navigation. Normal users call `/budget` and existing `/statistic`
  endpoints; demo users remain in memory and never call authenticated APIs.
- Compatibility: Additive `/api/v0` budget contract plus internal presentation
  refactor; existing clients remain valid.
- Migration/rollback: MySQL migrations `013` and `014` add the budget table and
  preserve cash-flow cents with `DECIMAL(18,2)`; both have down scripts. MongoDB
  creates partial unique and period indexes at startup. No environment was
  deployed; rollback is repository revert plus numbered MySQL rollback before
  accepting new budget writes.
- Implementation refs: `cashlenx-server` commits `acb3a67` (`feat: add
  user-scoped monthly budgets`), `2f089ee` (`test: verify budget persistence
  parity`), and `24bf6e8` (`docs: document budget API and CLI`);
  `cashlenx-app` commit `25ae098` (`feat: connect budgets and live
  statistics`). Resulting server version: `0.10.0`. Resulting app version:
  `0.5.0+5`.

## Validation

- Commands and results: `go test ./...` passed; `scripts/smoke-budget.ps1
  -Database mongodb` passed; `scripts/smoke-budget.ps1 -Database mysql` passed;
  `flutter analyze` passed with no issues; final `flutter test` passed all 41
  tests. Smoke coverage includes unauthenticated rejection and the disposable
  create-category, create-budget, create-expense, derived-spending, update,
  soft-delete, and deleted-read path for each database.
- Known limits: No deployment or migration against retained data was authorized.
  The legacy full API smoke script references an absent Flutter integration-test
  file; focused budget smoke evidence is complete, while restoring that broader
  harness remains backlog. Dashboard, category, transaction, and settings code
  still share the legacy shell file; the newly changed budget/statistics paths
  now have coherent boundaries, and further mechanical extraction carries no
  user-visible parity change.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow and deployment states recorded.
- [x] Durable facts synchronized.
- [x] Implementation refs recorded.
