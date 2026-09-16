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

Validate candidate deployment, idempotency, rollback, automatic partial-start
recovery, no-database behavior, and fail-before-lifecycle rejection of tampered
artifacts, mutable tags, revision drift, public-configuration mismatch, and
missing rollback images with:

```powershell
pwsh -File scripts/deploy-candidate-smoke.ps1
```

### App

From `../cashlenx-app`:

```bash
flutter analyze
flutter test
test/scripts/container-lifecycle-smoke.sh
```

The repository-local image gate uses the tracked environment example without
reading owner-managed deployment configuration:

```bash
ENV_FILE=.env.example scripts/build.sh
```

The build enforces the Flutter lockfile and automatically checks the resulting
static runtime payload, public build metadata, OCI version/revision labels, and
prohibited file absence.

The app repository currently has no maintained live Flutter-to-server harness.
Restore or replace that coverage before relying on a whole-product database
smoke claim. The current focused live database evidence is the server-owned
disposable flow, run from `../cashlenx-server`:

```powershell
powershell -ExecutionPolicy Bypass -File test/scripts/budget-smoke.ps1 -Database mongodb
powershell -ExecutionPolicy Bypass -File test/scripts/budget-smoke.ps1 -Database mysql
```

It verifies authenticated profile/configuration persistence and budget/ledger
behavior against both databases without retaining test data.

### Build toolchain convergence

CI and container builds must report Flutter 3.44.0 / Dart 3.12.0, Go 1.23.12,
and Bun 1.4.0 respectively. Every normal CI workflow validates its deployable
image through `scripts/build.sh`. Acceptance includes successful clean and
cache-assisted builds plus deliberate wrong-version and lock/module drift
failures. No validation reads Testing or Production environment files.

### Server

From `../cashlenx-server`:

```bash
go build -o cashlenx main.go
go test ./...
go test -v -race -covermode=atomic -coverprofile=coverage.out ./...
test/scripts/dependency-lifecycle-smoke.sh
test/scripts/database-storage-smoke.sh
```

The database storage smoke uses disposable identities to prove the pinned
MongoDB/MySQL images, named-volume initialization, graceful restart persistence,
non-destructive stop, effective image identity, and the host's bind-mount
classification. The fake lifecycle suite supplies deterministic ext4/XFS and
9p/v9fs cases so supported and rejected filesystem classes remain covered on
every host.

Build and inspect the candidate Server image with:

```bash
ENV_FILE=.env.example scripts/build.sh
```

The build automatically checks the executable version/revision output,
OpenAPI and default-category runtime assets, OCI labels, and prohibited file
absence.

CI runs the package suite with the race detector and an atomic coverage profile.
It also builds the server and container image, generates the Swagger UI
artifact, and runs the MongoDB API smoke flow in a separate workflow.
The dependency lifecycle smoke uses fake Docker and nerdctl 2.2 frontends to
validate implementation detection, the `docker`-as-nerdctl wrapper case,
enable-aware credential checks, file boundaries, deterministic configured image
selection, persistence-safe stop calls, and fail-before-mutation behavior
without pulling images or changing containers. It also rejects the unsupported
`config --images` and `up --wait` patterns, covers verbose multi-line nerdctl
version output under strict pipe handling, and verifies that frontend output
cannot echo configured values during start.

The same lifecycle suites validate status, doctor, bounded logs, healthy and
deliberately degraded probes, missing image/network/dependency classification,
graceful and forced stop reporting, and repeated stop behavior for both Docker
and nerdctl command contracts. Disposable real-Docker acceptance additionally
starts App, API, Website, MongoDB, and MySQL, verifies effective image identity,
observes a paused service and a stopped selected dependency without restarts,
and confirms graceful and timeout-forced termination behavior.

Validate numbered MySQL migrations against a disposable MySQL 8 instance on Windows with:

```powershell
powershell -ExecutionPolicy Bypass -File test/scripts/mysql-migrations-smoke.ps1
```

Validate MongoDB fresh, existing-data baseline, repeat, changed-checksum,
reordered, native-handler, and failed/dirty migration behavior against a
disposable MongoDB 7 instance with:

```powershell
powershell -ExecutionPolicy Bypass -File test/scripts/mongodb-migrations-smoke.ps1
```

Validate encrypted database backup, checksum and corrupt-input rejection,
tier retention, disposable restore, and migration-state recovery against both
database profiles with:

```powershell
powershell -ExecutionPolicy Bypass -File test/scripts/data-protection-smoke.ps1 -Database all
```

The smoke test generates its own database data, passphrase, container names,
and ignored backup path. It never reads Testing or Production environment files
and removes its source and restore containers plus temporary artifacts on exit.

Run the complete production-like topology against the MongoDB primary and
MySQL compatibility profiles with:

```powershell
pwsh -File scripts/rehearsal.ps1 -Database all
```

This is release-rehearsal evidence rather than a replacement for repository
unit, static-analysis, or focused integration suites. The generated manifest is
checksummed, contains exact commits and image IDs, and contains no secret values.

### Website

From `../cashlenx-website`:

```bash
bun run build
ENV_FILE=.env.example scripts/build.sh
test/scripts/container-lifecycle-smoke.sh
```

The image build is lockfile-driven and automatically verifies compiled static
content, nginx configuration, public build metadata, OCI version/revision
labels, and prohibited file absence.

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
