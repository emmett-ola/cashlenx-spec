# Server

## Snapshot

`../cashlenx-server` is the Go backend for CashLenX. It exposes a Cobra CLI and a Gorilla Mux REST API for authentication, user accounts, cash flows, categories, statistics, import/export, and admin database management.

Current stack:

- Go `1.23.0`.
- Cobra CLI.
- Gorilla Mux HTTP routing.
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
- Statistics summary, breakdown, trends, top expenses, dashboard, and chart endpoints.
- User-scoped export/import backup flows.
- Admin user management and full database backup/restore.
- Backup/restore preflight validation and progress reporting.
- MySQL migration tracking and startup migration application.
- SMTP email utility for verification-related delivery.
- Snowflake ID generator initialization for distributed IDs.

## CLI Structure

High-level command groups:

- `open`: `start`, `health`, `version`, public auth, and verification commands.
- `auth`: token-management commands.
- `admin`: user management and database backup/restore.
- `user`: profile, configuration, password, email, account, and database operations.
- `cash`: expense, income, list, query, range, summary, update, and delete.
- `category`: create, list, query, tree, update, and delete.
- `statistic`: summary, breakdown, trends, top, dashboard, chart, export, and import.

The server start command is `go run main.go open start -p 11063`, not `server start`.

## Persistence

- MongoDB is the default development database.
- MySQL 8 is also runnable and covered by disposable smoke validation.
- Independent MongoDB and MySQL Compose projects store data in the named `cashlenx-mongodb-data` and `cashlenx-mysql-data` volumes. Server build/start scripts do not manage dependency lifecycle.
- MongoDB applied-version tracking is not implemented and remains architecture debt.

## Standard Validation

```bash
go build -o cashlenx main.go
go test ./...
scripts/ci-test.sh
```

The sibling Flutter client owns the end-to-end database smoke flow through `../cashlenx-app/scripts/smoke-api.ps1`.
