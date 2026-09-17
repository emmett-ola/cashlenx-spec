# Versions

This directory preserves completed repository-local delivery evidence and provides templates for explicit closeout snapshots. Jira Product Discovery project `CLV` owns the authoritative exact-version catalog; Jira project `CLX` owns task contracts, validation summaries, implementation refs, and delivery state.

Current behavior belongs in `../system/`. Deferred candidates belong in `../backlog/`. A closed version is delivery evidence, not the current source of truth.

## Current State

- The spec is pre-baseline and the online-design parity series is active.
- `v0.2.0` through `v0.8.0` are closed. The online-design parity series and the
  deployment-script lifecycle consolidation are complete.
- `v0.8.1-env-example-and-selection` is closed.
- `v0.8.2-env-example-guidance` is closed with accepted formats, units, and
  operational meaning documented in every tracked environment example.
- `v0.8.3-dependency-lifecycle-and-env-reuse` is closed with isolated database
  lifecycle entry points and single-definition database configuration values.
- `v0.8.4-explicit-env-controls` is closed with active assignments, explicit
  capability switches, and one application/container timezone key.
- `v0.8.5-timezone-contract` is closed with a shared unambiguous timezone format
  contract for the Server application and containers.
- `v0.8.6-configurable-persistence-storage` is closed with configurable database
  named-volume identities and absolute host bind paths.
- `v0.8.7-derived-database-uris` is closed with database URI values derived from
  one set of atomic credentials, ports, and database names.
- `v0.8.8-runtime-image-package-independence` is closed with an APK-independent
  Server image build and retained health/timezone behavior.
- `v0.8.9-shared-docker-network-and-layout` is closed with one external network
  shared by application and dependency containers and a project-local Docker
  definition layout.
- The former beta and `v0.10.0` planning boundaries are consolidated into the first stable `v1.0.0` delivery record. `../backlog/beta-baseline.md` remains historical readiness evidence rather than an active version plan.
- Product implementation remains pre-release while the accepted stable contract is now canonical at `/api/v1`; `/api/v0` remains a frozen previous-client alias.
- Stable-release and delivery-workflow decisions are recorded in `../decisions/0001-stable-release-api-auth-and-capability-policy.md`, `../decisions/0002-jira-controlled-delivery-with-project-local-advancement.md`, and `../decisions/0004-agent-led-jira-intake-and-version-archives.md`.
- [CLV-7](https://macacloud.atlassian.net/browse/CLV-7) is the authoritative
  `v1.0.0` version record. It remains visible on the Roadmap because the
  accepted candidate is release-ready but has not been tagged, published,
  promoted, deployed, migrated, or accepted in production.
- [CLV-8](https://macacloud.atlassian.net/browse/CLV-8) is the authoritative
  `v1.0.1` version record for compatible follow-up maintenance.
- CLX items use matching `version-v1-0-0` or `version-v1-0-1` labels and
  Product Discovery delivery links. CLV owns version identity; labels support
  queries and do not form a second authority.

Do not create a version directory for active planning, routine Jira work, or an audit. Create a repository-local snapshot only when durable closeout evidence explicitly needs to live with the specification.

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
| 5 | `v0.6.0-profile-settings-truth` | Closed | Profile/settings parity without pretending unsupported fields or prototype statistics are persisted. |
| 6 | `v0.7.0-design-parity-acceptance` | Closed | Multi-viewport visual acceptance, regression closeout, durable fact synchronization, and residual-gap disposition. |

## Subsequent Delivery Boundaries

| Version | State | Delivery boundary |
| --- | --- | --- |
| `v0.8.0-deployment-script-lifecycle` | Closed | Uniform image build, health-gated image start, and persistence-safe project stop entry points. |
| `v0.8.1-env-example-and-selection` | Closed | Tracked environment example convention and repository-local lifecycle selection. |
| `v0.8.2-env-example-guidance` | Closed | In-template guidance for environment value formats, units, constraints, and operational meaning. |
| `v0.8.3-dependency-lifecycle-and-env-reuse` | Closed | Explicit MongoDB/MySQL lifecycle scripts and single-definition database environment values. |
| `v0.8.4-explicit-env-controls` | Closed | Active environment assignments, enable-aware validation, and one application/container timezone source. |
| `v0.8.5-timezone-contract` | Closed | UTC or region-based IANA timezone validation shared by the Server application and containers. |
| `v0.8.6-configurable-persistence-storage` | Closed | Configurable MongoDB/MySQL named volumes and absolute host bind paths with persistence-safe lifecycle behavior. |
| `v0.8.7-derived-database-uris` | Closed | Local and Docker database URIs derived without duplicated credential, port, or database constants. |
| `v0.8.8-runtime-image-package-independence` | Closed | APK-independent Server image build using embedded timezone data and the base image health utility. |
| `v0.8.9-shared-docker-network-and-layout` | Closed | Shared external network lifecycle, container-DNS dependency routes, and Docker definitions under each project's `docker/` tree. |

Use CLV version Ideas, Product Discovery delivery links, and optional CLX workstream items to select and sequence active delivery. Each app-affecting
version advances the app's `pubspec.yaml` version and records its repository
commit independently from the spec commit.

## Record Selection

| Work level | Required active record |
| --- | --- |
| Lightweight | Jira is optional unless the work is already tracked or benefits from shared visibility. |
| Standard | CLX story or task connected to the selected CLV version Idea. |
| High-impact | Jira issue with the task contract, triggered evidence, and recorded Human decision. |

A repository-local closeout snapshot is optional and must not duplicate active Jira state. Promote Lightweight work to Standard when it changes external behavior or a controlled API, schema, auth, workflow, state, compatibility, migration, or deployment boundary. Promote Standard work to High-impact when a Human gate or substantial migration, security, recovery, or rollout plan is required.

## Version Naming And Buckets

Name CLV version Ideas `vX.Y.Z — outcome`. When an explicit repository snapshot is required, use `vX.Y.Z-short-name/`.

- `v0.x`: beta and pre-stable product versions. The accepted stable compatibility boundary has opened at `/api/v1`; `/api/v0` remains a frozen alias while release readiness completes.
- `v1.0.0`: first stable release gate.
- Patch versions: compatible fixes, refactors, internal maintenance, and operational improvements.
- Minor versions: compatible user, product, or platform capabilities.
- Major versions: breaking compatibility or an intentional product or platform reset.

Keep one active release line by default and label its CLX work `release-line-vX-Y` plus exactly one `version-vX-Y-Z`. Closeout of one patch does not archive the whole line. When an exact version closes and the next delivery boundary opens, record final evidence and use CLV's native Idea archive. Completed CLX work remains in place with full history.

Version numbers express product delivery scope. They do not imply deployment, publication, branch promotion, or release tags.

## Implementation Version Policy

The durable policy is owned by `../decisions/0002-jira-controlled-delivery-with-project-local-advancement.md`, `../decisions/0004-agent-led-jira-intake-and-version-archives.md`, and `../decisions/0005-clv-authoritative-version-catalog.md`. Apply it directly rather than restating it in each retained version record. Every CLV version Idea and explicit snapshot identifies affected project areas, their resulting runtime or displayed versions, and any separately authorized release, tag, publication, or deployment action under `../WORKFLOW.md`.

## Retained Record State Semantics

The following states describe records already retained in this directory and do not replace the active Jira workflow:

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

## Optional Snapshot Workflow

1. Classify the work through `../WORKFLOW.md`.
2. Use the selected CLV version Idea and connected CLX work items for active delivery.
3. Implement repository by repository while preserving independent build and runtime boundaries.
4. Validate touched repositories in proportion to changed behavior and risk and record the summary and refs in Jira.
5. Promote durable behavior into `../system/` before closing and archiving the CLV version Idea.
6. Move deferred or rejected ideas into `../backlog/`.
7. Add an ADR under `../decisions/` only when a choice should remain discoverable after the version closes.
8. Create `versions/vX.Y.Z-short-name/` only when an explicit repository-local closeout snapshot is required; include only evidence that must remain with the spec.

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
