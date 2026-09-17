# CashLenX Delivery Workflow

This workflow keeps CashLenX specification and delivery work proportionate to risk. The spec workspace may inspect sibling implementation repositories, but app, server, design, and website repositories must remain independently buildable and must not depend on this spec workspace at runtime, build time, or test time.

## Operating Principles

- Evidence before opinion.
- Use the smallest complete and reversible change.
- Keep one authoritative document per fact.
- Match planning, validation, and documentation effort to the risk of the change.
- Keep app, server, website, and design reference boundaries explicit.

## Branch Model

- The code repositories (`cashlenx-app`, `cashlenx-server`, and `cashlenx-website`) use `develop` as the default development and integration branch.
- The code repositories use `testing` as the shared test and acceptance branch. It receives explicitly selected changes from `develop` and is the only branch name for the test environment; do not retain or create `test`.
- The code repositories use `main` as the production release branch. It receives validated changes from `testing`, except through an explicitly approved production hotfix workflow.
- Normal code promotion flows in one direction: `develop` -> `testing` -> `main`.
- `cashlenx-spec` uses `main` as its only branch; specification commits do not represent an implementation release or deployment.
- Creating commits, reconciling history, or pushing a working branch does not itself authorize implementation promotion or deployment.

## Work Levels

| Level | Typical work | Default authority | Delivery record |
| --- | --- | --- | --- |
| Lightweight | Documentation correction, focused test, internal refactor, narrow defect fix with no external contract change | AI proceeds autonomously | Jira is optional unless the work is already tracked or benefits from shared visibility |
| Standard | Clear reversible product behavior, additive API response, bounded cross-repository feature, release-scope refinement | AI proceeds after recording a concise task contract | CLX story or task connected to the selected CLV version Idea |
| High-impact | Breaking API change, destructive data action, security/privacy boundary, production deployment, release/tag action, major product direction | Human confirms the material decision or operation; AI executes the work | Jira issue with triggered evidence and the recorded Human decision |

When levels overlap, use the highest applicable level. Technical difficulty alone does not make work High-impact.

## Required For Every Task

1. State the goal and observable done condition.
2. Inspect relevant evidence and Git status in every repository that may be touched.
3. Identify the authoritative documents and repositories actually affected.
4. For Standard and High-impact work, use a CLX issue connected to the selected CLV version Idea, apply its `version-vX-Y-Z` label, and keep the task contract current. Before moving it from `Ready` to `In Progress`, run the Jira blocker scan defined below.
5. Preserve unrelated user work and implement the smallest complete change.
6. Validate in proportion to the behavior and risk changed.
7. Synchronize the canonical `system/` fact when implementation behavior changes.
8. When an implementation `.env.example` changes, run `cashlenx-spec/scripts/sync-env.sh` for local `.env` structure and preserve every existing configured value unless an explicit migration requires changing it. Do not inspect or synchronize owner-managed `.env.testing` or `.env.production` files without explicit authorization.
9. Commit the completed request or coherent change set by default unless the user explicitly opts out. Implementation commits use `develop` by default; spec-only commits use the spec repository's sole `main` branch. Stage only intended files and keep implementation promotion to `testing` or `main`, tag creation, publication, and deployment as separately authorized actions.
10. Before moving a Jira item to `Done`, run the blocker scan again. Update the issue with validation, implementation refs, known limits, and accurate delivery, release, and deployment state.
11. Recheck repository state and report validation, changed files, known limits, commits, and delivery actions.

Lightweight work does not require a persisted task contract, scenario matrix, or broad implementation build unless its impact triggers one.

## Task Contract

Standard and High-impact Jira work records four required contract fields:

| Field | Content |
| --- | --- |
| Goal | User or business outcome |
| Context | Verified current behavior and evidence |
| Constraints | Scope, compatibility, security, repository, deployment, and non-goals |
| Done when | Observable result and validation evidence |

For Lightweight work, a concise goal and done condition in the task conversation are sufficient unless a Jira issue already owns the request.

## Jira Intake And Orchestration

The primary board is `CashLenX — Active Delivery`. It uses five states:

| State | Meaning | Exit condition |
| --- | --- | --- |
| `Intake` | Human-authored raw demand or a returned decision answer awaiting agent triage. | Intent is preserved, evidence is inspected, and executable work or a recorded decision is produced. |
| `Ready` | The task contract, authoritative CLV version Idea, exact-version label, priority, size, dependencies, and acceptance criteria are sufficient to start. | The start blocker scan is clear and execution begins. |
| `In Progress` | An agent is implementing, validating, or synchronizing the scoped work. | Acceptance evidence is complete, or a genuinely unresolved Human decision is isolated. |
| `Awaiting Confirmation` | A separate decision task contains a concrete Human question with prepared evidence and a recommendation. | The Human records an answer and returns the decision task to `Intake`. |
| `Done` | Acceptance criteria and required evidence are satisfied and canonical facts are synchronized. | Terminal for the work item; archiving is controlled separately by release line. |

`Intake` and `Ready` use Jira's To Do category. `In Progress` and `Awaiting Confirmation` use the In Progress category. `Done` uses the Done category.

### Rovo Operating Model

The authorized Rovo integration maintains CLX and CLV issues, labels, Product Discovery delivery links, comments, searches, existing transitions, native CLV Idea archival, and Confluence guidance. The physical CLX workflow contains `Intake`, `Ready`, `In Progress`, `Awaiting Confirmation`, and `Done`.

CLV replaces Jira `Fix Version/s` and per-version archive boards as the authoritative version layer. A CLV Idea owns the exact version identity, outcome, roadmap position, lifecycle state, and release evidence. CLX remains the execution layer. Its `version-vX-Y-Z` label is a query and migration aid whose meaning is derived from the linked CLV Idea; it is not a second version authority.

### Triage On Request

When the product owner asks for requirement triage:

1. Read every applicable `Intake` card and preserve its original wording in the issue history or an `Original request` section.
2. Inspect the affected specification, implementation, Jira relationships, and current release boundary.
3. Rewrite or split the request into the smallest independently verifiable tasks. A `size-l` item is normally decomposed before it reaches `Ready`.
4. Give each executable item an outcome, verified context, scope and non-goals, acceptance criteria, validation expectations, dependencies, risks, and documentation or compatibility impact.
5. Connect the item to exactly one planned CLV version Idea and assign its exact-version label, Jira priority, one size label (`size-s`, `size-m`, or `size-l`), the release-line label, and controlled area or concern labels.
6. Use `Highest` for urgent or severe product, security, data, or release risk; `High` for major user impact or work that unlocks the active line; `Medium` for normal planned delivery; and `Low` for non-urgent polish or optional maintenance. Effort changes decomposition, not priority or semantic versioning.
7. Link dependencies. Keep an externally blocked task in `Ready` with `blocked` and without `agent-ready`; otherwise add `agent-ready` and move it to `Ready`.

Keep one active release line by default. The CLV Idea is the exact version authority. `version-v1-0-1` and `release-line-v1-0` labels make CLX work queryable and must match the linked CLV Idea.

### Human Decision Loop

Do not place executable work in `Awaiting Confirmation`. When a material decision cannot be resolved from evidence:

1. Create a separate Task named `Decision: ...`.
2. Put the options, evidence, recommendation, exact requested answer, and blocked transition in its `Human intervention gate` section.
3. Apply `human-decision` and `human-action-required`, remove `agent-ready`, link the decision task as blocking the affected work, and move the decision task to `Awaiting Confirmation`.
4. Leave affected executable work in its truthful state with `blocked` and no `agent-ready` when the decision blocks its next transition.
5. The Human records the answer and moves the decision task to `Intake`.
6. At the next triage, record the decision with decision maker, date, scope, and constraints; update dependent task contracts; remove satisfied blocker labels; move newly executable work to `Ready`; and move the decision task to `Done`.

### Version Selection And Archive

- Patch versions contain compatible fixes, refactors, internal maintenance, and operational improvements.
- Minor versions contain compatible user or platform capabilities.
- Major versions contain breaking compatibility or an intentional product or platform reset.
- A CLV Idea describes the exact version outcome and lifecycle. Workstream epics or tasks in CLX remain optional execution-navigation aids.
- Keep planned and active versions visible on the CLV Roadmap. When a version close gate passes and the next delivery boundary opens, record the final outcome and all separate implementation, release, deployment, migration, and production-acceptance states, then set the CLV Idea's native `Idea archived` field.
- Do not archive CLX executable items merely because their version closes. They remain in `Done` with full history, delivery links, exact-version label, and release-line label; CLV supplies the compact version archive.

## Human Decision Gates

Request a Human decision only when one of these remains unresolved:

- Two or more plausible interpretations materially change business behavior or scope.
- A major architecture direction or long-lived external contract is being selected.
- Breaking compatibility, destructive data mutation, irreversible operation, or security/privacy risk must be accepted.
- Production or shared-environment deployment, branch promotion, release/tag action, secret change, or external-system mutation lacks concrete authorization.
- Completion requires expanding beyond the requested outcome or accepting a known High-impact risk.

Human approval covers only the stated decision or operation. Reversible implementation choices, focused tests, documentation synchronization, and repository-local commits inside an approved outcome remain AI responsibilities.

### Jira Human-Intervention Markers

- `human-decision` identifies a separate decision task that records a Human gate. Keep a prominent `Human intervention gate` section near the top of the description stating the trigger, options, evidence, recommendation, exact input or authorization required, the transition it blocks, and its current state.
- `human-action-required` means a concrete Human response is required now on the decision task. While present, the issue must not carry `agent-ready`, and affected work must not cross the stated blocked transition.
- `blocked` means an unresolved Jira dependency or other external condition prevents the next planned transition. It must not coexist with `agent-ready`. Use the issue link as the authoritative dependency when another Jira item is responsible.
- Remove `human-action-required` promptly after the decision or authorization is recorded. Remove `blocked` from affected work when no unresolved blocking condition remains. Preserve `human-decision` on the completed decision task as classification history.
- Record the decision or authorization in the decision task with the decision, decision maker, date, scope, and any constraints. A conversation-only approval is copied into Jira before dependent work crosses the gate.

### Jira Blocker Scan

Run this scan before moving an item from `Ready` to `In Progress` and before moving it to `Done`:

1. Inspect inward `Blocks` links and confirm every blocking issue has reached the state required by the task contract.
2. Inspect the selected CLV version Idea, relevant CLX release or workstream item, and release line for unresolved prerequisites or a stopped delivery boundary.
3. Inspect `human-decision`, `human-action-required`, `blocked`, and `agent-ready` labels and the `Human intervention gate` section.
4. Check comments and the task contract for an unanswered decision, authorization, acceptance condition, or newly discovered external dependency.
5. If clear, continue and keep labels accurate. If blocked, do not cross the affected transition; add or update a concise `Blocker scan` Jira comment with the scan point, blocker, exact Human action when applicable, and consequence, then alert the user in the active conversation.

Do not request a Human response before it is actionable. Prepare the options, evidence, and recommendation first unless the unresolved input prevents that preparation itself.

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

1. **Understand:** load governance, inspect relevant facts, identify the selected CLV version Idea and release line, and select the work level.
2. **Decide:** create or refine the Jira task contract, isolate any required Human decision, choose the smallest safe approach, and move complete unblocked work to `Ready`.
3. **Implement:** run the start blocker scan, move the Jira item from `Ready` to `In Progress`, work repository by repository, and preserve independent build/runtime boundaries.
4. **Validate:** run focused checks first, add only triggered enhanced scenarios, synchronize affected facts and guidance, and record evidence and implementation refs on the item.
5. **Close:** commit the coherent change set by default, run the completion blocker scan, and move the Jira item to `Done` only when acceptance is satisfied and no closing gate remains. Push, merge, tag, publication, deployment, and other controlled delivery actions occur only when authorized.

## Release Delivery Convention

- Jira Product Discovery project `CLV` controls exact product-version identity and lifecycle; Jira project `CLX` controls executable work. Implementation version advancement follows `decisions/0002-jira-controlled-delivery-with-project-local-advancement.md`.
- Candidate validation, release tags, artifact publication, branch promotion,
  deployment, migration, and production acceptance are separate evidenced
  actions. The accepted v1 charter provides standing authority for routine
  non-destructive delivery after every applicable gate passes; prohibited
  actions still require a new explicit Human decision.
- A completed CLV version Idea records accepted scope and linked evidence; it does not imply deployment.
- Release tags are annotated `vX.Y.Z` identities in affected implementation
  repositories. Create them only for exact accepted commits, never tag the spec
  repository, and never move or recreate an existing tag. A correction receives
  a new semantic version and tag.
- Publish only the prebuilt artifacts and digests recorded by the accepted
  candidate manifest. Do not rebuild between acceptance and publication.

## Release Candidate Gate

Run this gate for every product release candidate. It is the reusable acceptance contract for local execution and future CI/CD; automation may implement it but must not weaken its semantics.

1. **Jira preflight:** run the blocker scan for the selected CLV version Idea and every connected CLX item. Stop on an unresolved dependency, `human-action-required`, incomplete acceptance criterion, or unrecorded required decision.
2. **Source preflight:** record exact repository branches and commits, confirm intended worktrees contain no unrelated change, confirm the candidate ancestry is suitable for any requested fast-forward, and identify every affected project area.
3. **Version contract:** verify the selected product version against each affected runtime/display version, API path, OpenAPI document, image label, artifact name, changelog, and release note. Generated metadata must derive from an authoritative source and must not act as an independent fallback.
4. **Database preflight:** compare the currently delivered database boundary with the candidate, enumerate ordered migrations and recovery requirements, verify migration identity and immutability, and state explicitly when no database change is required. Source delivery never proves that an environment ran a migration.
5. **Repository validation:** run focused checks first, then the required package tests, static analysis, contract tests, builds, and generated-file checks for every affected repository.
6. **Image validation:** build candidate images from controlled contexts, verify required runtime contents and version/revision metadata, and prove that environment files, credentials, Git state, logs, local data, and unrelated outputs are absent.
7. **Production-like rehearsal:** use generated disposable secrets and isolated names to run the selected production topology locally. Do not read `.env.testing` or `.env.production`. Verify ingress, health, restart, graceful shutdown, persistence, backup/restore, failure behavior, and safe teardown.
8. **Whole-product acceptance:** exercise the selected stable user journeys through built client and server artifacts against the primary database profile, then run the required compatibility suite against every supported alternate database.
9. **Evidence manifest:** emit a safe machine-readable record containing the version, commits, image and artifact identities, migration classification, validation results, timestamps, known limits, and requested delivery actions. Do not include secret values.
10. **Delivery authority:** perform only delivery actions covered by recorded standing or per-action authorization. Keep candidate acceptance, tags, artifact publication, branch promotion, runtime deployment, database migration, and production acceptance as separate states.
11. **Post-delivery verification:** verify remote refs and immutable tags, deployed identities when deployment occurred, health and smoke evidence, migration state when applicable, and rollback readiness. Synchronize Jira, canonical facts, and affected Confluence guidance.

The gate fails closed. Do not bypass a failed check, force-push a delivery branch, move an existing release tag, or substitute a build result for runtime, migration, or acceptance evidence.

## Production Promotion Database Preflight

Before promoting an implementation repository to `main` or deploying a candidate that changes Server or persistence behavior:

1. Resolve the exact current delivered commit and requested target commit.
2. Inspect every intervening migration, schema, initialization, backup/restore, and compatibility change.
3. Produce the complete ordered migration and operational instruction list, or state `No database change required`.
4. Classify each action as already evidenced, required before runtime update, required after runtime update, or unverified.
5. Record repeat safety, rollback or forward-fix behavior, supported database engines, and the evidence required to declare completion.
6. Stop before any destructive, ambiguous, or non-recoverable data action unless its specific Human gate has been satisfied.

## Definition Of Done

Every task is done when:

- the requested outcome and done condition are satisfied without unresolved scope deviation;
- relevant validation passes and known limits are explicit;
- current facts are synchronized when behavior changed;
- intended repository changes are identified and unrelated work is preserved;
- Jira state, implementation state, deployment state, commits, and delivery actions are reported accurately when applicable.
- the completion blocker scan finds no unresolved dependency or Human gate that prevents review or closure.

Standard and High-impact work also requires the applicable compatibility, migration, security, operational, and Jira closeout evidence.

A product version is release-ready only when the release-candidate gate passes for the exact candidate commits and artifacts. Release-ready does not itself mean tagged, published, promoted, deployed, migrated, or accepted in production.

## Version And Deployment Semantics

- Jira workflow states are `Intake`, `Ready`, `In Progress`, `Awaiting Confirmation`, and `Done`.
- `Done` means the stated scope and required evidence are accepted and canonical facts are synchronized; it does not imply deployment.
- Product ideas that are not selected for delivery remain in `backlog/`, not Jira.
- Deployment states are `Not deployed`, `Testing`, `Production`, and `N/A`.
- `system/` describes verified current implementation facts, not production deployment evidence unless a deployment baseline is recorded explicitly.

## Spec-Only Governance Exception

Information architecture, workflow rules, templates, references, and factual documentation may change directly in `cashlenx-spec` without opening a CLV product version when runtime behavior and controlled contracts do not change. Use Jira when shared visibility is useful. Validate Markdown structure and local links, moved paths, encoding, stale or duplicated policy owners, `git diff --check` when available, source-snapshot integrity when touched, and the unchanged state of implementation repositories.
