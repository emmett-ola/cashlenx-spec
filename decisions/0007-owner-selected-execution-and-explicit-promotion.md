# 0007 Owner-Selected Execution And Explicit Promotion

## Status

Accepted on 2026-10-12 by the project owner.

This decision narrows the autonomous delivery authority recorded in
`0003-v1-product-deployment-and-autonomous-release-charter.md`.

## Context

Jira contains a growing inventory of executable Ready items. Readiness proves
that a task contract is prepared and unblocked, but it does not identify which
work the product owner wants implemented next. Treating Ready status as standing
authorization can start the wrong scope and makes a fresh agent session behave
differently from the established workflow.

The project also uses separate `develop`, `testing`, and `main` branches. Branch
state, CI success, and a completed Jira item are evidence, but none identifies a
requested environment promotion by itself.

## Decision

- Jira `Ready` means prepared for execution. It does not authorize a transition
  to `In Progress`, code changes, or inclusion in a delivery batch.
- The product owner explicitly selects the Ready item or batch to execute.
  Triage and execution remain separate requests, and unselected Ready inventory
  remains unchanged.
- A selection instruction may also name the terminal delivery step for that
  batch. It remains valid through the routine substeps of that stated sequence,
  without repeated approval, and does not expand to another batch or boundary.
- Implement a selected batch sequentially unless the product owner explicitly
  requests parallel work. Run blocker scans per item, validate the completed
  scope, create a focused commit per item or coherent change, and push the
  affected repository's `develop` branch.
- Working-branch commits and pushes are part of routine completion for selected
  work. They do not authorize branch promotion, tags, publication, deployment,
  migration execution, or production acceptance.
- Promote a completed selected batch to `testing` only under an explicit current
  instruction and only as a verified fast-forward from the exact `develop`
  candidate. Confirm clean synchronized worktrees, version consistency,
  proportional tests, green required CI, ancestry, remote refs, and Testing
  workflow results.
- Keep the CLV Idea in Delivery until Human Testing acceptance is recorded.
- Promote to `main`, create a release tag, publish artifacts, or deploy to
  production only under explicit authorization for that step after its
  applicable gate passes.
- Record exact commits, validation, promotions, workflow results, and acceptance
  in CLV and connected CLX work without inferring one delivery state from
  another.

## Consequences

- A new session can inspect Ready inventory without accidentally starting it.
- The product owner controls scope order and every environment boundary.
- Selected implementation work proceeds without repeated permission for routine
  edits, focused validation, commits, and `develop` pushes.
- Testing and production history remains reproducible because promotions are
  fast-forwarded from verified commits and each state has separate evidence.

## References

- `../AGENTS.md`
- `../WORKFLOW.md`
- `../system/collaboration.md`
- `0003-v1-product-deployment-and-autonomous-release-charter.md`
