# Versions

This directory stores CashLenX delivery history and active delivery control for Standard and High-impact work. Use it for concrete version scopes, task contracts, validation evidence, implementation refs, release notes, and known limits.

Current behavior belongs in `../system/`. A closed version is evidence, not the current source of truth.

## Current Planning Position

- Current spec state: pre-baseline. A formal baseline will be created later after the beta readiness boundary is clearer.
- Current implementation line: active `v0.x` development preparing for beta.
- Server position: `v0.9.0` implementation and local verification are complete; `v0.10.0` cloud and self-hosted hardening is the active server milestone.
- App position: core authenticated finance flows are implemented; budget mutation, explicit transaction date-range filtering, complete statistics/reporting UI, and some auth unit coverage remain open.
- Beta boundary: unfinished app/web surfaces may remain visible when their actions use the existing coming-soon toast and do not claim that the feature is implemented.
- Deployment position: the current app/server flow has been deployed to a UAT environment and manually confirmed working by the project owner. This is testing deployment evidence, not production evidence.
- Stable release position: `v1.0.0` remains future stable-release readiness, not the current beta baseline.

## Version Plan

| Version area | State | Purpose | Notes |
| --- | --- | --- | --- |
| Beta baseline | Not opened | Record the first coherent app/server/spec beta baseline once develop readiness is confirmed. | Do not create a baseline directory until the boundary is selected. |
| `v0.10.0` server hardening | Planned outside spec version record | Cloud and self-hosted hardening, production CORS/rate-limit/secrets/operational endpoint defaults, and shared-cache decision only if multi-instance deployment is adopted. | Track implementation details in server roadmap until a cross-repository spec version is needed. |
| `v1.0.0` stable readiness | Future | Stable API policy, release pipeline, changelog/version sync, final core workflow readiness, and stable documentation. | Keep `/api/v0` during active `v0.x` development; stable docs point to `/api/v1` only after implemented. |
| Post-stable maintenance | Future | Low-risk polish and coverage after stable release. | Open only when selected. |
| Larger finance/platform features | Future | Budget workflow, broader reporting, and platform/deployment expansion. | Keep deferred until product scope and backend support are confirmed. |

## Before Opening The Beta Baseline

- [x] Confirm the beta boundary permits unfinished app/web surfaces to remain visible with the existing coming-soon toast.
- [x] Confirm explicit transaction date-range filtering is not required before the beta baseline.
- [x] Confirm complete statistics/reporting UI is not required before the beta baseline.
- [ ] Confirm the develop branches and implementation refs that define the baseline.
- [ ] Confirm server `v0.10.0` hardening is explicitly outside the beta baseline.
- [ ] Record validation evidence for app analyze/tests, server tests, MongoDB smoke flow, MySQL smoke flow, and website build if included.
- [ ] Promote durable facts into `system/` and keep deferred scope in `backlog/`.

## Latest Beta Readiness Audit

Audit date: `2026-07-30`.

- Candidate app baseline: branch `develop`, commit `cad7da0` (`chore: consolidate environment ignores`).
- Candidate server baseline: branch `dev/v0.9.0`, commit `5a08082` (`ops: separate database dependency projects`).
- Candidate website baseline: branch `main`, commit `4afa590` (`chore: consolidate environment ignores`).
- The server production image builds successfully with the repository-owned Go 1.23 Docker toolchain.
- The app's prior 158-file line-ending-only delta was reverted before the deployment-script change was committed.
- App analyze/tests were not rerun because Flutter is unavailable in the current Linux environment.
- Server tests were not rerun because the host has Go 1.18.1 and the sandbox did not permit the required Docker test process. The containerized production build passed.
- The website build was not rerun because its installed dependencies contain Windows/Bun executable shims rather than Linux command shims.
- The project owner reported that the app/server flow is deployed to UAT and works there. Exact deployment refs and automated validation output have not yet been recorded.
- The independent local MongoDB Compose project was recreated from an empty Docker state on `2026-07-30`; it reached healthy status and passed an authenticated `ping` through `mongosh`. MySQL remained stopped.

This audit does not open or approve a beta baseline. The product boundary and fresh validation evidence are still required by the checklist above.

## Version Bucket Policy

- `v0.x`: beta and pre-stable development. Keep `/api/v0` unless a specific version opens a compatibility boundary.
- `v1.0.0`: stable release gate. Include only work required for a credible first formal application release.
- `v1.0.x`: small low-risk improvements after stable release.
- `v1.x.0`: larger features, architecture changes, deployment model changes, or platform capabilities.
- Lightweight work normally has no version directory. Keep its goal, result, validation, and repository state in task and commit evidence.
- Standard work normally uses a compact version record. Add detailed evidence files only when the compact record cannot express the decision safely.
- High-impact work uses the full template and triggered evidence from `../WORKFLOW.md`.

## Implementation Version Policy

- `cashlenx-spec` controls product delivery versions and defines the version scope.
- Website, app, and backend all advance to `v1.0.0` for the first stable release.
- After `v1.0.0`, only project areas affected by a delivery advance their runtime/displayed version.
- Example: if `v1.0.1` changes only backend behavior, backend advances to `v1.0.1` while app remains at `v1.0.0`.
- Example: if `v1.0.3` changes only app behavior, app advances to `v1.0.3` while backend remains at its last affected version until a later backend-impacting delivery.
- Release/tag delivery, publication, and deployment are separate actions and require explicit authorization.
- Workflow state is separate from deployment state.

## State Semantics

- Workflow states: `Draft`, `Ready`, `WIP`, `Testing`, `Closed`, and `Cancelled`.
- Deployment states: `Not deployed`, `Testing`, `Production`, and `N/A`.
- `Closed` means the stated scope and required evidence are accepted; it does not imply deployment.
- Do not close a version merely because code exists.
- Do not keep a version open merely because deployment has not occurred.

## Template

Use `_template/` when opening a new version directory.

Recommended files:

- `README.md`
- `requirement.md` for High-impact scope and decisions.
- `developing.md` for High-impact rollout, compatibility, migration, or recovery notes.
- `testing.md` for detailed validation evidence.

## Workflow

1. Create `versions/vX.Y.Z-short-name/`.
2. Classify the work level through `../WORKFLOW.md`.
3. Fill in the compact `README.md`; add optional High-impact files only when triggered.
4. Implement in the affected sibling repositories.
5. Validate touched repositories in proportion to triggered risk.
6. Move durable behavior into `system/` before closing the version.
7. Move deferred or rejected items to `backlog/`.
8. Add ADRs under `decisions/` only for durable product or architecture decisions.

`system/` remains the current source of truth after a version closes.

## Version Close Gate

- Done condition satisfied.
- Relevant validation passed and known limits recorded.
- Workflow state and deployment state recorded separately.
- Durable facts updated in the canonical `system/` document.
- Deferred work moved to `backlog/` or retained as an explicit open question.
- Repository state and compatibility with untouched clients/repositories checked.
- Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- Human decision recorded only when a Human gate was triggered.
