# Operations And Testing

## Local Runtime

### Server

From `../cashlenx-server`:

```bash
cp .env.sample .env
docker compose --env-file .env -f docker/dependencies/compose.mongodb.yml up -d --wait
go run main.go open start -p 11063
```

Use MySQL 8 instead of MongoDB with:

```bash
docker compose --env-file .env -f docker/dependencies/compose.mysql.yml up -d --wait
```

### App

From `../cashlenx-app`:

```bash
flutter pub get
flutter analyze
flutter test
```

`.env` is listed as a Flutter asset and is required for app startup. Use `.env.sample` as the local template. Do not commit real secrets.

## Deployment Notes

- The app has Docker-based Flutter web deployment through `Dockerfile`, `compose.yml`, nginx route fallback, and `scripts/build.sh`, `scripts/start.sh`, and `scripts/health.sh`.
- The app has a GitHub Actions web release workflow that builds, analyzes, tests, and publishes static web output to the release repository.
- The server provides the same build/start/health script contract and owns only the API container. MongoDB and MySQL are independent optional Compose projects under `docker/dependencies/`; server scripts do not start, stop, or remove them.
- The product-introduction website has a multi-stage Bun/nginx Docker image, Compose service, and the same build/start/health script contract. Its default host port is `11065`.
- Default host ports are `11063` for the server API, `11064` for the Flutter app web build, and `11065` for the product-introduction website. Environment files may override these published ports.
- Default container names follow their projects: `cashlenx-server`, `cashlenx-app`, and `cashlenx-website`.
- Project Compose files bind published ports to `127.0.0.1` by default for a host reverse proxy and expose configurable CPU, memory, PID, graceful-stop, and container-health settings.
- Runtime images record the source commit through the OCI `org.opencontainers.image.revision` label when built with the project scripts.
- `cashlenx-spec/scripts/sync-env.sh` owns workspace environment-template synchronization. Run it after changing any implementation `.env.sample`; it appends missing keys to ignored local `.env` files without overwriting configured values.
- Each runtime project keeps ignored `.env.testing` and `.env.production` files for owner-managed sensitive deployment values. They are initialized from `.env.sample` but are not read or maintained by the synchronization workflow without explicit owner authorization.
- The server exposes `/metrics` for Prometheus and development-only pprof endpoints when `ENV=dev`.
- Production deployments should restrict `/metrics` at the reverse proxy or firewall.
- The project owner reports that the current app/server flow is deployed to a UAT environment and works there.
- Treat this as deployment state `Testing`; it does not establish production deployment or replace recorded automated validation evidence.
- Local dependency validation on `2026-07-30` confirmed that the standalone `cashlenx-mongodb` project creates its dedicated network and `cashlenx-mongodb-data` volume, reaches healthy status, and accepts an authenticated ping. The standalone MySQL project was configured but not started in that check.

### UAT Deployment Sequence

In each affected project directory:

```bash
scripts/build.sh
scripts/start.sh
```

Build all affected images before starting any of them. Start the server first,
then the Flutter web app, then the product-introduction website. Each `start.sh` runs
its project health check. Reverse-proxy routing and TLS remain owned by the UAT
host and are outside these project-local scripts.

## Validation Commands

### Spec

When Git metadata and write access are available:

```bash
git diff --check
```

### App

```bash
flutter analyze
flutter test
```

Disposable live Flutter-to-server smoke flow on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1
```

Use MySQL 8:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1 -Database mysql
```

The smoke flow starts disposable database and API instances, seeds verification records directly, and runs `integration_test/api_smoke_test.dart` without sending email or retaining test data.

### Server

```bash
go build -o cashlenx main.go
go test ./...
scripts/ci-test.sh
```

## Testing Strategy

- Unit test pure Dart behavior, DTO parsing, repositories with fake data sources, storage policy, and helpers.
- Test infrastructure contracts for HTTP error mapping, error-message resolution, request tracking, route redirect policy, and persistence adapters.
- Test auth provider states including logged-out startup, remember-me refresh success/failure, login success/failure, logout, password-reset request, and password-reset confirm.
- Keep widget tests behind fake repositories/data sources unless explicitly running integration checks.
- Do not make widget tests depend on a live API server.
- Live integration coverage should include registration, login, refresh, logout, profile, cash flow, category, statistics, XLSX import, CSV/XLSX export, backup, password reset, and admin APIs.
