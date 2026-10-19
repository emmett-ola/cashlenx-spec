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
the complete local orchestration, including explicit candidate inputs, exact packaged Server and App images,
isolated Compose resources, both databases, disposable user/data setup,
cleanup, and checksummed evidence:

```bash
APP_SOURCE=/candidate/app SERVER_SOURCE=/candidate/server \
WEBSITE_SOURCE=/candidate/website CANDIDATE_ARTIFACTS=/candidate/artifacts \
EVIDENCE_ROOT=/candidate/evidence bash scripts/whole-product-acceptance.sh
```

The browser runs inside the App container network namespace and reaches the
built client through loopback, preserving the secure-context requirement of
encrypted Flutter Web session storage without weakening Chromium security.
Acceptance covers real login and first-login setup, remembered-session reload,
stable destinations, seeded transactions, unknown-route recovery, and an
editable Demo journey that is rejected if it calls authenticated APIs. Results
are retained under ignored `.artifacts/browser/<run-id>/`; secrets and test
accounts are not retained.

`test/scripts/budget-acceptance.sh` covers authenticated extended profile and
configuration persistence plus budget CRUD and cash-flow-derived spending for
both disposable database profiles. The PowerShell harness is historical only.

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

The Bash candidate gate runs tagged Go migration integration suites against
isolated MongoDB and MySQL databases. Coverage includes fresh installation,
existing data and the native migration handlers, repeat safety, checksum and
history rejection, and dirty-state blocking/compensation. The integration
MySQL database is separate from the API database.

After recording the Jira blocker scan, run:

```bash
bash scripts/release-gate.sh \
  --affected-components app,server,website \
  --database all \
  --jira-preflight-reference "CLX-104 comment 10323"
```

The gate uses detached clean worktrees and preserves each component's own
version. It packages and replays all three retained compatibility images and
uses the exact image IDs for runtime acceptance. Go/Bun checks and runtime
services use Compose. `whole-product-acceptance.sh` requires explicit candidate
source and artifact paths; it has no owner-workspace or environment fallback.
Every run generates credentials in a private temporary directory and uses a
unique Compose project, network and named volumes. No owner environment file
or persistent database is read or changed.

Both profiles exercise API smoke, budget/profile/configuration compatibility,
the built-client browser journeys, TLS ingress, restart and repeat migration,
dependency failure, named-volume persistence, encrypted repository-owned
backups, corrupt checksum/wrong key rejection, three-tier retention and an
unnetworked disposable restore. The backup adapter permits only inspection
and Compose execution against the selected disposable database. Restore
checks object counts and migration state against the source. Teardown removes
only resources labeled with the run's project and verifies their absence.
Only aggregate browser results are retained; raw browser/session and runtime
output is removed with generated secrets. Runtime uses the test configuration
to allow the release App's loopback HTTP public API configuration; TLS ingress
is checked separately. This validates disposable compatibility, not shared
environment migration or deployment.

Results and hashes are retained under ignored `.artifacts/release-gates/`.
The gate never tags, promotes or deploys. A passing manifest is evidence for
the separate verified fast-forward operation; the historical failed attempt
remains retained in the v1.1.3 reconciliation record.

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
