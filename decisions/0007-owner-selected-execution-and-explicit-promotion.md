# 0007 Owner-Selected Execution And Explicit Promotion

## Status

Accepted on 2026-10-12 by the project owner.

Amended on 2026-10-12 to establish workspace synchronization preflight and
standing authority for verified Testing promotion of a complete version.

Amended again on 2026-10-12 so an explicit production-promotion instruction
covers the complete normal delivery sequence for affected repositories,
including App publication and non-destructive Server deployment.

This decision narrows the autonomous delivery authority recorded in
`0003-v1-product-deployment-and-autonomous-release-charter.md`.

## Context

Jira contains a growing inventory of executable Ready items. Readiness proves
that a task contract is prepared and unblocked, but it does not identify which
work the product owner wants implemented next. Treating Ready status as standing
authorization can start the wrong scope and makes a fresh agent session behave
differently from the established workflow.

The project also uses separate `develop`, `testing`, and `main` branches. Work
must start from clean synchronized local repositories so stale or unrelated
state cannot enter a selected delivery. Implementation occurs on `develop`.
A complete version should reach `testing` without a repeated approval request,
while production branch promotion remains a deliberate Human decision.

## Decision

- Jira `Ready` means prepared for execution. It does not authorize a transition
  to `In Progress`, code changes, or inclusion in a delivery batch.
- The product owner explicitly selects the Ready item or batch to execute.
  Triage and execution remain separate requests, and unselected Ready inventory
  remains unchanged.
- Before task work, identify every relevant active repository, fetch remote
  refs, and verify a clean worktree on the expected branch synchronized with its
  upstream. Fast-forward a clean branch that is only behind. Stop on dirty,
  divergent, unexpected-branch, or missing-upstream state instead of resetting,
  stashing, switching, or overwriting unrelated work.
- Implement a selected batch sequentially unless the product owner explicitly
  requests parallel work. Run blocker scans per item, validate the completed
  scope, create a focused commit per item or coherent change, and push the
  affected repository's `develop` branch.
- Working-branch commits and pushes on `develop` are part of routine completion
  for selected work. An individual commit does not make an incomplete version
  eligible for promotion.
- After every selected item in an exact product version is complete, promote the
  affected repositories to `testing` under standing authority when the
  release-candidate gate passes. Use only a verified fast-forward from the exact
  `develop` candidate. Confirm clean synchronized worktrees, version
  consistency, proportional tests, green required CI, ancestry, remote refs,
  and Testing workflow results.
- Keep the CLV Idea in Delivery until Human Testing acceptance is recorded.
- Promote to `main` only after explicit manual Human confirmation for the exact
  accepted candidate. That confirmation covers the ordered normal release
  sequence: fast-forward the affected repositories, wait for and verify the
  App's branch-triggered Production publication, then deploy and verify the
  exact Server `main` candidate when Server is affected. Keep those states
  separately evidenced. Tags, other artifact publication, database execution,
  exceptional deployment actions, and production acceptance retain their own
  authority gates.
- Stop at the last verified state and record an incomplete release when the
  approved Bash deployment entry point, non-echoing access profile, exact
  deployable identity, rollback identity, or health evidence is unavailable.
  Never treat Server `main` or App publication as proof of Server deployment.
- Record exact commits, validation, promotions, workflow results, and acceptance
  in CLV and connected CLX work without inferring one delivery state from
  another.

## Consequences

- A new session can inspect Ready inventory without accidentally starting it.
- The product owner controls scope order and the production branch boundary.
- Selected implementation work proceeds without repeated permission for routine
  edits, focused validation, commits, and `develop` pushes.
- Testing and production history remains reproducible because promotions are
  fast-forwarded from verified commits and each state has separate evidence.
- Completed versions reach Testing without a redundant confirmation, while
  `main` cannot advance without a manual Human decision.
- Once that production decision is given, the normal release does not stop at
  source promotion: App publication and deployment of an affected Server are
  completed and verified in the same ordered operation whenever the approved
  deployment channel is available.

## References

- `../AGENTS.md`
- `../WORKFLOW.md`
- `../system/collaboration.md`
- `0003-v1-product-deployment-and-autonomous-release-charter.md`
