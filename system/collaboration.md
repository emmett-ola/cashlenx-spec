# Collaboration System

## Purpose

CashLenX uses Jira, Confluence, and the project repositories as complementary collaboration surfaces. Each fact or action has one primary owner so humans and agents can work together without duplicated plans or drifting technical claims.

All routine Jira and Confluence operations are performed through the authorized Atlassian Rovo integration. Standing authorization covers in-scope reads, creation, edits, links, comments, workflow transitions, and targeted deletion. Clearing or fully resetting a project, space, or equivalent collaboration surface requires fresh explicit user authorization for that specific operation. Browser-based Atlassian administration is outside the default workflow and requires an explicit user request.

## Ownership

| Surface | Primary responsibility |
| --- | --- |
| Jira project `CLX` | Active product versions, executable work, priority, dependencies, ownership, acceptance criteria, validation summaries, and delivery state. |
| Confluence | Maintained instructions and shared context for users and developers, including product orientation, architecture navigation, workflow guidance, and decision summaries. |
| `cashlenx-spec/system/` | Verified current product, architecture, API, operations, testing, quality, and collaboration facts. |
| `cashlenx-spec/decisions/` | Durable product and architecture decisions. |
| `cashlenx-spec/backlog/` | Deferred candidates and unresolved questions that are not selected delivery commitments. |
| `cashlenx-spec/versions/` | Completed repository-local delivery evidence and explicitly required closeout snapshots. |
| Implementation repositories and active contracts | Exact runtime behavior, generated artifacts, routes, fields, and executable truth. |

## Language

English is the default working language for code, documentation, Jira, Confluence, commit messages, release notes, and engineering artifacts. Another language is used only when explicitly required by localized product content, translation, or i18n validation.

## Jira Version Model

- Create one outcome-based epic for each selected product version.
- Name the epic with the version and outcome, for example `Deliver v0.10.0 — cloud and self-hosted hardening`.
- Record the goal, verified context, scope, non-goals, affected project areas, exit criteria, dependencies, risks, and documentation impact in the epic.
- Connect every selected story and task to its version epic.
- Keep unselected ideas in `backlog/`; do not fill Jira with speculative work.
- Use issue links for cross-version or cross-area dependencies.
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

## Human Intervention And Blockers

- Apply `human-decision` to every item that contains a Human gate and place a `Human intervention gate` section near the top of its description. The section records the trigger, exact requested decision or authorization, blocked transition, and current state.
- Apply `human-action-required` only when Human input is required now. It is mutually exclusive with `agent-ready` and prevents the stated transition until the response is recorded in Jira.
- Apply `blocked` while an unresolved linked dependency or external condition prevents the next planned transition. It is mutually exclusive with `agent-ready`. Represent Jira-to-Jira dependencies with issue links, not labels alone.
- Before planning or starting work and before moving work to `In Review` or `Done`, inspect linked blockers, the parent/version state, Human-gate markers, comments, and acceptance conditions.
- When a blocker is found or changes, record a concise `Blocker scan` comment in Jira and alert the user in the active conversation. State the issue key, exact Human action when applicable, and what cannot proceed.
- Prepare decision options, evidence, and a recommendation before requesting Human input unless the missing input prevents preparation itself.
- The accepted `v1.0.0` charter provides standing authority for routine
  delivery actions after their automated gates pass. Do not create redundant
  Human gates for those actions. Preserve explicit Human gates for force-push,
  existing-tag mutation, secret exposure or change, destructive or ambiguous
  production-data migration, security exceptions, and failed-gate bypass.

## Workflow And Evidence

Jira workflow states are `To Do`, `In Progress`, `In Review`, and `Done`.

- `To Do` means the item is selected but implementation has not started.
- `In Progress` means scoped work is being implemented.
- `In Review` means implementation is complete and acceptance evidence is being reviewed.
- `Done` means acceptance criteria and required evidence are satisfied and canonical facts are synchronized.

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
