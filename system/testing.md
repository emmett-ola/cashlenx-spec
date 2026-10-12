# Testing

## Environment profile synchronization

The Spec-owned disposable smoke suite verifies named-profile creation,
value-preserving missing-key synchronization, repeat safety, read-only checks,
duplicate rejection, invalid-profile rejection, and output redaction:

```bash
bash test/scripts/env-profile-sync-smoke.sh
```

The suite builds an isolated three-repository fixture and never reads or changes
owner-managed `.env.testing` or `.env.production` files.

The coordination suite verifies all three named profiles, MongoDB/MySQL
selection, delegated phase order, health gating, reverse stop order,
pre-existing resource preservation, partial-start rollback, mismatch failures,
post-start health-gate rollback, degraded pre-existing resource refusal,
container/project identity collisions, and value-redacted diagnostics:

```bash
bash test/scripts/environment-lifecycle-smoke.sh
```

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

The retained PowerShell candidate-deployment smoke harness is legacy evidence,
not an active validation entry point. A runtime-deployment change must first
port its idempotency, rollback, partial-start recovery, tamper rejection,
revision, public-configuration, and missing-image scenarios to Bash.

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

The App owns a containerized Playwright journey gate. The specification owns
the complete local orchestration, including safe local environment
configuration, exact current-source Server and App image builds, an isolated
built App container, the selected database, disposable user/data setup,
cleanup, and checksummed evidence:

```bash
bash scripts/whole-product-acceptance.sh
```

The browser runs inside the App container network namespace and reaches the
built client through loopback, preserving the secure-context requirement of
encrypted Flutter Web session storage without weakening Chromium security.
Acceptance covers real login and first-login setup, remembered-session reload,
stable destinations, seeded transactions, unknown-route recovery, and an
editable Demo journey that is rejected if it calls authenticated APIs. Results
are retained under ignored `.artifacts/browser/<run-id>/`; secrets and test
accounts are not retained.

The former PowerShell budget smoke harness is retained only as historical
evidence. Before a Server or persistence release depends on those scenarios,
port the authenticated profile/configuration and budget/ledger matrix for
MongoDB and MySQL to Bash.

### Build toolchain convergence

CI and container builds must report Flutter 3.47.5 / Dart 3.13.4, Go 1.27.1,
and Bun 1.4.2 respectively. Every normal CI workflow validates its deployable
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
and nerdctl command contracts. A real nerdctl installation is not part of local
or release acceptance. Disposable real-Docker acceptance is the sole
production-like execution path: it starts App, API, Website, MongoDB, and MySQL,
verifies effective image identity, observes a paused service and a stopped
selected dependency without restarts, and confirms graceful and timeout-forced
termination behavior.

The MySQL migration, MongoDB migration, and dual-database data-protection
PowerShell harnesses are retained as historical evidence only. A Server release
with no database or persistence-boundary change may use `--database unchanged`;
the Bash gate compares `origin/main` to the candidate and rejects the scope when
a database-sensitive path changed. Any release that changes those boundaries
must first provide Bash replacements with the same fresh, upgrade, repeat,
checksum, dirty-state, encrypted-backup, corrupt-input, retention, restore,
recovery, generated-secret, isolation, and teardown coverage.

After the Jira preflight has been recorded, run the complete release gate with:

```bash
bash scripts/release-gate.sh \
  --affected-components app \
  --database unchanged \
  --jira-preflight-reference "CLV-15 comment 10250"
```

The gate uses real Docker for local execution and aggregates affected-repository
static and unit checks, reproducible candidate evidence, retained-contract
compatibility, and the built-client browser journey into one checksummed
manifest under ignored
`.artifacts/release-gates/` storage. Repository checks run from detached clean
worktrees, so owner-managed local environment files are absent rather than
merely hidden by a command-line option. The gate does not tag, publish, promote,
deploy, or mutate persistent product data.

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
