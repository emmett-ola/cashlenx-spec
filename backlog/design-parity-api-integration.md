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
| User configuration | Currency, language, and theme are app-local. | Authenticated user configuration CRUD already supports these preferences. | `v0.6.0` | Reconcile local startup state with server configuration without breaking offline/demo behavior. |
| Extended profile | Phone, location, and birth date appear in presentation but are not persisted. | Profile update supports nickname, avatar, and gender only. | `v0.6.0` | Add optional typed fields across schema, both persistence backends, OpenAPI/CLI, and Flutter, or remove edit affordances until the same version delivers the contract. |
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
  existing `scripts/smoke-api.ps1` invokes that absent file, so it is not valid
  current evidence for the documented whole-product database smoke flow.
  `v0.5.0` added and passed a focused disposable budget smoke for MongoDB and
  MySQL; broader registration/profile/import/export smoke remains a separate
  harness repair.
