# Delivery

This file owns how CashLenX turns selected work into a delivered, evidenced
version: the Jira surfaces, the promotion sequence, the release gate, and the
separate states a release passes through. The framework cycle that dispatches and
reviews that work is ASIDE's; it is not restated here.

## Work levels

| Level | Typical work | Who starts it | Record |
| --- | --- | --- | --- |
| Lightweight | Documentation correction, focused test, internal refactor, narrow defect fix with no external contract change | Agent, autonomously | Jira optional unless the work is already tracked |
| Standard | Clear reversible product behavior, additive API response, bounded cross-repository feature, release-scope refinement | Agent, after the owner selects a prepared item | CLX story or task linked to its version record |
| High-impact | Breaking API change, destructive data action, security or privacy boundary, production deployment, release or tag action, major product direction | Owner confirms the decision or operation; agent executes | Jira item with triggered evidence and the recorded owner decision |

When levels overlap, the highest applies. Technical difficulty alone does not
make work High-impact.

## Jira surfaces

- `CLX` (`CashLenX — Active Delivery`) owns executable work: contract fields,
  priority, size, dependencies, acceptance criteria, Human decision tasks and
  delivery state.
- `CLV` (`CashLenX Versions`) records the product-version outcome, roadmap
  position, lifecycle and links, so that a version is queryable from Jira.
- A version's identity is the ladder row in `../versions/README.md` plus its
  `version/X.Y.Z` tag. A CLV Idea, a `version-vX-Y-Z` label or a fix-version
  field is a query aid that must match the ladder; when they disagree the
  implementation is verified and the ladder is repaired first, then Jira.
- CLX physical states: `Intake`, `Ready (Server)`, `Ready (App)`,
  `In Progress`, `Awaiting Confirmation`, `Done`.
- `Intake`, `Ready (Server)` and `Ready (App)` map to Jira's To Do category;
  `In Progress` and `Awaiting Confirmation` to In Progress; `Done` to Done.
- A done item, a green workflow or a merged branch proves none of promotion,
  tagging, publication, deployment, migration or production acceptance. Each is
  recorded where it is proven.

## Routing

- `Ready (Server)` owns API and server-side services, authentication,
  persistence, database behavior, operations, performance, optimization,
  maintenance and backend development.
- `Ready (App)` owns app-side interface, interaction, visual design,
  accessibility, localization presentation, navigation, client state, app
  performance and other user-facing implementation.
- A demand with independently deliverable Server and App outcomes is split into
  linked items before either enters a Ready lane. An irreducible cross-area item
  is routed by its primary next implementation owner and names every affected
  repository and rollout dependency in its contract.
- A `size-l` item is normally decomposed before it reaches a Ready lane.
- Entering a Ready lane completes triage only. It never authorizes
  implementation, a transition to `In Progress`, or inclusion in a batch.

## Task contract

Every executable item carries: outcome; verified context and evidence; in-scope
and out-of-scope boundaries; observable acceptance criteria; validation
expectations including the first meaningful failure path; dependencies and risks;
documentation and compatibility impact; one size label (`size-s`, `size-m`,
`size-l`); and its target version.

## Owner selection

- The owner selects the item or batch to execute. Unselected Ready inventory is
  left untouched, and another batch requires a new instruction.
- Selected items run sequentially unless the owner explicitly requests parallel
  work, each with its own start blocker scan, focused validation, Jira evidence
  and focused commit on the affected repository's `develop`.
- An instruction that selects a batch remains authorization for that stated
  implementation sequence, including routine edits, validation, commits and
  `develop` pushes. It does not extend to `main`, a tag, publication, production
  deployment, migration or production acceptance.

## Human decision loop

Do not place executable work in `Awaiting Confirmation`. When a material
decision cannot be resolved from evidence:

1. Create a separate Task named `Decision: ...`.
2. Put the options, evidence, recommendation, the exact answer requested and the
   blocked transition in its `Human intervention gate` section.
3. Apply `human-decision` and `human-action-required`, remove `agent-ready`,
   link it as blocking the affected work, and move it to `Awaiting Confirmation`.
4. Leave affected work truthful: `blocked`, no `agent-ready`, no transition.
5. The owner records the answer and returns the task to `Intake`.
6. Next triage records decision maker, date, scope and constraints; updates
   dependent contracts; removes satisfied blockers; moves newly executable work
   to its owning Ready lane; and closes the decision task.

A conversation-only approval is copied into Jira before dependent work crosses
the gate. A decision that changes a version's scope or an authority rule is also
written into the owning facts file, not only into the ticket.

## Human gates

Ask for an owner decision only when one of these is unresolved:

- Two or more plausible interpretations materially change business behavior.
- A major architecture direction or long-lived external contract is selected.
- Breaking compatibility, destructive data mutation, an irreversible operation
  or a security/privacy risk must be accepted.
- Production deployment, promotion to `main`, a release tag, a secret change or
  another external-system mutation lacks concrete authorization.
- Completion requires expanding beyond the requested outcome or accepting a
  known High-impact risk.

The normal confirmation to promote an accepted release covers the ordered
sequence for its affected repositories: fast-forward to `main`, wait for and
verify the App branch-triggered Production publication, then deploy and verify
the exact Server `main` candidate when Server is affected. Tags, database
execution, secret changes, exceptional deployment actions and production
acceptance keep their own gates.

## Blocker scan

Run it before moving an item from either Ready lane to `In Progress` and again
before `Done`:

1. Inward `Blocks` links — is every blocker at the state the contract requires?
2. The selected version and release line — unresolved prerequisite or stopped
   boundary?
3. `human-decision`, `human-action-required`, `blocked`, `agent-ready` and the
   `Human intervention gate` section.
4. Comments and the contract for an unanswered decision, authorization,
   acceptance condition or new external dependency.
5. Clear → continue. Blocked → do not cross the transition; record a concise
   `Blocker scan` comment naming the blocker, the exact owner action and the
   consequence, and alert the owner in the conversation.

## Evidence when triggered

| Trigger | Additional evidence |
| --- | --- |
| External behavior or cross-repository feature | Goal, context, constraints, done condition, compatibility boundary, rollout order |
| API, schema, permission, workflow or state change | Positive and negative cases, authority owner, compatibility or migration behavior |
| Migration or data rewrite | Existing-data behavior, repeat safety, rollback or forward-fix plan |
| Security, privacy, credential or file-access change | Threat or abuse cases, sensitive-data handling, authorization, audit evidence |
| Production deployment, release, `main` promotion or nonstandard shared-environment action | Target, timing, reversibility, compatibility, explicit owner authorization |
| Major architecture or product direction | Options, trade-offs, recommendation, recorded owner decision |
| User-facing documentation, marketing or training claim | Review of the derived artifact against current facts |

## Release candidate gate

Run for every product release candidate. It is the acceptance contract for local
execution and for CI/CD; automation may implement it but may not weaken it.

1. **Jira preflight** — blocker scan for the version and every connected item.
   Stop on an unresolved dependency, `human-action-required`, incomplete
   acceptance criterion or unrecorded required decision.
2. **Source preflight** — record exact branches and commits, confirm intended
   worktrees hold no unrelated change, confirm ancestry suits the requested
   fast-forward, identify every affected area.
3. **Version contract** — verify the selected version against each affected
   runtime/display version, image label, artifact name and release record.
   Verify API paths and OpenAPI only when the Server changes. Record each
   unaffected repository at its retained version. Generated metadata derives
   from one authoritative source; it is never an independent fallback.
4. **Database preflight** — compare the delivered database boundary with the
   candidate, enumerate ordered migrations and recovery requirements, verify
   identity and immutability, and state when no change is required. Source
   delivery never proves an environment ran a migration.
5. **Repository validation** — focused checks first, then the required package
   tests, static analysis, contract tests, builds and generated-file checks for
   every affected repository through Bash-owned entry points.
6. **Image validation** — build candidates from controlled contexts, verify
   runtime contents and version/revision metadata, and prove environment files,
   credentials, Git state, logs, local data and unrelated outputs are absent.
7. **Production-like rehearsal** — generated disposable secrets, isolated names,
   selected topology run locally. Do not read `.env.testing` or
   `.env.production`. Verify ingress, health, restart, graceful shutdown,
   persistence, backup/restore, failure behavior and safe teardown.
8. **Whole-product acceptance** — selected stable journeys through built client
   and server artifacts against the primary database profile, then the required
   compatibility suite against every supported alternate engine.
9. **Evidence manifest** — a secret-free machine-readable record of version,
   commits, image and artifact identities, migration classification, validation
   results, timestamps, known limits and requested delivery actions.
10. **Delivery authority** — a complete version has standing authority for its
    verified `develop` → `testing` fast-forward once every gate above passes.
    Every other controlled action needs its applicable explicit instruction.
11. **Post-delivery verification** — remote refs and immutable tags, deployed
    identities when deployment occurred, health and smoke evidence, migration
    state, rollback readiness; then synchronize Jira, facts and Confluence.

The gate fails closed. Never bypass a failed check, force-push a delivery
branch, move an existing tag, or substitute a build result for runtime,
migration or acceptance evidence.

## Testing fast-forward

After every selected item in an exact version is complete: confirm every item is
complete, unblocked and linked to the intended version record; confirm each
affected worktree is clean, equal to `origin/develop`, with consistent runtime
and display versions, passing focused validation and green required `develop`
CI; prove `origin/testing` is an ancestor of the exact `origin/develop`
candidate; promote with `git push origin develop:testing` from that verified
candidate only; then verify the exact remote `testing` ref and the Testing
workflow, recording both and the candidate SHA.

Stop on divergence. Do not create a merge commit, cherry-pick, reset or
force-push to simulate a fast-forward. Keep the version in Delivery until the
owner records Testing acceptance.

## Main promotion and production delivery

After the owner authorizes the exact accepted release for `main`:

1. Re-run promotion and database preflights; fast-forward only the affected
   repositories from their exact accepted `testing` refs.
2. Wait for every required `main` workflow. When App is affected, its Production
   static publication must succeed and the public App runtime identity must be
   verified before continuing.
3. When Server is affected, deploy the exact Server `main` revision only through
   the approved Bash entry point and non-echoing owner-managed access profile.
   Do not read or print the owner-managed Production environment file, rebuild
   from another revision, pull an unverified image, or use retained PowerShell
   tooling.
4. Verify the deployed version and revision, container-local health, ingress
   health, selected-database connectivity and migration state, absence of
   unintended host ports, and rollback readiness.
5. Record branch refs, workflow results, App publication, Server deployment,
   database execution and production acceptance as distinct states.

If the Bash entry point, deployment access, exact deployable revision, rollback
identity or required health evidence is unavailable, stop at the last verified
state and record the release as incomplete. A `main` push or an App publication
is never evidence of Server deployment.

## Database preflight before promotion

Before promoting a repository to `main`, or deploying a candidate that changes
Server or persistence behavior: resolve the exact delivered and target commits;
inspect every intervening migration, schema, initialization, backup/restore and
compatibility change; produce the complete ordered instruction list or state
`No database change required`; classify each action as already evidenced, before
runtime update, after runtime update, or unverified; record repeat safety,
rollback or forward-fix behavior, supported engines and the evidence that closes
it; and stop before any destructive, ambiguous or non-recoverable data action
without its specific owner gate.

## Definition of done

The requested outcome and done condition are satisfied without scope deviation;
relevant validation passes and known limits are explicit; current facts are
synchronized when behavior changed; intended repository changes are identified
and unrelated work preserved; Jira, implementation, deployment, commit and
delivery states are reported accurately; and the completion blocker scan finds
no unresolved dependency or owner gate.

Standard and High-impact work also carries the applicable compatibility,
migration, security, operational and closeout evidence. A version is
release-ready only when the gate passes for the exact candidate commits and
artifacts; release-ready does not mean tagged, published, promoted, deployed,
migrated or accepted in production.

## Deployment states

`Not deployed`, `Testing`, `Production`, `N/A`. They are reported separately
from workflow state and from branch state.
