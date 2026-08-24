# Operations

This document owns current runtime, container, configuration-synchronization, and deployment-mechanics facts. Dated validation and deployment evidence belong in an opened version record or, before a version is opened, in the relevant backlog readiness record.

## Local Runtime

### Server

From `../cashlenx-server`:

```bash
cp .env.example .env
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
scripts/stop.sh
```

These scripts manage the server container only. `start.sh` uses the existing
image and waits for the Compose healthcheck. `stop.sh` removes the API container
and project network but preserves the image, bind-mounted logs, database
dependency projects, and their named volumes. Database dependency lifecycle
remains explicit and independent.

### App

From `../cashlenx-app`:

```bash
flutter pub get
flutter run
```

`.env` is listed as a Flutter asset and is required for app startup. Use
`.env.example` as the local template and do not commit real secrets.

## Runtime Project Boundaries

- The app has Docker-based Flutter web deployment through `Dockerfile`, `compose.yml`, nginx route fallback, and `scripts/build.sh`, `scripts/start.sh`, and `scripts/stop.sh`.
- The app GitHub Actions web-release workflow analyzes, tests, builds, and publishes static web output to the release repository.
- The server provides the same build/start/stop script contract and owns only the API container. MongoDB and MySQL are independent optional Compose projects under `docker/dependencies/`.
- The product-introduction website has a multi-stage Bun/nginx Docker image, Compose service, and the same build/start/stop script contract.
- In every runtime project, `build.sh` compiles the program inside its image build, `start.sh` starts or updates containers from an existing image with `--no-build --wait`, and `stop.sh` uses Compose `down --remove-orphans` without `--volumes` or image removal.
- Default host ports are `11063` for the server API, `11064` for the Flutter app web build, and `11065` for the product-introduction website. Environment files may override them.
- Default container names are `cashlenx-server`, `cashlenx-app`, and `cashlenx-website`.
- Project Compose files bind published ports to `127.0.0.1` by default for a host reverse proxy and expose configurable CPU, memory, PID, graceful-stop, and health settings.
- Runtime images record the source commit through the OCI `org.opencontainers.image.revision` label when built with the project scripts.

## Configuration Synchronization

- Each runtime repository ignores `.env*` and tracks only `.env.example` as its
  layered configuration catalog. Existing local variants remain untracked.
- `../scripts/sync-env.sh` owns workspace environment-template synchronization.
- Run it after changing any implementation `.env.example`; it appends missing keys to ignored local `.env` files without overwriting configured values.
- Each runtime project keeps ignored `.env.testing` and `.env.production` files for owner-managed sensitive deployment values. The synchronization workflow must not inspect or maintain their contents without explicit owner authorization.
- Runtime lifecycle scripts use `.env` by default and accept a repository-local
  override through `ENV_FILE`. They reject missing files, paths outside the
  repository, and symlinks. Build permits placeholders; start rejects active
  `CHANGE_ME` and known legacy weak values without printing their contents; stop
  requires the selected file but does not validate its values.

## Operational Endpoints

- The server exposes `/metrics` for Prometheus and development-only pprof endpoints when `ENV=dev`.
- Production deployments should restrict `/metrics` at the reverse proxy or firewall.

## UAT Deployment Mechanics

Build every affected image before starting services. In each affected project directory:

```bash
scripts/build.sh
scripts/start.sh
```

Start the server first, then the Flutter web app, then the product-introduction
website. Each `start.sh` waits for its project Compose healthcheck. To remove a
project's runtime container and network while retaining its image and persistent
data, run `scripts/stop.sh` in that project. Reverse-proxy routing and TLS remain
owned by the UAT host and are outside the project-local scripts.

This sequence describes mechanics only. Deployment authorization, target, implementation refs, results, and current deployment state require delivery evidence outside `system/`.
