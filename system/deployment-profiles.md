# Deployment Profiles

This document defines the supported CashLenX `v1.0.0` deployment shapes. It
turns the accepted deployment decision into an operator-facing contract without
coupling the independently buildable runtime repositories.

## Selected Profiles

| Profile | Intended use | Database | Status |
| --- | --- | --- | --- |
| Single-node MongoDB | Personal self-hosting or a shared service for multiple isolated users | MongoDB 7 | Primary production profile |
| Single-node MySQL | The same application topology where MySQL compatibility is required | MySQL 8 | Required compatibility profile |

Both profiles use one node and exactly one API application instance. The same
API is multi-user capable in both cases. A private installation with one intended
user and a shared installation with several users are operating modes of the
same topology, not different tenancy architectures.

CashLenX does not provide organization, workspace, or tenant administration in
`v1.0.0`. User isolation is enforced by authentication plus user-scoped service
and persistence operations inside one logical application database. The
bootstrap administrator remains an installation-wide operator role, so this
boundary must not be represented as hostile-tenant isolation.

## Node Layout

The supported node contains independent container projects joined to one
explicit external bridge network:

| Component | Required | Responsibility |
| --- | --- | --- |
| Host ingress | Production only | TLS termination, public routing, request-size policy, and any stricter public rate limits |
| Flutter Web app | Yes | Certified user client; published to loopback for the host ingress |
| API server | Yes | Authentication, authorization, business rules, migrations, and operational endpoints |
| MongoDB or MySQL | Yes | Exactly one selected persistent database project |
| Product website | Optional | Public information surface; it has no runtime dependency on the app or API |
| SMTP service | Capability-dependent | External vendor-neutral SMTP in deployed environments; disposable mail capture in local rehearsal |

The App, Server, Website, MongoDB, and MySQL projects retain distinct Compose
project names, containers, images, lifecycle scripts, and environment files.
They share only the configured `DOCKER_NETWORK_NAME`. Starting or stopping one
project must not implicitly start, stop, rebuild, or remove another project.

Production ports remain bound to `127.0.0.1` by default. The host ingress owns
public HTTPS and routes the configured App and API hostnames to those loopback
ports. Direct public publication of the database ports is unsupported.

## Reproducible Lifecycle

Build each selected image before starting any service. For a project-managed
database, use this order:

1. Build and start the selected MongoDB or MySQL dependency from the Server
   repository.
2. Build and start the API server.
3. Build and start the Flutter Web app.
4. Build and start the optional product website.
5. Configure the host ingress and verify HTTPS routing, API health, and the Web
   deep-link fallback.

Every runtime project uses `scripts/build.sh`, `scripts/start.sh`, and
`scripts/stop.sh`. Database dependencies expose the same verbs under
`scripts/dependencies/<database>/`. Start consumes an already built image and
waits for an in-container readiness command. Stop removes only the owning
Compose project and preserves images, logs, and database storage.

The selected repository-local `ENV_FILE` is an input, not an artifact. It must
resolve inside its owning repository. Environment files, credentials, Git
state, local data, logs, and unrelated workspace content remain outside build
contexts and runtime images. App API settings are public build-time values;
Server and database credentials remain runtime-only values.

Local rehearsal, self-hosted production, and a cloud VM or container host use
this same lifecycle and container boundary. A platform-specific orchestration
layer is not part of the contract.

## Profile Configuration

### MongoDB Primary

- Set `DB_TYPE=mongodb` for the API.
- Start only the MongoDB dependency project.
- Route the API through `DOCKER_MONGO_DB_URI` on the shared network.
- Keep the `schema_migrations` collection in every database-level backup.
- Treat dirty, missing, reordered, renamed, or checksum-modified migration
  history as a failed deployment rather than editing the ledger manually.

### MySQL Compatibility

- Set `DB_TYPE=mysql` for the API.
- Start only the MySQL dependency project.
- Route the API through `DOCKER_MYSQL_DB_URI` on the shared network.
- Preserve the numbered migration history and fail closed on dirty or
  incompatible state.
- Use this profile for compatibility acceptance; it does not replace MongoDB
  as the primary production recommendation.

Running MongoDB and MySQL simultaneously is useful for isolated test jobs but is
not a supported application profile. One API instance selects exactly one
database engine.

## Isolation And Capacity Boundary

- The API derives the acting user from authenticated request context and the
  persistence layer applies user filters to user-owned data.
- Browser origins are an exact HTTPS allowlist in production.
- Logs must not expose tokens, credentials, verification codes, or full request
  query strings.
- The in-process rate limiter is an aggregate safety circuit when a reverse
  proxy is the direct peer. The ingress may enforce stricter public limits.
- `SNOWFLAKE_WORKER_ID=0` is appropriate for the single API instance. A second
  concurrent API instance is outside the profile and must not be introduced by
  changing only this value.
- CPU, memory, PID, healthcheck, and graceful-stop settings are configurable per
  project. Capacity is increased vertically on the one node; horizontal scaling
  requires a new architecture decision and acceptance evidence.

## Persistence, Backup, And Rollback

MongoDB and MySQL use named volumes by default. An absolute host path may be
selected for a bind mount. Changing a volume name or bind path selects different
storage; it does not migrate, copy, or delete existing data. Project stop scripts
never remove either storage form.

The production recovery policy is encrypted daily backup with 7 daily, 4
weekly, and 12 monthly restore points, failure notification, and a quarterly
disposable restore drill. The target recovery point is 24 hours and the target
recovery time is 4 hours. Server-owned operator tooling creates encrypted
database-level artifacts, prunes completed artifacts by tier, rejects corrupt
input, and emits disposable restore-drill evidence for MongoDB and MySQL.
Scheduler installation, off-node storage, encryption-key custody, notification
delivery, capacity monitoring, and quarterly execution remain deployment-owned.

Application rollback means returning the App, API, or Website to a previously
verified immutable image while preserving the selected database storage. It is
safe only when the database state remains compatible with the earlier API.
Forward-compatible migrations are not automatically reversed. A destructive or
compatibility-breaking data change requires a specific migration and recovery
plan plus a new Human decision before production execution.

If startup fails before a compatible migration completes, keep the last known
good image and database backup available. Do not treat container recreation,
volume replacement, or manual migration-ledger edits as rollback.

## Observability And Acceptance

- The App, API, Website, and selected database must pass their project-owned
  readiness checks after start and restart.
- API metrics are disabled in production unless explicitly enabled with a
  strong bearer token; network restriction remains defense in depth.
- Pprof is development-only.
- Container and host logs, resource usage, storage capacity, backup results, and
  TLS expiry remain operator responsibilities.
- Release rehearsal must verify ingress, health, restart, graceful shutdown,
  persistence, backup and restore, failure behavior, and safe teardown with
  disposable secrets and isolated names.

## Unsupported Topologies

The following are outside the `v1.0.0` support boundary:

- multiple concurrent API application instances;
- Kubernetes, Helm, or another cluster scheduler;
- shared or distributed application cache;
- database clustering, sharding, or automatic cross-node failover;
- organization-level tenants, workspaces, tenant administrators, or tenant data
  placement controls;
- direct public database exposure;
- mixing MongoDB and MySQL behind one API instance;
- treating preview native clients as production-certified distributions.

These are not forbidden future directions. Each requires an explicit selected
scope, threat and failure analysis, migration or compatibility plan where
applicable, and new acceptance evidence.

## Trade-off Record

| Option | Benefit | Cost or risk | Decision |
| --- | --- | --- | --- |
| One private instance per user | Simple operational ownership and small blast radius | Repeats infrastructure for every user | Supported through the same single-node profile |
| One shared instance for several users | Better resource utilization and centralized operation | Operator-wide admin trust and a larger shared blast radius | Supported through application user isolation |
| Multiple API replicas | Availability and horizontal capacity | Requires shared state, worker-ID coordination, ingress balancing, and failover evidence | Deferred |
| Kubernetes or Helm | Standard cluster primitives | Adds an unneeded orchestration and support surface for the selected scale | Deferred |
| Organization-level multi-tenancy | Business-account administration and policy boundaries | Requires a new domain model, authorization model, and migration | Deferred |

The selected profiles are the smallest shapes that match the implemented
multi-user product while remaining reproducible across local rehearsal,
self-hosting, and a single cloud host.
