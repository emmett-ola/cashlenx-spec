# 0002 Spec-Controlled Versioning With Project-Local Advancement

## Status

Accepted

## Context

CashLenX has separate project areas for spec, app, backend, website, and design reference. Release scope is controlled by `cashlenx-spec`, but not every later delivery affects every runtime project.

## Decision

- `cashlenx-spec` controls product delivery versions and defines scope under `versions/`.
- Website, app, and backend all advance to `v1.0.0` for the first stable release.
- After `v1.0.0`, only affected implementation projects advance their runtime/displayed version.
- If `v1.0.1` changes only backend behavior, backend advances to `v1.0.1` while app remains at its last affected version.
- If `v1.0.3` changes only app behavior, app advances to `v1.0.3` while backend remains at its last affected version until a later backend-impacting delivery.
- Spec versions can exist even when some implementation projects do not receive version bumps.

## Consequences

- Version records must list affected project areas clearly.
- Release notes must distinguish product/spec scope from each implementation project's runtime/displayed version.
- Validation scope should follow touched project areas.
- Version metadata synchronization is required only for affected projects, except for the coordinated first stable `v1.0.0` release.

## References

- `../versions/README.md`
