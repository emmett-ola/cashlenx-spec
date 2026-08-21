# Testing

This document owns current validation commands, evidence boundaries, and testing strategy. Select only the checks triggered by the change through `../WORKFLOW.md` and `quality-attributes.md`.

## Evidence Boundaries

- Unit and widget suites, package builds, live API/database smoke tests, migration checks, container health, and deployment evidence are separate evidence sets.
- A passing repository-local suite does not prove a Docker-backed database flow or deployment state.
- Dated results, implementation refs, and accepted limits belong in the relevant version or readiness record rather than this command catalog.

## Validation Commands

### Spec

From `cashlenx-spec`:

```bash
git diff --check
```

Spec-only work also validates local Markdown links, moved paths, accidental non-English content, duplicated policy owners, and unchanged sibling repositories.

### App

From `../cashlenx-app`:

```bash
flutter analyze
flutter test
```

The legacy Flutter-to-server commands below are intended targets but are not
valid current evidence because `integration_test/api_smoke_test.dart` is absent:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1
```

Use MySQL 8 instead of MongoDB with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1 -Database mysql
```

Restore or replace that harness before relying on it. The current focused live
database evidence is the server-owned disposable flow:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-budget.ps1 -Database mongodb
powershell -ExecutionPolicy Bypass -File scripts/smoke-budget.ps1 -Database mysql
```

It verifies authenticated profile/configuration persistence and budget/ledger
behavior against both databases without retaining test data.

### Server

From `../cashlenx-server`:

```bash
go build -o cashlenx main.go
go test ./...
scripts/ci-test.sh
```

`scripts/ci-test.sh` runs the package suite with the race detector and an atomic coverage profile. CI also builds the server and container image and generates the Swagger UI artifact, but it does not run the live database-backed smoke flow.

Validate numbered MySQL migrations against a disposable MySQL 8 instance on Windows with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-mysql-migrations.ps1
```

## Testing Strategy

- Unit test pure Dart behavior, DTO parsing, repositories with fake data sources, storage policy, and helpers.
- Test app infrastructure contracts for HTTP error mapping, error-message resolution, request tracking, route redirect policy, and persistence adapters.
- Test auth provider states including logged-out startup, remember-me refresh success/failure, login success/failure, logout, password-reset request, and password-reset confirm.
- Keep widget tests behind fake repositories or data sources and independent of a live API server.
- Keep committed golden baselines for the 390 px phone, 430 px maximum shell,
  and 768 px host classes. Generate intentionally with `--update-goldens`, then
  run the same test without that flag before accepting changes.
- Keep server unit tests deterministic and free of real database, filesystem, and email-provider mutations. Prefer constructor-injected services and in-memory mapper or side-effect fakes.
- Keep mapper and database tests separate from normal unit tests through explicit integration naming, build tags, or scripts, and point them only at disposable databases.
- Live integration coverage should include registration, login, refresh, logout, profile, cash flow, category, statistics, XLSX import, CSV/XLSX export, backup, password reset, and admin APIs.
