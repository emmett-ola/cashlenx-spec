# Operations

This document owns current runtime, container, configuration-synchronization, and deployment-mechanics facts. Dated validation and deployment evidence belong in an opened version record or, before a version is opened, in the relevant backlog readiness record.

## Local Runtime

### Server

From `../cashlenx-server`:

```bash
cp .env.example .env
scripts/dependencies/mongodb/build.sh
scripts/dependencies/mongodb/start.sh
go run main.go open start -p 10063
```

Use MySQL 8 instead of MongoDB with:

```bash
scripts/dependencies/mysql/build.sh
scripts/dependencies/mysql/start.sh
```

For the project-owned server container flow:

```bash
scripts/build.sh
scripts/start.sh
scripts/stop.sh
```

The root scripts manage the server container only. `start.sh` uses the existing
image, ensures the shared external network exists, and waits for the Compose
healthcheck. `stop.sh` removes the API container but preserves the image,
bind-mounted logs, database dependency projects, and their named volumes. It
removes the shared network only when no containers remain attached. Database
dependency lifecycle remains explicit and independent.

MongoDB owns `docker/dependencies/mongodb/` and
`scripts/dependencies/mongodb/`; MySQL owns matching `mysql/` directories. Each
dependency exposes `build.sh`, `start.sh`, and `stop.sh`. Build pulls the
configured upstream image, start launches only that dependency on the shared
network and waits on an in-container readiness probe, and stop removes its
container while preserving its image and persistent storage. Each dependency
keeps its existing named volume by default. An empty `*_DATA_PATH` uses the
configurable `*_DATA_VOLUME_NAME`; an absolute data path selects a host bind mount. Root
Server scripts never select a dependency from `DB_TYPE` or manage dependency
lifecycle.

### App

From `../cashlenx-app`:

```bash
flutter pub get
flutter run
```

`.env` is listed as a Flutter asset and is required for app startup. Use
`.env.example` as the local template and do not commit real secrets.

## Environment Endpoints

| Environment | App | API |
| --- | --- | --- |
| Development | `http://127.0.0.1:10064` | `http://127.0.0.1:10063/api/v0` |
| Testing | `https://app.test.cashlenx.com` | `https://api.test.cashlenx.com/api/v0` |
| Production | `https://app.cashlenx.com` | `https://api.cashlenx.com/api/v0` |

Testing and production public endpoints are terminated and routed by their host
reverse proxy. Their project-local container ports remain independently
configurable and are not implied by the public HTTPS URLs.

## Runtime Project Boundaries

- Every Dockerfile and Compose definition lives under its owning repository's
  `docker/` tree. Dependency definitions remain under
  `docker/dependencies/<name>/`; root `.dockerignore` files remain beside their
  build contexts.
- The app has Docker-based Flutter web deployment through `docker/Dockerfile`, `docker/compose.yml`, nginx route fallback, and `scripts/build.sh`, `scripts/start.sh`, and `scripts/stop.sh`.
- The app GitHub Actions web-release workflow analyzes, tests, builds, and publishes static web output to the release repository.
- The server provides the same build/start/stop script contract and owns only the API container. MongoDB and MySQL are independent optional Compose projects under `docker/dependencies/`.
- MongoDB and MySQL each provide their own explicit build/start/stop scripts
  under `scripts/dependencies/`. They accept the same repository-local
  `ENV_FILE` selection and do not invoke the API lifecycle.
- The product-introduction website has a multi-stage Bun/nginx Docker image, Compose service, and the same build/start/stop script contract.
- In every runtime project, `build.sh` compiles the program inside its image
  build, `start.sh` starts or updates containers from an existing image with
  `--no-build` and then runs the service's readiness command inside the target
  container, and `stop.sh` uses Compose `down --remove-orphans` without
  `--volumes` or image removal. Start scripts do not require Compose `up --wait`
  or Compose-managed health status, so the lifecycle also works with compatible
  frontends such as nerdctl whose Compose surface omits those features.
- Compose project, container, and shared-network identities are explicit
  environment values with defaults. App, Server, Website, MongoDB, and MySQL
  each have an owning `*_PROJECT_NAME` and container-name key; all repositories
  use the same absolute `DOCKER_NETWORK_NAME`. Separate project identities
  preserve independent lifecycle and prevent `--remove-orphans` from treating
  sibling services as part of the same Compose project. Every start script
  creates the network idempotently. Every stop script attempts removal only
  after its own Compose project is down and only when Docker reports zero
  connected containers.
- Default development host ports are `10063` for the server API and `10064` for
  the Flutter app web build. The product-introduction website defaults to
  `11065`. Environment files may override them.
- Default container names are `cashlenx-server`, `cashlenx-app`, and `cashlenx-website`.
- Project Compose files bind published ports to `127.0.0.1` by default for a host reverse proxy and expose configurable CPU, memory, PID, graceful-stop, and health settings.
- Runtime images record the source commit through the OCI `org.opencontainers.image.revision` label when built with the project scripts.
- The Server image build performs no Alpine package installation. Go embeds the
  IANA timezone database, and the API healthcheck uses BusyBox `wget` already
  present in the selected Alpine runtime image, so Alpine package-index
  availability is not a Server image-build dependency.

## Configuration Synchronization

- Each runtime repository ignores `.env*` and tracks only `.env.example` as its
  explicit configuration catalog. Existing local variants remain untracked.
- Each `.env.example` documents accepted values, formats, units, and operational
  meaning where a key is not self-explanatory. Every assignment is active;
  operators change values directly rather than enabling configuration by
  uncommenting lines.
- Optional Server capabilities use explicit lowercase boolean settings such as
  `SMTP_ENABLED`. Disabled capability values remain present but are ignored by
  API startup validation. MongoDB/MySQL lifecycle has no enable flag: the
  selected dependency script determines which container project is managed.
- Server database URIs may reuse earlier atomic values with `${NAME}` so each
  username, password, and database name has one definition. Docker Compose and
  the Server dotenv loader expand this form; shell default expressions such as
  `${NAME:-default}` are not portable across both loaders.
- Direct local and Docker-specific MongoDB/MySQL URIs both derive credentials,
  ports, and database names from the same earlier atomic keys. Direct runtime
  routes use the published host ports; Docker routes use configured container
  names and internal ports on the shared network. Compose injects the Docker URI
  variables directly and does not rebuild them with credential, port, or
  database fallback constants.
- `../scripts/sync-env.sh` owns workspace environment-template synchronization.
- Run it after changing any implementation `.env.example`; it appends missing keys to ignored local `.env` files without overwriting configured values.
- Each runtime project may keep ignored `.env.local`, `.env.testing`, and
  `.env.production` files for owner-managed sensitive deployment values. The
  synchronization workflow must not inspect or maintain their contents without
  explicit owner authorization.
- Runtime lifecycle scripts use `.env` by default and accept a repository-local
  override through `ENV_FILE`. `.env` and an explicit `ENV_FILE` may be symbolic
  links when their fully resolved targets remain regular files inside the owning
  repository; broken links and links resolving outside the repository are
  rejected. Build permits placeholders; start rejects relevant `CHANGE_ME`,
  invalid booleans, and known legacy weak values without printing their contents.
  Server start validates only its selected database and enabled capabilities.
  Stop requires the selected file but does not validate values.
- Server dependency lifecycle scripts use the same file-selection boundary.
  Their starts validate only credentials owned by the selected dependency;
  their builds permit incomplete credentials and their stops remain available
  without credential validation.
- MongoDB and MySQL storage defaults remain the named volumes
  `cashlenx-mongodb-data` and `cashlenx-mysql-data`. Operators may change the
  matching `*_DATA_VOLUME_NAME`, or set an absolute `*_DATA_PATH` to use a host
  bind mount. Relative paths, filesystem roots, and parent traversal are
  rejected by dependency start. Changing the selected source does not copy,
  migrate, or delete data, and dependency stop preserves both storage forms.
- `TIMEZONE` is the only operator-facing Server timezone setting. Compose maps
  it to the API, MongoDB, and MySQL containers' standard `TZ` environment value.
  The supported contract is `UTC` or a region-based IANA name such as
  `Asia/Shanghai`. Every start entry point rejects fixed offsets, ambiguous
  abbreviations, and POSIX-sign `Etc/GMT` forms by key name before creating its
  container. API startup also verifies the name against the Go timezone
  database; Compose itself only passes the selected string through.

## Operational Endpoints

- The server exposes `/metrics` for Prometheus and development-only pprof endpoints when `ENV=dev`.
- Production deployments should restrict `/metrics` at the reverse proxy or firewall.

## UAT Deployment Mechanics

Build every affected image before starting services. In each affected project directory:

```bash
scripts/build.sh
scripts/start.sh
```

If the UAT database is project-managed, explicitly prepare and start the selected
dependency before the Server by running its dependency `build.sh` and
`start.sh`. Start the Server next, then the Flutter web app, then the
product-introduction website. Each `start.sh` waits for its project Compose
healthcheck. To remove a project's runtime container while retaining its image
and persistent data, run `scripts/stop.sh` in that project. The final stop also
removes the now-unused shared network.
Reverse-proxy routing and TLS remain owned by the UAT host and are outside the
project-local scripts.

This sequence describes mechanics only. Deployment authorization, target, implementation refs, results, and current deployment state require delivery evidence outside `system/`.
