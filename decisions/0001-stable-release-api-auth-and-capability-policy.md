# 0001 Stable Release API, Auth, And Capability Policy

## Status

Accepted

## Context

`v1.0.0` is the first formal stable CashLenX release. Before implementation starts, the release needs durable decisions for API path, login semantics, session behavior, demo mode, and export/import exposure.

## Decision

- `v1.0.0` launches the stable API path under `/api/v1`.
- Stable login supports both username and email.
- Remember-me does not define a separate app-level expiry; refresh-token expiry controls remembered session lifetime.
- Logout keeps the existing backend-supported ability to revoke a specified session or all sessions.
- Demo mode remains a normal available feature with local demo data.
- Export/import remains a management capability and is not exposed as a normal app user workflow in `v1.0.0`.
- Budget is not part of `v1.0.0`; it is planned as a `v1.1.0` major feature.

## Consequences

- App, server, OpenAPI, website, and spec release docs must point stable users to `/api/v1`.
- The backend must support username and email login semantics before `v1.0.0` closes.
- The app should not implement an independent remember-me expiry timer.
- The app should keep demo mode visible and intentional.
- Export/import UI should not be added for normal app users in `v1.0.0`.
- Budget must not appear as an unfinished primary stable workflow in `v1.0.0`.

## References

- `../versions/README.md`
- `../backlog/README.md`
