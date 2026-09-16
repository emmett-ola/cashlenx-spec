# 0001 Stable Release API, Auth, And Capability Policy

## Status

Accepted. The Budget scope decision is superseded by
`0003-v1-product-deployment-and-autonomous-release-charter.md`.

## Context

`v1.0.0` is the first formal stable CashLenX release. Before implementation starts, the release needs durable decisions for API path, login semantics, session behavior, demo mode, and export/import exposure.

## Decision

- `v1.0.0` launches the stable API path under `/api/v1`.
- `/api/v0` remains a frozen compatibility alias for previously shipped
  clients throughout the initial `v1` transition. It preserves the existing
  route, request, response, authentication, and error behavior but receives no
  new API surface. Removing the alias requires a separately recorded decision
  and an announced migration window; no removal date is currently set.
- Stable login supports both username and email.
- Remember-me does not define a separate app-level expiry; refresh-token expiry controls remembered session lifetime.
- Logout keeps the existing backend-supported ability to revoke a specified session or all sessions.
- Demo mode remains a normal available feature with local demo data.
- Export/import remains a management capability and is not exposed as a normal app user workflow in `v1.0.0`.
- The implemented monthly category-budget workflow is part of `v1.0.0` under
  the later accepted charter.

## Consequences

- App, server, OpenAPI, website, and spec release docs must point stable users to `/api/v1`.
- The Server registers `/api/v1` and the `/api/v0` compatibility alias from one
  implementation. OpenAPI is canonical at `/api/v1`, and validation normalizes
  supported v0 requests to that contract.
- The backend must support username and email login semantics before `v1.0.0` closes.
- Login retains the existing `username` JSON field for wire compatibility; the
  field accepts either identifier and authentication failures must not reveal
  whether a username or email exists.
- The app should not implement an independent remember-me expiry timer.
- The app should keep demo mode visible and intentional.
- Export/import UI should not be added for normal app users in `v1.0.0`.
- Budget must pass the same stable acceptance boundary as the other selected
  `v1.0.0` workflows.

## Compatibility Guarantees

- Additive fields and endpoints may be introduced under `/api/v1` when older
  clients can safely ignore them.
- Existing v1 field names, meanings, requiredness, response-wrapper shape,
  authentication semantics, and successful status codes are stable across
  `v1.x`. A change to any of these is breaking and requires a new API major
  version or a separately approved migration boundary.
- Security fixes may reject behavior that was never valid under the documented
  contract. They must retain non-enumerating authentication errors and the
  documented logout/session semantics.
- Binary download endpoints remain exempt from the JSON response wrapper.
- `/api/v0` is compatibility-only: new capabilities are not promised there,
  and clients should migrate to `/api/v1` without waiting for a removal date.

## v0 To v1 Client Path

1. Change the base path from `/api/v0` to `/api/v1`; route suffixes and the
   response wrapper remain unchanged.
2. Existing username login requests continue to work without payload changes.
   Email login uses the same `username` field.
3. Keep refresh-token-controlled remember-me and the existing logout request
   forms; do not add a client-only session lifetime.
4. Do not depend on normal-user import/export UI. Those operations remain
   management capabilities.
5. Treat `/api/v0` only as rollback time for cached or previously shipped
   clients, not as the target for new development.

## References

- `../versions/README.md`
- `../backlog/README.md`
- `0003-v1-product-deployment-and-autonomous-release-charter.md`
