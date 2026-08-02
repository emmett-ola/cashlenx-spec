# Operations

This document owns current runtime, container, configuration-synchronization, and deployment-mechanics facts. Dated validation and deployment evidence belong in an opened version record or, before a version is opened, in the relevant backlog readiness record.

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

For the project-owned server container flow:

```bash
scripts/build.sh
scripts/start.sh
scripts/health.sh
```

These scripts manage the server container only. Database dependency lifecycle remains explicit and independent.

### App

From `../cashlenx-app`:

```bash
flutter pub get
flutter run
```

`.env` is listed as a Flutter asset and is required for app startup. Use `.env.sample` as the local template and do not commit real secrets.

## Runtime Project Boundaries

- The app has Docker-based Flutter web deployment through `Dockerfile`, `compose.yml`, nginx route fallback, and `scripts/build.sh`, `scripts/start.sh`, and `scripts/health.sh`.
- The app GitHub Actions web-release workflow analyzes, tests, builds, and publishes static web output to the release repository.
- The server provides the same build/start/health script contract and owns only the API container. MongoDB and MySQL are independent optional Compose projects under `docker/dependencies/`.
- The product-introduction website has a multi-stage Bun/nginx Docker image, Compose service, and the same build/start/health script contract.
- Default host ports are `11063` for the server API, `11064` for the Flutter app web build, and `11065` for the product-introduction website. Environment files may override them.
- Default container names are `cashlenx-server`, `cashlenx-app`, and `cashlenx-website`.
- Project Compose files bind published ports to `127.0.0.1` by default for a host reverse proxy and expose configurable CPU, memory, PID, graceful-stop, and health settings.
- Runtime images record the source commit through the OCI `org.opencontainers.image.revision` label when built with the project scripts.

## Configuration Synchronization

- `../scripts/sync-env.sh` owns workspace environment-template synchronization.
- Run it after changing any implementation `.env.sample`; it appends missing keys to ignored local `.env` files without overwriting configured values.
- Each runtime project keeps ignored `.env.testing` and `.env.production` files for owner-managed sensitive deployment values. The synchronization workflow must not inspect or maintain their contents without explicit owner authorization.

## Operational Endpoints

- The server exposes `/metrics` for Prometheus and development-only pprof endpoints when `ENV=dev`.
- Production deployments should restrict `/metrics` at the reverse proxy or firewall.

## UAT Deployment Mechanics

Build every affected image before starting services. In each affected project directory:

```bash
scripts/build.sh
scripts/start.sh
```

Start the server first, then the Flutter web app, then the product-introduction website. Each `start.sh` runs its project health check. Reverse-proxy routing and TLS remain owned by the UAT host and are outside the project-local scripts.

This sequence describes mechanics only. Deployment authorization, target, implementation refs, results, and current deployment state require delivery evidence outside `system/`.
