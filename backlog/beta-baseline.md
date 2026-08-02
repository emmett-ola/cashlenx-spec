# Beta Baseline Readiness

This record owns readiness work for the first coherent CashLenX beta baseline while no delivery version has been opened. It is a backlog candidate, not accepted version evidence.

## Current Boundary

- The spec remains pre-baseline during active `v0.x` development.
- Unfinished app and web surfaces may remain visible when their actions use the existing coming-soon toast and do not claim that the feature is implemented.
- Explicit transaction date-range filtering is not required before the beta baseline.
- Complete statistics and reporting UI is not required before the beta baseline.

## Open Gates

- [ ] Confirm the develop branches and implementation refs that define the baseline.
- [ ] Confirm server `v0.10.0` hardening is explicitly outside the beta baseline.
- [ ] Record fresh app analyze/tests, server tests, MongoDB smoke, MySQL smoke, and website build evidence when those project areas are included.
- [ ] Promote verified durable facts into `../system/` and retain deferred scope in this backlog.
- [ ] Open a concrete directory under `../versions/` only after the baseline boundary and affected project areas are selected.

## Latest Readiness Audit

Audit date: `2026-07-30`.

- Candidate app baseline: branch `develop`, commit `cad7da0` (`chore: consolidate environment ignores`).
- Candidate server baseline: branch `dev/v0.9.0`, commit `5a08082` (`ops: separate database dependency projects`).
- Candidate website baseline: branch `main`, commit `4afa590` (`chore: consolidate environment ignores`).
- The server production image built successfully with the repository-owned Go 1.23 Docker toolchain.
- The app's prior 158-file line-ending-only delta was reverted before the deployment-script change was committed.
- App analyze/tests were not rerun because Flutter was unavailable in the audit environment.
- Server tests were not rerun because the audit host had Go 1.18.1 and could not run the required Docker test process. The containerized production build passed.
- The website build was not rerun because its installed dependencies contained Windows/Bun executable shims rather than Linux command shims.
- The project owner reported that the app/server flow was deployed to UAT and worked there. Exact deployment refs and automated validation output were not recorded.
- The independent local MongoDB Compose project was recreated from an empty Docker state, reached healthy status, and passed an authenticated `ping` through `mongosh`. MySQL remained stopped.

This audit does not approve a baseline and does not establish current deployment state. Revalidate candidate refs and triggered gates before opening or closing a beta version.

## Promotion Rule

When the beta boundary becomes concrete, create `../versions/vX.Y.Z-short-name/`, move the accepted task contract and fresh delivery evidence there, and leave only still-deferred work in `backlog/`. Do not use this readiness record as a substitute for a version close gate.
