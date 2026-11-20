# Collaboration System

## Purpose

CashLenX uses Jira, Confluence, and the project repositories as complementary collaboration surfaces. Each fact or action has one primary owner so humans and agents can work together without duplicated plans or drifting technical claims.

All routine Jira and Confluence operations are performed through the authorized Atlassian CLI (`twg`) against `macacloud.atlassian.net`. Standing authorization covers in-scope reads, creation, edits, links, comments, workflow transitions, and targeted deletion. Clearing or fully resetting a project, space, or equivalent collaboration surface requires fresh explicit user authorization for that specific operation. Browser-based Atlassian administration is outside the default workflow and requires an explicit user request.

## Ownership

| Surface | Primary responsibility |
| --- | --- |
| Jira project `CLX` | Raw requirement intake, executable work, priority, dependencies, ownership, acceptance criteria, validation summaries, Human decision tasks, and delivery state. |
| Jira Product Discovery project `CLV` | Archived on 2026-11-20. Its Ideas are historical version records only; the project is not maintained and new versions are not created there. |
| Confluence | Maintained instructions and shared context for users and developers, including product orientation, architecture navigation, workflow guidance, and decision summaries. |
| `cashlenx-spec/facts/` | Verified current product, architecture, API, operations, delivery, testing, quality, and collaboration facts. |
| `cashlenx-spec/versions/` | The version ladder and one record per version: exact commits, decisions, evidence, acceptance, deployment identity. |
| `cashlenx-spec/backlog/` | Deferred candidates and unresolved questions that are not selected delivery commitments. |
| Implementation repositories and active contracts | Exact runtime behavior, generated artifacts, routes, fields, and executable truth. |

`cashlenx-app` owns current UI behavior and presentation. `cashlenx-design` was
archived on 2026-10-12 and remains historical prototype evidence only; it is not
maintained in parallel and does not impose a parity requirement.

## Workspace And Remote Identities

The local workspace uses stable short checkout directories:

| Area | Local directory | Remote repository and artifact identity |
| --- | --- | --- |
| App | `app/` | `cashlenx-app` |
| Server | `server/` | `cashlenx-server` |
| Website | `website/` | `cashlenx-website` |
| Spec | `spec/` | `cashlenx-spec` |

Automation maps these columns explicitly. Local path resolution never assumes
the `cashlenx-*` remote name is also the checkout directory, and remote links,
image names, source archives, and repository reports never replace the remote
identity with the short local directory. Shared automation prefers the short
local directories and accepts full remote-style checkout names only as a
compatibility fallback.

## Language

English is the default working language for code, documentation, Jira, Confluence, commit messages, release notes, and engineering artifacts. Another language is used only when explicitly required by localized product content, translation, or i18n validation.

## Version Model

- The version ladder in `../versions/README.md` and the `version/X.Y.Z` tag on a
  commit of `develop` are the identity of a product version. A checkout resolves
  it; no external surface does.
- Versions are recorded in `versions/` only. The CLV project was archived on
  2026-11-20 by the owner so the project stops maintaining two version lines;
  its Ideas stay readable as historical records and a ladder row that has no
  repository record points at the archived Idea.
- CLX owns execution. A selected item names its target version and carries the
  matching `version-vX-Y-Z` and `release-line-vX-Y` labels as query aids.
- When a label or fix version disagrees with the ladder, verify the
  implementation, correct the ladder, then repair the Jira metadata.
- Keep one active release line by default.
- Use patch versions for compatible fixes, refactors, maintenance and
  operational improvements; minor versions for compatible capabilities; major
  versions for breaking or reset boundaries. Effort changes task decomposition,
  not the semantic version.
- Keep unselected ideas in `backlog/`; do not fill Jira with speculative work.
- Use issue links for cross-version or cross-area dependencies.
- When a version close gate passes and the next delivery boundary opens, record
  the final evidence in the version record. Leave completed CLX items in place
  with their history and labels; no CLV Idea is created or archived.
- Treat release publication, tags, branch promotion and deployment as separate
  evidenced actions. A complete version may be fast-forwarded from `develop` to
  `testing` under standing authority after every applicable gate passes.
  Promotion to `main` requires explicit manual owner confirmation; other
  controlled delivery actions retain their applicable authority requirements.

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
- Before moving work from either Ready lane to `In Progress` and before moving it to `Done`, inspect linked blockers, the target version record and release-line state, Human-gate markers, comments, and acceptance conditions.
- When a blocker is found or changes, record a concise `Blocker scan` comment in Jira and alert the user in the active conversation. State the issue key, exact Human action when applicable, and what cannot proceed.
- Prepare decision options, evidence, and a recommendation before requesting Human input unless the missing input prevents preparation itself.
- A selected implementation item authorizes work on `develop`, but an individual
  item does not make an incomplete version eligible for promotion. A complete
  version that passes the release-candidate gate has standing authority for a
  verified fast-forward to `testing`. Require explicit manual Human confirmation
  for `main` and the applicable authority for tags, publication, production
  deployment, migration, or production acceptance. Preserve additional Human
  gates for force-push, existing-tag mutation, secret exposure or change,
  destructive or ambiguous production-data migration, security exceptions,
  and failed-gate bypass.

## Workflow

Board states, triage, owner selection, blocker scan, Human gates, the promotion
sequence and the release gate are owned by `delivery.md`. This file owns which
surface holds what, and how the surfaces stay synchronized.

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
2. Update the canonical fact in `facts/`, or the version record when the
   change belongs to a delivery.
3. Update the Jira item with validation and implementation references.
4. Update Confluence when user or developer guidance changed.
5. Report implementation, release, and deployment state separately.

If the surfaces disagree, inspect implementation and active contracts first, correct the canonical specification, and then synchronize Jira and Confluence.

## Authority

The owner holds product direction, security and privacy decisions, release
acceptance, credentials, shared-environment actions, and the final decision to
merge or deploy. A contribution, a prepared Ready item, or an AI agent's
confidence authorizes none of those.

AI assistance is part of the delivery model. It does not replace owner
accountability: material product choices, security and privacy boundaries,
secrets, production actions, license changes and final acceptance stay with the
owner, and AI-modified work must remain reviewable, traceable to repository
evidence, and validated in proportion to its risk.

## Participation

- Direct a change to the repository that owns the behavior, and describe
  cross-repository impact explicitly instead of coupling repositories at build
  or run time. Current UI work goes to `cashlenx-app`; the archived prototype is
  read-only.
- Read the repository `README.md` and nearest `AGENTS.md`, state the outcome and
  the observable done condition, confirm current behavior from code, contracts,
  tests and facts, make the smallest complete change, and add focused validation
  for the behavior plus its first relevant failure, authorization or repeat path.
- Update OpenAPI, user documentation or the facts here when the external
  contract or verified behavior changes.
- A reviewable change states: the problem and intended outcome, the owning and
  affected repositories, reproducible validation, API/data/migration/security/
  deployment impact, screenshots for visible UI changes, and known limits.
- Never place credentials, owner-managed environment contents, personal data,
  production logs or unsanitized telemetry in issues, commits, tests or pull
  requests. Treat a possibly real exposed credential as compromised and rotate
  it before use.
- Report a vulnerability through the repository's private reporting or security
  advisory feature when available, naming the affected repository, branch,
  commit, route or component, the impact and realistic attack conditions,
  minimal reproduction and suggested mitigations. If private reporting is
  unavailable, open a minimal issue asking for a private channel and omit every
  sensitive detail.
- Contributions are submitted under the MIT licence. Third-party material keeps
  its own terms and attribution.
