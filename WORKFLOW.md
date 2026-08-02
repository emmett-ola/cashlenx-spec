# CashLenX Delivery Workflow

This workflow keeps CashLenX specification and delivery work proportionate to risk. The spec workspace may inspect sibling implementation repositories, but app, server, design, and website repositories must remain independently buildable and must not depend on this spec workspace at runtime, build time, or test time.

## Operating Principles

- Evidence before opinion.
- Use the smallest complete and reversible change.
- Keep one authoritative document per fact.
- Match planning, validation, and documentation effort to the risk of the change.
- Keep app, server, website, and design reference boundaries explicit.

## Work Levels

| Level | Typical work | Default authority | Version record |
| --- | --- | --- | --- |
| Lightweight | Documentation correction, focused test, internal refactor, narrow defect fix with no external contract change | AI proceeds autonomously | Not required unless external behavior or a controlled contract changes |
| Standard | Clear reversible product behavior, additive API response, bounded cross-repository feature, release-scope refinement | AI proceeds after recording a concise task contract | Compact version `README.md` is normally sufficient |
| High-impact | Breaking API change, destructive data action, security/privacy boundary, production deployment, release/tag action, major product direction | Human confirms the material decision or operation; AI executes the work | Full version record and triggered evidence |

When levels overlap, use the highest applicable level. Technical difficulty alone does not make work High-impact.

## Required For Every Task

1. State the goal and observable done condition.
2. Inspect relevant evidence and Git status in every repository that may be touched.
3. Identify the authoritative documents and repositories actually affected.
4. Preserve unrelated user work and implement the smallest complete change.
5. Validate in proportion to the behavior and risk changed.
6. Synchronize the canonical `system/` fact when implementation behavior changes.
7. When an implementation `.env.sample` changes, run `cashlenx-spec/scripts/sync-env.sh` for local `.env` structure and preserve every existing configured value unless an explicit migration requires changing it. Do not inspect or synchronize owner-managed `.env.testing` or `.env.production` files without explicit authorization.
8. Commit the completed request or coherent change set by default unless the user explicitly opts out. Implementation commits use an existing `develop` branch by default; spec-only commits use the current spec governance branch. Stage only intended files and keep push, merge, tag, publication, and deployment as separately authorized actions.
9. Recheck repository state and report validation, changed files, known limits, commits, and delivery actions.

Lightweight work does not require a persisted task contract, scenario matrix, or broad implementation build unless its impact triggers one.

## Task Contract

Standard and High-impact work records four fields:

| Field | Content |
| --- | --- |
| Goal | User or business outcome |
| Context | Verified current behavior and evidence |
| Constraints | Scope, compatibility, security, repository, deployment, and non-goals |
| Done when | Observable result and validation evidence |

For Lightweight work, a concise goal and done condition in the task conversation are sufficient.

## Human Decision Gates

Request a Human decision only when one of these remains unresolved:

- Two or more plausible interpretations materially change business behavior or scope.
- A major architecture direction or long-lived external contract is being selected.
- Breaking compatibility, destructive data mutation, irreversible operation, or security/privacy risk must be accepted.
- Production or shared-environment deployment, branch promotion, release/tag action, secret change, or external-system mutation lacks concrete authorization.
- Completion requires expanding beyond the requested outcome or accepting a known High-impact risk.

Human approval covers only the stated decision or operation. Reversible implementation choices, focused tests, documentation synchronization, and repository-local commits inside an approved outcome remain AI responsibilities.

## Enhanced Evidence When Triggered

| Trigger | Additional evidence |
| --- | --- |
| External behavior or cross-repository feature | Goal, context, constraints, done condition, compatibility boundary, and repository rollout order |
| API, schema, permission, workflow, or state change | Positive and negative cases, authority owner, and compatibility or migration behavior |
| Migration or data rewrite | Existing-data behavior, repeat safety, and rollback or forward-fix plan |
| Security, privacy, credential, or file-access change | Threat or abuse cases, sensitive-data handling, authorization, and audit evidence |
| Deployment, release, branch promotion, or shared-environment action | Target, timing, reversibility, compatibility, and explicit Human authorization |
| Major architecture or product direction | Options, trade-offs, recommendation, and recorded Human decision |
| User-facing documentation, marketing, or training claim | Review the derived artifact against current `system/` facts |

## Delivery Flow

1. **Understand:** load governance, inspect relevant facts, and select the work level.
2. **Decide:** choose the smallest safe approach; obtain only triggered Human decisions.
3. **Implement:** work repository by repository and preserve independent build/runtime boundaries.
4. **Validate:** run focused checks first and add only triggered enhanced scenarios.
5. **Close:** synchronize facts, record evidence and deferred work, commit the completed change set by default on the applicable working branch, and perform push, merge, tag, publication, deployment, or other controlled delivery actions only when authorized.

## Release Delivery Convention

- `cashlenx-spec` controls product delivery scope under `versions/`; implementation version advancement follows `decisions/0002-spec-controlled-versioning-with-project-local-advancement.md`.
- Release/tag delivery, publication, and deployment are separate actions and require explicit authorization.
- A closed version records accepted scope and evidence; it does not imply deployment.
- Do not move or recreate an existing release tag. A correction receives a new version and tag.

## Definition Of Done

Every task is done when:

- the requested outcome and done condition are satisfied without unresolved scope deviation;
- relevant validation passes and known limits are explicit;
- current facts are synchronized when behavior changed;
- intended repository changes are identified and unrelated work is preserved;
- workflow state, deployment state, commits, and delivery actions are reported accurately when applicable.

Standard and High-impact work also requires the applicable compatibility, migration, security, operational, and version-close evidence.

## Version And Deployment Semantics

- Version workflow states are `Draft`, `Ready`, `WIP`, `Testing`, `Closed`, and `Cancelled`.
- `Closed` means the stated scope and required evidence are accepted; it does not imply deployment.
- Deployment states are `Not deployed`, `Testing`, `Production`, and `N/A`.
- `system/` describes verified current implementation facts, not production deployment evidence unless a deployment baseline is recorded explicitly.

## Spec-Only Governance Exception

Information architecture, workflow rules, templates, references, and factual documentation may change directly in `cashlenx-spec` without a product version when runtime behavior and controlled contracts do not change. Validate Markdown structure and local links, moved paths, encoding, stale or duplicated policy owners, `git diff --check` when available, source-snapshot integrity when touched, and the unchanged state of implementation repositories.
