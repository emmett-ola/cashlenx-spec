# 0009 Split Ready Lanes By Implementation Owner

## Status

Accepted on 2026-10-13.

## Context

The single CLX `Ready` state mixed backend and user-facing work in one queue,
even though CashLenX has distinct Server and App implementation ownership. Jira
now exposes two physical To Do statuses, `Ready (Server)` and `Ready (App)`, in
place of the former single Ready status. The specification must route triaged
work to the same physical workflow used by Jira.

## Decision

- `Ready (Server)` owns API and Server-side services, authentication,
  persistence, database behavior, operations, performance, optimization,
  maintenance, and backend development.
- `Ready (App)` owns App-side user interfaces, interaction, visual design,
  accessibility, localization presentation, navigation, client state, App
  performance, and other user-facing implementation.
- A demand that contains independently deliverable Server and App outcomes is
  split into linked work items before either item enters a Ready lane.
- An irreducible cross-area item is routed by its primary next implementation
  owner and identifies every affected repository and rollout dependency in its
  task contract.
- Both Ready lanes retain the same readiness contract, blocker semantics, and
  owner-selection gate. Entering either lane completes triage; it does not
  authorize implementation or a transition to `In Progress`.
- The blocker scan applies before work moves from either Ready lane to
  `In Progress` and again before it moves to `Done`.

## Consequences

- The physical CLX workflow has six states: `Intake`, `Ready (Server)`,
  `Ready (App)`, `In Progress`, `Awaiting Confirmation`, and `Done`.
- Triage must select an implementation owner instead of placing all prepared
  work in one undifferentiated queue.
- Cross-area requirements expose repository ownership and rollout dependencies
  before implementation begins.
- Existing rules for task contracts, CLV delivery links, version labels,
  priority, size, blockers, Human decisions, execution selection, and evidence
  remain unchanged.

## References

- `../AGENTS.md`
- `../WORKFLOW.md`
- `../system/collaboration.md`
- `0004-agent-led-jira-intake-and-version-archives.md`
- `0006-archive-design-prototype-and-move-ui-authority-to-app.md`
- `0007-owner-selected-execution-and-explicit-promotion.md`
