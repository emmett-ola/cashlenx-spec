# Design Parity API Integration Backlog

## Purpose

This backlog prevents visual parity work from silently dropping product
capabilities. Each live-design surface is checked against both Flutter behavior
and `/api/v0` support. Items move into the named version only after its preceding
version closes.

## Capability Matrix

| Capability | App state | Server state | Selected boundary | Required outcome |
| --- | --- | --- | --- | --- |
| Transaction date range | Type/category/search filters exist. | `GET /cash/range` exists. | `v0.4.0` | Connect or equivalently filter the authoritative result, validate inclusive ranges, and retain demo parity. |
| Statistics and charts | Delivered in `v0.5.0`: typed yearly summary, monthly comparison, and top-expense adapters replace sample-only expanded reporting with loading/error/empty states. | Summary, breakdown, trends, top expenses, dashboard, and chart APIs exist. | Delivered `v0.5.0` | Retain typed real/demo adapters and extend to other existing chart endpoints only when a selected product surface needs them. |
| Budget CRUD | Delivered in `v0.5.0`: authenticated API and isolated demo CRUD, month navigation, derived usage, and recovery states. | Delivered in server `0.10.0`: user-scoped CRUD, OpenAPI, CLI, MongoDB indexes, and MySQL migrations. | Delivered `v0.5.0` | Preserve user isolation and dual-database parity in future changes. |
| User configuration | Delivered in `v0.6.0`: server startup reconciliation and writes coexist with local offline fallback and isolated demo state. | Authenticated user configuration CRUD persists all three preferences. | Delivered `v0.6.0` | Add a durable retry queue only with a selected offline-conflict policy. |
| Extended profile | Delivered in `v0.6.0`: phone, location, and birth date use real/demo persistence paths. | Delivered in server `0.11.0` across OpenAPI, CLI, MongoDB, and MySQL. | Delivered `v0.6.0` | Add nullable clear semantics in a future compatibility boundary if explicit field clearing is selected. |
| Transaction attachments | App and design expose an attachment affordance without persistence. | No upload/storage contract exists. | Post-parity contract version | Keep the affordance explicitly unavailable, prewire an attachment repository boundary, and select storage, size/type, authorization, deletion, and recovery rules before enabling it. |
| Export/import | No complete app workflow is selected. | User-scoped backup plus statistics XLSX/CSV/PDF export/import exist. | Unselected | Define mobile/web file handling and recovery UX before exposing the existing endpoints. |

## Delivery Rules

- A missing server capability is not replaced with prototype local storage for
  authenticated users.
- New persisted user data must be user-scoped and supported by both MongoDB and
  MySQL unless a version explicitly records a narrower compatibility decision.
- Demo mode receives an isolated in-memory equivalent and never calls
  authenticated APIs.
- A disabled affordance must state that it is unavailable; it must not imply a
  successful save.
- Every selected item needs positive, negative, authorization, compatibility,
  and recovery evidence appropriate to its data impact.

## Delivery Tooling Backlog

- Restore or replace `cashlenx-app/integration_test/api_smoke_test.dart`. The
  invalid wrapper that invoked the absent file was removed during deployment
  script consolidation, so no whole-product database smoke harness currently
  ships with the app.
  `v0.5.0` added and passed a focused disposable budget smoke for MongoDB and
  MySQL; broader registration/profile/import/export smoke remains a separate
  harness repair.

## Deferred Profile And Offline Semantics

- Select omitted-versus-null profile update semantics before enabling explicit
  clearing of optional profile fields. Current empty strings preserve the stored
  value for compatibility.
- Select conflict resolution, retry timing, and account-switch behavior before
  adding a durable offline queue for user configuration writes. Current local
  state remains usable and write failures are surfaced to the user.
