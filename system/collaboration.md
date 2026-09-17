# Collaboration System

## Purpose

CashLenX uses Jira, Confluence, and the project repositories as complementary collaboration surfaces. Each fact or action has one primary owner so humans and agents can work together without duplicated plans or drifting technical claims.

All routine Jira and Confluence operations are performed through the authorized Atlassian Rovo integration. Standing authorization covers in-scope reads, creation, edits, links, comments, workflow transitions, and targeted deletion. Clearing or fully resetting a project, space, or equivalent collaboration surface requires fresh explicit user authorization for that specific operation. Browser-based Atlassian administration is outside the default workflow and requires an explicit user request.

## Ownership

| Surface | Primary responsibility |
| --- | --- |
| Jira project `CLX` | Raw requirement intake, active product versions, executable work, priority, dependencies, ownership, acceptance criteria, validation summaries, Human decision tasks, and delivery state. |
| Confluence | Maintained instructions and shared context for users and developers, including product orientation, architecture navigation, workflow guidance, and decision summaries. |
| `cashlenx-spec/system/` | Verified current product, architecture, API, operations, testing, quality, and collaboration facts. |
| `cashlenx-spec/decisions/` | Durable product and architecture decisions. |
| `cashlenx-spec/backlog/` | Deferred candidates and unresolved questions that are not selected delivery commitments. |
| `cashlenx-spec/versions/` | Completed repository-local delivery evidence and explicitly required closeout snapshots. |
| Implementation repositories and active contracts | Exact runtime behavior, generated artifacts, routes, fields, and executable truth. |

## Language

English is the default working language for code, documentation, Jira, Confluence, commit messages, release notes, and engineering artifacts. Another language is used only when explicitly required by localized product content, translation, or i18n validation.

## Jira Version Model

- `Fix Version/s` is the authoritative exact product delivery version for selected Jira work.
- Create one outcome-based release epic for each selected product version. Add workstream epics only when they materially improve navigation; do not use epic membership as a substitute for the version field.
- Name the release epic with the version and outcome, for example `Deliver v1.1.0 — shared household planning`.
- Record the goal, verified context, scope, non-goals, affected project areas, exit criteria, dependencies, risks, and documentation impact in the release epic.
- Assign every selected story and task to its exact Fix Version and connect it to the most useful release or workstream epic when applicable.
- Keep one active release line by default. Apply `release-line-vX-Y` to all work in that line.
- Use patch versions for compatible fixes, refactors, maintenance, and operational improvements; minor versions for compatible capabilities; and major versions for breaking or reset boundaries. Effort changes task decomposition, not the semantic version.
- Keep unselected ideas in `backlog/`; do not fill Jira with speculative work.
- Use issue links for cross-version or cross-area dependencies.
- When a major or minor release line is fully closed and the next line begins, add `archived` to its completed work and expose it through a saved-filter board named `CashLenX — vX.Y.x Archive`. The primary board excludes `archived` work.
- Treat release publication, tags, branch promotion, and deployment as separate
  evidenced actions. Apply the standing authority in the accepted delivery
  charter only after every applicable gate passes.

## Jira Work Item Contract

Every executable story, task, or bug contains:

1. Outcome.
2. Verified context and evidence.
3. In-scope and out-of-scope boundaries.
4. Observable acceptance criteria.
5. Validation expectations, including meaningful failure paths.
6. Dependencies and risks.
7. Documentation and compatibility impact.

Use a small controlled label set for project area, concern, and decision state. Do not encode status, priority, or assignee into the summary.

Every executable item also has one of `size-s`, `size-m`, or `size-l`. Size expresses decomposition and implementation breadth; priority expresses impact, urgency, risk, or ability to unlock the active release line.

## Human Intervention And Blockers

- Represent a Human gate as a separate Task named `Decision: ...` in `Awaiting Confirmation`. Apply `human-decision` and place a `Human intervention gate` section near the top of its description. The section records the trigger, options, evidence, recommendation, exact requested decision or authorization, blocked transition, and current state.
- Apply `human-action-required` only when Human input is required now. It is mutually exclusive with `agent-ready` and prevents the stated transition until the response is recorded in Jira.
- Apply `blocked` while an unresolved linked dependency or external condition prevents the next planned transition. It is mutually exclusive with `agent-ready`. Represent Jira-to-Jira dependencies with issue links, not labels alone.
- Before moving work from `Ready` to `In Progress` and before moving it to `Done`, inspect linked blockers, the Fix Version and release-line state, Human-gate markers, comments, and acceptance conditions.
- When a blocker is found or changes, record a concise `Blocker scan` comment in Jira and alert the user in the active conversation. State the issue key, exact Human action when applicable, and what cannot proceed.
- Prepare decision options, evidence, and a recommendation before requesting Human input unless the missing input prevents preparation itself.
- The accepted `v1.0.0` charter provides standing authority for routine
  delivery actions after their automated gates pass. Do not create redundant
  Human gates for those actions. Preserve explicit Human gates for force-push,
  existing-tag mutation, secret exposure or change, destructive or ambiguous
  production-data migration, security exceptions, and failed-gate bypass.

## Workflow And Evidence

The accepted primary-board target is `CashLenX — Active Delivery`. Its logical workflow states are `Intake`, `Ready`, `In Progress`, `Awaiting Confirmation`, and `Done`.

- `Intake` contains Human-authored raw demand and answered decision tasks awaiting agent triage.
- `Ready` contains executable task contracts with an exact Fix Version, priority, size, acceptance criteria, and known dependencies.
- `In Progress` contains scoped work being implemented, validated, or synchronized.
- `Awaiting Confirmation` contains only separate decision tasks with a concrete Human question and prepared recommendation.
- `Done` means acceptance criteria and required evidence are satisfied and canonical facts are synchronized.

When the product owner requests triage, the agent reads `Intake`, preserves original intent, inspects evidence, rewrites or splits the demand, assigns priority and version, links dependencies, and moves complete unblocked work to `Ready`. A `size-l` request is normally decomposed before it is ready.

After the Human answers a decision task, they move it from `Awaiting Confirmation` to `Intake`. The next triage records the decision, updates and unblocks affected work, and moves the decision task to `Done`.

The authorized Rovo surface currently maintains issue and Confluence content but does not expose Jira project administration. Until it can configure the target physically, the project uses `To Do` without `agent-ready` for logical `Intake`, `To Do` with unblocked `agent-ready` for logical `Ready`, `In Progress` directly, `In Review` with active Human-decision labels for logical `Awaiting Confirmation`, and `Done` directly. Temporary `planned-version-vX-Y-Z` labels preserve migration intent but are not authoritative Fix Versions. Physical board and release configuration remains tracked in Jira and must not be reported as complete.

Jira state does not prove branch promotion, tag creation, publication, or deployment. Record those states explicitly when they occur.

## Confluence Information Architecture

The CashLenX Confluence hub maintains concise English pages for:

- Product overview and user goals.
- Architecture and repository navigation.
- User instructions.
- Developer instructions.
- Delivery and Jira workflow.
- Decision summaries and open questions.
- Release and operational guidance when selected.

Confluence pages link to repository documents for detailed contracts and implementation facts. Avoid copying route catalogs, schemas, command references, or large specifications that will drift.

## Synchronization

When work changes behavior or instructions:

1. Update implementation and active contracts.
2. Update the canonical `system/` fact and any durable decision.
3. Update the Jira item with validation and implementation references.
4. Update Confluence when user or developer guidance changed.
5. Report implementation, release, and deployment state separately.

If the surfaces disagree, inspect implementation and active contracts first, correct the canonical specification, and then synchronize Jira and Confluence.
