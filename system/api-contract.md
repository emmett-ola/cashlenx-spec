# API Contract

## Current Version

- Public API path: `/api/v0`.
- Server default local base URL: `http://localhost:11063/api/v0`.
- The API path version is configurable through `API_VERSION`.

The detailed contract lives in `../cashlenx-server/docs/openapi.yaml`. This document is a human-readable summary.

## Response Shape

Most JSON endpoints respond through the shared response wrapper:

```json
{
  "code": "OK",
  "message": "",
  "data": {},
  "meta": {},
  "extra": {},
  "errors": []
}
```

File download endpoints may return binary content instead of the JSON wrapper.

## Authentication

Most non-open routes require:

```text
Authorization: Bearer <access_token>
```

Route groups:

- `/open/*`: public by convention.
- `/auth/tokens`: authenticated token-management API.
- `/admin/*`: authenticated admin API.
- `/user/*`, `/cash/*`, `/category/*`, `/budget/*`, and `/statistic/*`: authenticated user-scoped APIs.

`POST /open/auth/logout` is public and idempotent. It returns OK without credentials, revokes one session when a valid `refresh_token` is provided, and revokes all sessions when a valid bearer access token is provided without `refresh_token`.

## Operational Endpoints

Operational endpoints are mounted outside the versioned API:

- `GET /metrics`: Prometheus request counters, duration histograms, and Go runtime/process metrics.
- `/debug/pprof/*`: available only when `ENV=dev`.

These endpoints bypass JWT and OpenAPI validation. Production deployments should restrict `/metrics` to trusted monitoring networks, and pprof should not be registered outside development.

## Implemented Route Surface

### System And Auth

- `GET /open/health`
- `GET /open/version`
- `POST /open/auth/login`
- `POST /open/auth/register`
- `POST /open/verification/code`
- `POST /open/verification/verify`
- `POST /open/auth/logout`
- `GET /auth/tokens`
- `POST /open/auth/reset-password`
- `POST /open/auth/reset-password/confirm`

### User And Admin

- `GET /user/profile`
- `PUT /user/profile`
- `GET /user/configuration`
- `POST /user/configuration`
- `PUT /user/configuration`
- `PUT /user/password`
- `POST /user/email/change`
- `POST /user/email/confirm`
- `DELETE /user/account`
- `GET /user/database/backup`
- `POST /user/database/restore`
- `POST /admin/user`
- `GET /admin/user`
- `GET /admin/user/{id}`
- `PUT /admin/user/{id}`
- `DELETE /admin/user/{id}`
- `GET /admin/database/backup`
- `POST /admin/database/restore`

`PUT /user/profile` supports optional `nickname`, `avatar_url`, `gender`,
`phone_number`, `location`, and `birth_date`; non-empty birth dates use
`YYYY-MM-DD`. User configuration persists `display_language`, `currency_code`,
and `active_theme_color` per authenticated user.

### Cash Flow

- `POST /cash/expense`
- `POST /cash/income`
- `GET /cash`
- `GET /cash/range`
- `GET /cash/date/{date}`
- `DELETE /cash/date/{date}`
- `GET /cash/{id}`
- `PUT /cash/{id}`
- `DELETE /cash/{id}`
- `GET /cash/summary/total`
- `GET /cash/summary/daily/{date}`
- `GET /cash/summary/monthly/{month}`
- `GET /cash/summary/yearly/{year}`

### Category

- `POST /category`
- `GET /category`
- `GET /category/name/{name}`
- `GET /category/{parent_id}/children`
- `GET /category/tree`
- `GET /category/{id}`
- `PUT /category/{id}`
- `DELETE /category/{id}`

### Budget

- `POST /budget`
- `GET /budget?period=YYYY-MM`
- `GET /budget/{id}`
- `PUT /budget/{id}`
- `DELETE /budget/{id}`

Budgets are unique within the active user/category/period scope. Only expense
categories may be budgeted. List/get responses derive `spent_amount`,
`remaining`, and `progress` from user-owned cash flows rather than persisting
duplicate ledger totals.

### Statistics, Dashboard, Chart, Import, And Export

- `GET /statistic/export`
- `POST /statistic/import`
- `GET /statistic/summary/daily/{date}`
- `GET /statistic/summary/monthly/{month}`
- `GET /statistic/summary/yearly/{year}`
- `GET /statistic/breakdown/daily/{date}`
- `GET /statistic/breakdown/monthly/{month}`
- `GET /statistic/breakdown/yearly/{year}`
- `GET /statistic/trends/daily/{date}`
- `GET /statistic/trends/monthly/{month}`
- `GET /statistic/trends/yearly/{year}`
- `GET /statistic/top/daily/{date}`
- `GET /statistic/top/monthly/{month}`
- `GET /statistic/top/yearly/{year}`
- `GET /statistic/dashboard/{period}/{date}`
- `GET /statistic/chart/income-expense/{period}/{date}`
- `GET /statistic/chart/category-distribution/{period}/{date}`
- `GET /statistic/chart/monthly-comparison/{year}`
- `GET /statistic/chart/spending-heatmap/{year}`

## Client Integration Rules

The Flutter app builds its API base URL from `.env`:

- `API_SCHEME`
- `API_DOMAIN`
- `API_PORT`
- `API_VERSION`

The app sample target is `http://localhost:11063/api/v0`.

All app HTTP calls should go through:

- `ApiClient`
- `dioProvider`
- `CashlenxApi`

Backend error rendering in the app expects server errors such as:

```json
{"errors":[{"message":"..."}]}
```

## Maintenance Rules

- Keep `../cashlenx-server/docs/openapi.yaml` synchronized with route changes in `../cashlenx-server/controller/server.go`.
- Keep enum examples lowercase for cash/category types: `income` and `expense`.
- If this summary conflicts with OpenAPI or implementation code, verify the implementation and update this document.
