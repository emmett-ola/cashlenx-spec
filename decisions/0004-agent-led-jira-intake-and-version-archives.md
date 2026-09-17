# 0004 Agent-Led Jira Intake And Version Archives

## Status

Accepted on 2026-09-17.

Exact-version authority and archive implementation are superseded by `0005-clv-authoritative-version-catalog.md`. The five-state CLX workflow, agent-led triage, decision-task loop, semantic version selection, sizing, and priority rules remain in force.

## Context

CashLenX needs a collaboration loop in which the product owner can capture rough requirements without first converting them into implementation-ready tickets. The previous four-state Jira workflow mixed selected work, review, and Human decisions, while historical version labels did not provide an authoritative exact delivery boundary. Keeping every completed item on the primary board would also make the active view progressively less useful.

The product owner wants the agent to own requirement refinement, decomposition, prioritization, version planning, dependency modeling, and execution readiness. Material decisions must remain explicitly Human, and completed release lines must remain discoverable without occupying the active board.

## Decision

- The primary board is `CashLenX — Active Delivery` with `Intake`, `Ready`, `In Progress`, `Awaiting Confirmation`, and `Done`.
- The product owner writes rough demand in `Intake`. On request, the agent preserves original intent, inspects evidence, rewrites or splits the demand into task contracts, assigns priority, size, dependencies, and version, and moves complete unblocked work to `Ready`.
- `Awaiting Confirmation` contains only separate `Decision: ...` tasks. Each decision task prepares options, evidence, a recommendation, and the exact requested answer; it blocks affected work through a Jira `Blocks` link.
- The product owner records an answer and returns the decision task to `Intake`. The next triage records the decision, updates dependent contracts, removes satisfied blockers, closes the decision task, and moves newly executable work to `Ready`.
- Jira `Fix Version/s` is authoritative for the exact planned delivery version. One release epic describes each version outcome; optional workstream epics may improve navigation but do not replace version membership.
- Semantic scope determines the version: patch for compatible fixes and internal or operational improvements, minor for compatible capabilities, and major for breaking or reset boundaries. Effort determines decomposition and the `size-s`, `size-m`, or `size-l` label, not the version number.
- One release line is active by default. Every item in the line receives `release-line-vX-Y`.
- The primary board excludes `archived`. After a major or minor release line is fully closed and the next line begins, its completed items receive `archived` and appear on a saved-filter board named `CashLenX — vX.Y.x Archive`.
- Historical beta and `v0.10.0` planning are consolidated into the `v1.0.0` delivery record. Compatible remaining work begins at `v1.0.1`.

## Consequences

- Raw demand can be captured quickly without implying readiness or a delivery commitment.
- Every executable item has a complete contract, exact version, priority, size, and dependency state before execution begins.
- Human questions are visible without turning ordinary implementation review into a blocking queue.
- Jira retains full issue history while the active board remains focused on the current release line.
- Release-line and archive labels are controlled navigation metadata; they must not be used as substitutes for `Fix Version/s` or workflow status.
- While the authorized Rovo surface lacks project-administration operations, the five logical areas use the documented four-status compatibility mapping and temporary `planned-version-vX-Y-Z` migration labels. This is an operational bridge, not evidence that the physical board or Fix Versions were configured.
- A closed Jira item or Fix Version does not prove branch promotion, tag creation, publication, deployment, migration, or production acceptance.

## References

- `../WORKFLOW.md`
- `../system/collaboration.md`
- `../versions/README.md`
- `0002-jira-controlled-delivery-with-project-local-advancement.md`
