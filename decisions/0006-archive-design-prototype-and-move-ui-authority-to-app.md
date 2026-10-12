# 0006 Archive Design Prototype And Move UI Authority To App

## Status

Accepted on 2026-10-12 by the project owner.

## Context

`cashlenx-design` was created as an early Figma-exported React/Vite product
prototype. The production UI has matured in the Flutter application, and
maintaining the prototype and app as parallel UI implementations creates drift,
duplicate effort, and ambiguous design authority.

The prototype still contains useful historical evidence about early product
intent and visual exploration. Removing its history would reduce traceability,
while continuing to treat it as current would give future work the wrong source
of truth.

## Decision

- Archive the `cashlenx-design` GitHub repository and preserve its history as
  read-only historical prototype evidence.
- Stop all parallel UI maintenance and parity work in the archived repository.
- Make `cashlenx-app` the implementation authority for current UI behavior and
  presentation.
- Derive new UI work from active product requirements, the app's shared theme,
  tokens and components, acceptance evidence, and explicit durable decisions.
- Use the archived prototype only when historical context is relevant. A
  prototype-derived claim is not current until app evidence or an explicit
  product decision confirms it.
- Keep historical references in completed delivery records and copied source
  material intact when they accurately describe the evidence available at that
  time.

## Consequences

- New UI changes are implemented and reviewed in `cashlenx-app`.
- No task is blocked by missing prototype parity, and no current fact cites the
  prototype as its sole authority.
- Shared UI assets and tokens live in the app's maintained implementation
  boundary.
- The archived repository remains discoverable for traceability but accepts no
  ongoing contributions.

## Evidence

- The archival notice is committed at
  `bd91cf6e32b2219ff7f7d529c6b8630da7f3f16e` on `cashlenx-design/main`.
- GitHub reported `isArchived: true` for `emmett-ola/cashlenx-design` on
  2026-10-12.

## References

- `../system/design/README.md`
- `../system/collaboration.md`
- `../GOVERNANCE.md`
- `https://github.com/emmett-ola/cashlenx-design`
