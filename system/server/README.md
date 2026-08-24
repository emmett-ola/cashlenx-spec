# Server

## Snapshot

`../cashlenx-server` is the Go backend for CashLenX. It exposes a Cobra CLI and a Gorilla Mux REST API for authentication, user accounts, cash flows, categories, monthly budgets, statistics, import/export, and admin database management.

Current stack:

- Runtime contract version `0.11.0` on the `/api/v0` path.
- Go `1.23.0`.
- Cobra CLI.
- Gorilla Mux HTTP routing.
- Gin remains a direct dependency only for legacy response helpers; it is not the active router.
- Zap logging utilities.
- MongoDB and MySQL drivers.
- JWT via `github.com/golang-jwt/jwt/v5`.
- `shopspring/decimal` for money values.
- `excelize` and `gofpdf` for exports.
- OpenAPI validation through `kin-openapi`.
- Prometheus instrumentation.

## Entry Points

- `main.go`: calls `cmd.Execute()`.
- `cmd/root.go`: wires the CLI and initializes the MongoDB pool in `PersistentPreRun`.
- `cmd/cli_auth/auth.go`: owns CLI session persistence, authorization helpers, and refresh behavior.
- `cmd/open_cmd/start.go`: starts the HTTP server with `controller.StartServer(port)`.
- `controller/server.go`: registers versioned API routes under `/api/{version}`.
- `docs/openapi.yaml`: detailed OpenAPI contract.

Start the local API server with:

```bash
go run main.go open start -p 11063
```

Local API base URL:

```text
http://localhost:11063/api/v0
```

## Repository Layout

```text
cashlenx-server/
  auth/         # Auth service/provider abstraction.
  cache/        # Cache helpers.
  cmd/          # Cobra commands.
  config/       # Runtime data files.
  controller/   # HTTP route registration and handlers.
  docker/       # Database initialization assets.
  docs/         # API, CLI, OpenAPI, roadmap docs.
  errors/       # Custom error types.
  mapper/       # MongoDB/MySQL persistence mappers.
  middleware/   # Auth, admin, CORS, logging, schema validation.
  migrations/   # MongoDB/MySQL migration scripts.
  model/        # Entities, DTOs, response types, constants.
  scripts/      # Start and docs helper scripts.
  service/      # Business logic.
  test/         # Sparse test and log area.
  util/         # Config, logging, DB, email, date, ID, HTTP helpers.
  validation/   # Validation helpers and tests.
```

## Current Implemented Behavior

- User registration and login.
- JWT access tokens and persisted refresh tokens.
- Password reset using verification codes.
- Purpose-scoped email verification for sign-up, password reset, and email change.
- User profile query/update, configuration query/create/update, password change, email change request/confirm, and account deletion.
- Admin bootstrap user initialization on server startup.
- Cash flow CRUD, date/range queries, summaries, pagination, and filtering.
- Category CRUD plus tree, children, and name lookup.
- User-scoped monthly budget CRUD. Limits persist per expense category and
  `YYYY-MM` period; spent, remaining, and progress values are derived from the
  authoritative cash-flow ledger.
- Statistics summary, breakdown, trends, top expenses, dashboard, and chart endpoints.
- User-scoped export/import backup flows.
- Admin user management and full database backup/restore.
- Backup/restore preflight validation and progress reporting.
- Compensating rollback for destructive admin restore and versioned MySQL migrations; failed migration compensation retains dirty state and blocks startup.
- MySQL migration tracking and startup migration application.
- SMTP email utility for verification-related delivery.
- Snowflake ID generator initialization for distributed IDs.

## Architecture And Entry Layers

The primary server path is:

```text
HTTP -> Controller -> Service -> Mapper -> Database
```

- Cobra commands under `cmd/` and Gorilla Mux handlers under `controller/` are the two entry layers.
- Controllers translate requests into service calls and take authenticated identity and role from middleware context.
- CLI commands translate flags and saved CLI session context into the same request shapes and service behavior. Non-open commands centralize session checks in `cmd/cli_auth`.
- CLI-only behavior is limited to terminal output, prompts, local file paths, and session persistence.
- When an API request field or query parameter also has a CLI surface, the matching CLI flag should mirror it.
- Route or command shape changes must keep `controller/server.go`, `docs/openapi.yaml`, `docs/api.md`, and `docs/cli.md` aligned.

Supporting ownership:

- `middleware/` owns request authentication, administrator checks, CORS, request logging, metrics, and OpenAPI validation.
- `auth/` owns token creation and authentication middleware delegation.
- `validation/validators.go` owns shared request validators.
- `config/default_categories.json` owns the built-in category seed data.

## CLI Structure

High-level command groups:

- `open`: `start`, `health`, `version`, public auth, and verification commands.
- `auth`: token-management commands.
- `admin`: user management and database backup/restore.
- `user`: profile, configuration, password, email, account, and database operations.
- `cash`: expense, income, list, query, range, summary, update, and delete.
- `category`: create, list, query, tree, update, and delete.
- `budget`: create, list, get, update, and delete monthly category budgets.
- `statistic`: summary, breakdown, trends, top, dashboard, chart, export, and import.

The server start command is `go run main.go open start -p 11063`, not `server start`.

## Persistence

- MongoDB is the default development database.
- MySQL 8 is also runnable and covered by disposable smoke validation.
- Production-facing mapper behavior is expected for both backends unless a change is explicitly database-specific.
- Current mapper owners include cash flow, category, budget, user, user configuration, refresh token, and operation confirmation code packages. Mapper packages select the active implementation by database type.
- Core entities use soft deletion through `is_delete` and audit metadata. Normal queries must continue to exclude deleted records unless an administrative backup or another explicit include-deleted operation requires them.
- Independent MongoDB and MySQL projects own Compose, initialization assets, and
  build/start/stop scripts under database-specific `docker/dependencies/` and
  `scripts/dependencies/` directories. Their named
  `cashlenx-mongodb-data` and `cashlenx-mysql-data` volumes survive dependency
  stop. Root Server scripts manage only the API and never select a dependency
  from `DB_TYPE`.
- MongoDB applied-version tracking is not implemented and remains architecture debt.

Persistence-shape changes must account for mapper code, migrations, Docker initialization assets when applicable, and backup/restore or import/export formats.

## Security-Critical Behavior

- User-owned cash flows, categories, configuration, and exports are scoped by authenticated user identity through controller, service, and mapper layers.
- Admin routes use `middleware.Admin`, which reads the `role` set by authentication middleware.
- Administrator users are created only by `user_service.InitAdminUser()` when no administrator exists.
- Registration and user-management creation always create the `user` role even if input requests `admin`.
- Generic user updates cannot promote or demote roles, and user deletion rejects administrator accounts.
- Password changes and account deletion revoke persisted refresh tokens.

## Middleware And Operational Surface

API traffic is wrapped in this order:

```text
CORS -> Logging -> Metrics -> Auth -> OpenAPI schema validation -> Router
```

- CORS stays outermost so browser preflight requests are answered before authentication or schema validation.
- Logging preserves or creates `X-Request-ID`, echoes it in responses, stores it in request context, and includes it in structured logs.
- `/api/{version}/open/*` bypasses required authentication. `POST /open/auth/logout` performs optional token handling in its controller and remains public and idempotent.
- `GET /metrics` is unversioned and outside JWT/OpenAPI middleware. `/debug/pprof/*` is registered only when `ENV=dev`.
- In development and test, loopback browser origins may use dynamic ports. Production uses explicit `CORS_ORIGINS` values.

## Configuration Boundaries

- Runtime configuration is loaded from `.env` and process environment through `util/config_util.go`.
- Database URI values may reference atomic values defined earlier with `${NAME}`;
  both Docker Compose and the current dotenv loader expand that form.
- Every Server example assignment is active. Optional capabilities use explicit
  lowercase booleans; API startup validation ignores disabled capabilities and
  unselected database credentials. Dependency script selection, rather than an
  enable flag or `DB_TYPE`, owns database-container lifecycle.
- `TIMEZONE` is the single application and container timezone source; Compose
  maps it to the standard container `TZ` variable, and the Server runtime image
  includes IANA timezone data.
- Database connection values map to internal keys `db.mongodb.url` and `db.mysql.url`; legacy `mongodb.uri` and `mysql.uri` keys are not registered.
- API version, schema validation, authentication lifetime, registration, bootstrap administrator, CORS, host/port, timezone, Snowflake worker, verification-code, SMTP, logging, and database selection are configuration-owned behaviors.
- Automated registration and password-reset tests must replace email delivery and must not contact a real provider.

## Standard Validation

See `../testing.md` for the canonical server build, unit, migration, and disposable database/API smoke commands and their evidence boundaries.
