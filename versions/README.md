# Versions

This directory stores active delivery control and historical evidence for Standard and High-impact CashLenX work. A version record owns a concrete delivery boundary, task contract, validation, implementation refs, release notes, and accepted limits.

Current behavior belongs in `../system/`. Deferred candidates belong in `../backlog/`. A closed version is delivery evidence, not the current source of truth.

## Current State

- The spec is pre-baseline and the online-design parity series is active.
- `v0.2.0` through `v0.5.0` are closed. The current Ready delivery boundary is
  `v0.6.0-profile-settings-truth`.
- `v0.6.0` has a concrete Ready boundary and must be
  implemented in order. `v0.7.0` is the final acceptance boundary and remains
  Draft until the preceding versions close.
- Readiness for the first beta baseline is tracked in `../backlog/beta-baseline.md` until its boundary and implementation refs are selected.
- Active implementation remains on the `v0.x` line and the current API path remains `/api/v0`.
- Stable-release decisions are recorded in `../decisions/0001-stable-release-api-auth-and-capability-policy.md` and `../decisions/0002-spec-controlled-versioning-with-project-local-advancement.md`.

Do not create a version directory merely to hold planning ideas or an audit without a selected delivery boundary.

## Active Online-Design Parity Series

The series uses the live Figma Make file as the visual reference and treats the
local React/Vite export as a validated cache only when its relevant files match
the online source.

| Order | Version | State | Delivery boundary |
| --- | --- | --- | --- |
| 1 | `v0.2.0-online-design-foundation` | Closed | Online-source authority, Flutter design tokens, shared control geometry, and consistent cash-flow semantics. |
| 2 | `v0.3.0-entry-flow-parity` | Closed | Splash, onboarding, authentication, and currency/setup visual parity while retaining real app behavior. |
| 3 | `v0.4.0-transaction-discovery-parity` | Closed | Date-range filtering, active filter chips, result summary, empty-state recovery, and focused tests. |
| 4 | `v0.5.0-finance-shell-boundaries` | Closed | Split high-change finance surfaces by feature, integrate reporting APIs, and deliver user-scoped budget workflows. |
| 5 | `v0.6.0-profile-settings-truth` | Ready | Profile/settings parity without pretending unsupported fields or prototype statistics are persisted. |
| 6 | `v0.7.0-design-parity-acceptance` | Draft | Multi-viewport visual acceptance, regression closeout, durable fact synchronization, and residual-gap disposition. |

Implement and close one version before starting the next. Each app-affecting
version advances the app's `pubspec.yaml` version and records its repository
commit independently from the spec commit.

## Record Selection

| Work level | Required record |
| --- | --- |
| Lightweight | No version by default. Keep goal, result, validation, and repository state in task and commit evidence. |
| Standard | Compact `README.md` with task contract, result, compatibility, validation, states, implementation refs, and known limits. |
| High-impact | Full template with only the requirement, migration, security, compatibility, recovery, rollout, and scenario evidence triggered by the work. |

Promote Lightweight work to Standard when it changes external behavior or a controlled API, schema, auth, workflow, state, compatibility, migration, or deployment boundary. Promote Standard work to High-impact when a Human gate or substantial migration, security, recovery, or rollout plan is required.

## Version Naming And Buckets

Open concrete work as `vX.Y.Z-short-name/`.

- `v0.x`: beta and pre-stable development. Keep `/api/v0` unless a specific version opens a compatibility boundary.
- `v1.0.0`: first stable release gate.
- `v1.0.x`: small low-risk improvements after stable release.
- `v1.x.0`: larger features, architecture changes, deployment-model changes, or platform capabilities.

Version numbers express product delivery scope. They do not imply deployment, publication, branch promotion, or release tags.

## Implementation Version Policy

The durable policy is owned by `../decisions/0002-spec-controlled-versioning-with-project-local-advancement.md`. Apply it directly rather than restating it in each version record. Every record identifies affected project areas, their resulting runtime or displayed versions, and any separately authorized release, tag, publication, or deployment action under `../WORKFLOW.md`.

## State Semantics

Workflow states:

- `Draft`: boundary or task contract is still being formed.
- `Ready`: scope and required decisions are sufficient to start implementation.
- `WIP`: implementation or documentation synchronization is in progress.
- `Testing`: scoped implementation is complete and acceptance evidence is being collected.
- `Closed`: done condition and triggered evidence are accepted.
- `Cancelled`: the version will not continue; retained decisions or deferred work have been moved to their canonical owners.

Deployment states are `Not deployed`, `Testing`, `Production`, and `N/A`.

`Closed` does not imply deployment. Do not close a version merely because code exists, and do not keep a version open merely because deployment has not occurred.

## Template

Use `_template/` when opening a version:

- `README.md`: required compact task contract, delivery result, validation, states, refs, and close gate.
- `requirement.md`: optional High-impact scope, evidence, and material decisions.
- `developing.md`: optional High-impact implementation, migration, recovery, compatibility, or rollout detail.
- `testing.md`: optional detailed scenario evidence when it does not fit the compact record.

Do not add optional files with empty placeholders. Create only the evidence areas triggered by the work.

## Delivery Record Workflow

1. Classify the work through `../WORKFLOW.md`.
2. Create `versions/vX.Y.Z-short-name/` only after the delivery boundary is concrete.
3. Fill in the compact `README.md`; add optional files only when triggered.
4. Implement repository by repository while preserving independent build and runtime boundaries.
5. Validate touched repositories in proportion to changed behavior and risk.
6. Promote durable behavior into `../system/` before closing.
7. Move deferred or rejected ideas into `../backlog/`.
8. Add an ADR under `../decisions/` only when a choice should remain discoverable after the version closes.

## Version Close Gate

### Required

- The scoped done condition is satisfied.
- Relevant validation passes and known limits are explicit.
- Workflow state, deployment state, validation owner/date, and implementation refs are recorded.
- Durable current facts are updated in the canonical `system/` document.
- Deferred work is moved to `backlog/` or retained as an explicit open question.
- Repository state and compatibility with untouched clients or repositories are checked.

### Enhanced When Triggered

- API, schema, auth, workflow, or state changes include positive and negative contract evidence.
- Migrations or data rewrites include existing-data behavior, repeat safety, and recovery evidence.
- Security, privacy, credential, or file changes include authorization and sensitive-data evidence.
- Deployment evidence records target, timing, reversibility, compatibility, and authorization.
- A Human decision and approver/date are recorded only when a Human gate was triggered.

After closeout, `system/` is authoritative and the version remains historical evidence.
