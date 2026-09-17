# Beta Baseline Readiness

This record preserves the 2026-07-30 readiness audit that preceded the consolidated stable delivery boundary. It is historical backlog evidence, not an active version plan or accepted release evidence.

## Current Boundary

- The audit was performed during pre-baseline `v0.x` development. Its former delivery boundary is now consolidated into Jira `v1.0.0` planning.
- Unfinished app and web surfaces may remain visible when their actions use the existing coming-soon toast and do not claim that the feature is implemented.
- Explicit transaction date-range filtering is not required before the beta baseline.
- Complete statistics and reporting UI is not required before the beta baseline.

## Unresolved Historical Evidence

- [ ] Confirm the develop branches and implementation refs that define the baseline.
- [x] Consolidate the former server `v0.10.0` hardening boundary into the Jira `v1.0.0` delivery record.
- [ ] Record fresh app analyze/tests, server tests, MongoDB smoke, MySQL smoke, and website build evidence when those project areas are included.
- [ ] Promote verified durable facts into `../system/` and retain deferred scope in this backlog.
- [x] Retire the former beta boundary without opening a standalone snapshot; current delivery is controlled in Jira.

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

Do not reopen this audit as an active delivery boundary. Any remaining relevant work must enter Jira through `Intake`, receive an exact Fix Version during triage, and satisfy the current version close gate. Create a repository-local closeout snapshot only when durable evidence explicitly needs to live with the specification.
