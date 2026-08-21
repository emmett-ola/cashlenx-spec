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
| Statistics and charts | Dashboard uses real data, but expanded statistics still presents samples. | Summary, breakdown, trends, top expenses, dashboard, and chart APIs exist. | `v0.5.0` | Add typed app adapters/providers and replace sample-only reporting while retaining explicit loading/error/empty states. |
| Budget CRUD | Summary UI exists; mutations are coming-soon placeholders. | No budget routes, model, mapper, or service exists. | `v0.5.0` | Define `/api/v0/budget` contracts, implement user-scoped CRUD for MongoDB and MySQL, document OpenAPI/CLI behavior, connect Flutter and demo repositories, and test ownership and validation. |
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
