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

`AppConfig` consumes `APP_ENV`, `API_SCHEME`, `API_DOMAIN`, `API_PORT`, and
`API_VERSION` through compile-time definitions. The container build script
reads only those public settings from the selected repository-local environment
file. It does not send or copy that file into the build context or runtime
image. Direct Flutter runs may supply the same values with `--dart-define`; the
code defaults to the local development API when they are omitted.

## Environment Endpoints

| Environment | App | API |
| --- | --- | --- |
| Development | `http://127.0.0.1:10064` | `http://127.0.0.1:10063/api/v1` |
| Testing | `https://app.test.cashlenx.com` | `https://api.test.cashlenx.com/api/v1` |
| Production | `https://app.cashlenx.com` | `https://api.cashlenx.com/api/v1` |

Testing and production public endpoints are terminated and routed by their host
reverse proxy. Their project-local container ports remain independently
configurable and are not implied by the public HTTPS URLs.

## Runtime Project Boundaries

The selected topology, database-profile trade-offs, isolation boundary,
persistence behavior, rollback rules, and explicit exclusions are defined in
`deployment-profiles.md`. This document owns the concrete runtime mechanics and
configuration facts used by those profiles.

The approved `v1.0.0` production profile is a single node with one application
instance serving isolated users, MongoDB as the primary production database,
and MySQL as a required compatibility profile. Flutter Web is the certified
client distribution. Multi-instance orchestration, Kubernetes, Helm, shared
cache, and organization-level multi-tenancy are outside the stable boundary.
Local rehearsal, self-hosted production, and a cloud VM or container host must
use the same container contract. These are accepted targets; implementation and
acceptance evidence remain tracked in Jira until delivered.

- Every Dockerfile and Compose definition lives under its owning repository's
  `docker/` tree. Dependency definitions remain under
  `docker/dependencies/<name>/`; root `.dockerignore` files remain beside their
  build contexts.
- The app has Docker-based Flutter web deployment through `docker/Dockerfile`, `docker/compose.yml`, nginx route fallback, and `scripts/build.sh`, `scripts/start.sh`, and `scripts/stop.sh`.
- The app GitHub Actions workflow analyzes, tests, and builds the canonical web
  client. Its manual candidate job packages a verified image artifact without
  external publication or deployment.
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
- App, Server, and Website image build contexts use explicit allowlists. Local
  environment files, credentials, Git state, logs, local data, caches, build
  outputs, and unrelated workspace content do not enter their contexts.
- Each runtime repository owns digest-pinned build and runtime base-image
  references in `docker/images.env`. Updating a pin is an isolated change that
  must pass the repository build and image verification before delivery; a
  revert restores the previous inputs.
- Runtime images record the full source commit and normalized product version
  through the OCI `org.opencontainers.image.revision` and
  `org.opencontainers.image.version` labels. App and Website also expose a
  public `build-metadata.json`; Server embeds version, commit, and deterministic
  commit time in its executable.
- Each repository `scripts/build.sh` validates version and image inputs, builds
  from its lockfile, and then verifies required runtime assets, provenance
  metadata, and the absence of environment, credential, and Git files from the
  application payload. Invalid or missing inputs fail closed.
- Each runtime repository also owns `scripts/package-image.sh`. It requires a
  clean exact checkout whose source version matches `PRODUCT_VERSION`, invokes
  the verified image build, and emits an image archive, deterministic metadata,
  and a SHA-256 sidecar. Manual CI candidate jobs use these same secret-free
  entry points; they do not publish or deploy.
- Candidate packaging disables BuildKit's automatically generated default
  attestation because its run-specific metadata changes the manifest-list
  identity. Version, revision, input-set digest, image identity, and artifact
  checksum remain in deterministic metadata and the release manifest. Future
  CI may attach a signed external attestation to the accepted artifact digest
  without rebuilding or changing the artifact.
- The Server runtime image includes `docs/openapi.yaml` and
  `config/default_categories.json` alongside the executable. The App and
  Website runtime images contain only their nginx configuration and compiled
  static output.
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

- `METRICS_ENABLED` controls the unversioned Prometheus `/metrics` endpoint. It defaults to enabled outside production and disabled in production when omitted.
- Production may enable metrics only with a non-placeholder `METRICS_BEARER_TOKEN` of at least 32 characters. Monitoring callers send it as a Bearer token; network or reverse-proxy restrictions remain defense in depth.
- Pprof endpoints are registered only when `ENV=dev`.

## Production Request Security

- API startup validates configuration before database initialization. Production rejects weak or placeholder JWT/bootstrap credentials, non-HTTPS or wildcard CORS origins, invalid rate-limit values, and an enabled metrics endpoint without a strong token. Validation messages name keys without printing values.
- Production CORS is an exact HTTPS allowlist. Requests carrying a disallowed origin fail with `403 Forbidden`; development and test retain dynamic loopback-port support.
- `API_RATE_LIMIT_REQUESTS_PER_MINUTE` and `API_RATE_LIMIT_BURST` configure the in-process token bucket. Buckets use the direct TCP peer, so a host reverse proxy is treated as one aggregate peer. The ingress may enforce stricter public per-client limits but must not weaken the server guard.
- Request access logs omit query strings and record the escaped path only.

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

This sequence describes mechanics only. The standing authority in
`../decisions/0003-v1-product-deployment-and-autonomous-release-charter.md` may
cover a deployment after every applicable gate passes and the external target
and credentials are configured. Target, implementation refs, results,
migration state, and current deployment state still require separate evidence
outside `system/`.

For an isolated local production-like run from exact committed implementation
revisions, use the specification-owned delivery orchestrator:

```powershell
pwsh -File scripts/rehearsal.ps1 -Database all
```

The orchestrator creates detached clean worktrees so unrelated local changes do
not enter candidate images. It generates disposable production-mode
configuration and secrets, uses isolated project/container/network/port/volume
identities, builds through each repository's own entry point, starts local TLS
ingress, runs API and static-surface checks, restarts the database and verifies
persistence, performs encrypted backup and disposable restore, and writes a
checksummed secret-free manifest under `.artifacts/rehearsal/`. It never reads
Testing or Production environment files. Normal teardown removes only the
generated containers, network, volume, plaintext, and clean worktrees while
retaining the evidence manifest and candidate images for inspection or a warm
rerun.

For a coordinated, untagged release candidate from clean synchronized commits,
use:

```powershell
pwsh -File scripts/release-candidate.ps1
```

The candidate builder verifies App, Server, Website, OpenAPI, Spec, changelogs,
and release notes against `release/VERSION`; rejects an existing target tag;
packages exact clean commits twice; compares image identities plus image/source
artifact hashes; and writes one retained artifact set, `SHA256SUMS`, and a
checksummed secret-free manifest under `.artifacts/release-candidates/`. It reads
only tracked release inputs and `.env.example`, creates no tag, publishes
nothing, promotes no branch, deploys nothing, and records no secret. The tag,
publication, rollback, and future CI/CD handoff contract is in
`release/README.md`.

## Database-Level Data Protection

The Server owns `scripts/data-protection/backup.sh` and
`scripts/data-protection/restore-drill.sh`. These protect the complete selected
MongoDB or MySQL database, including migration state. They complement rather
than replace application JSON export/import.

The backup entry point accepts `daily`, `weekly`, or `monthly`, requires a
separate one-line passphrase file, checks destination safety and free capacity,
creates a consistent logical dump, writes metadata and internal checksums,
encrypts the package, and publishes an external SHA-256 sidecar atomically. It
prunes only matching completed artifacts inside the selected tier after a new
artifact succeeds. Defaults retain 7 daily, 4 weekly, and 12 monthly artifacts.

The deployment scheduler runs the daily tier every day, weekly and monthly tiers
in their selected windows, serializes runs, and alerts on a non-zero exit or a
stale secret-free `status/latest.json`. Backup storage, passphrase custody, and
notification delivery use failure domains separate from the application node.
The intended recovery point is 24 hours and the intended recovery time is 4
hours.

The restore-drill entry point verifies both checksum layers, decrypts into a
restricted temporary directory, rejects unsafe archive paths, restores into an
unnetworked disposable database container, verifies database objects and
migration state, emits secret-free JSON evidence, and removes the container and
plaintext on exit. Run it quarterly and after database, migration, encryption,
or backup-tool changes.

Capacity failure occurs before dumping. Dump, encryption, checksum, or publish
failure cannot prune prior completed backups. Missing or mismatched checksums,
wrong keys, corrupt input, missing migration state, and empty restores fail the
drill. A real production restore is intentionally not automated: it requires a
compatible recovery plan, verified artifact, rollback readiness, and explicit
authorization before production data is touched.

## MongoDB Migration State

MongoDB records ordered migration filename, SHA-256 checksum, dirty state, and
timestamps in the application database's `schema_migrations` collection. The
first tracked startup safely runs the idempotent sequence against either a fresh
or compatible existing installation. Dirty, unknown, reordered, renamed, or
modified history blocks API startup.

Deployment-level database or volume backups must include this collection.
Application JSON backup/restore intentionally preserves rather than replaces
schema history. Recover a dirty or incompatible installation from a verified
database backup, or use an explicitly reviewed data/index repair plan; do not
treat manual ledger edits as routine recovery.
