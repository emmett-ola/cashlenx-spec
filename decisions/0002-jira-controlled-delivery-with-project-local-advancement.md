# 0002 Jira-Controlled Delivery With Project-Local Advancement

## Status

Accepted

Operational board states, exact Fix Version authority, optional workstream epics, and release-line archiving are refined by `0004-agent-led-jira-intake-and-version-archives.md`. Repository ownership and project-local version advancement in this decision remain in force.

## Context

CashLenX has separate specification, app, backend, website, and design-reference project areas. Humans and agents need one shared operational surface for product versions, executable work, priorities, dependencies, acceptance, and delivery state without weakening repository ownership of implementation facts.

## Decision

- Jira project `CLX` controls active product delivery versions and executable work.
- Each selected product version is represented by one outcome-based Jira release epic. Stories and tasks assigned to its Fix Version contain the task contract, acceptance criteria, dependencies, risks, and validation summary; optional workstream epics may improve navigation.
- Jira delivery state is distinct from implementation branch state, release publication, and deployment state.
- Confluence provides maintained English instructions and context for users and developers. It links to canonical repository sources instead of copying large technical specifications.
- `cashlenx-spec/system/` owns verified current product and system facts; `cashlenx-spec/decisions/` owns durable decisions; implementation repositories and active contracts own exact runtime truth.
- Existing records under `cashlenx-spec/versions/` preserve completed delivery evidence. A future repository-local version snapshot is created only when durable closeout evidence must live with the specification; Jira remains the active control surface.
- Website, app, and backend all advance to `v1.0.0` for the first stable release.
- After `v1.0.0`, only affected implementation projects advance their runtime or displayed version.
- If a product version changes only backend behavior, the backend advances while the app remains at its last affected version. The equivalent rule applies to app-only and website-only delivery.
- Recorded standing delivery authority may cover routine tags, publication,
  clean fast-forward promotion, and non-destructive deployment after every
  applicable gate passes. Exceptional actions remain subject to their explicit
  Human gates.

## Consequences

- Every active release epic must name its outcome, scope, exit criteria, affected project areas, and non-goals.
- Executable work must have an authoritative Fix Version unless it is intentionally version-independent maintenance and may connect to a release or workstream epic as useful.
- Jira status must not be used as evidence that implementation, release, or deployment occurred.
- Closing a Fix Version and its release epic requires canonical fact synchronization and links to the relevant implementation commits and validation evidence.
- Confluence must be updated when user or developer instructions change, but it does not override the repository specification.
- Validation and runtime version changes follow the implementation projects actually affected, except for the coordinated first stable `v1.0.0` release.

## References

- `../system/collaboration.md`
- `../WORKFLOW.md`
- `../versions/README.md`
- `0003-v1-product-deployment-and-autonomous-release-charter.md`
- `0004-agent-led-jira-intake-and-version-archives.md`
