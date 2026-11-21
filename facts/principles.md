# Engineering and product principles

These principles bind new work. The process that executes them is ASIDE's; the
facts they refer to live beside this file.

## Evidence first

- Start from implementation code, OpenAPI, tests, source documents, operational
  evidence, explicit owner decisions, and historical prototype evidence when it
  is relevant.
- Keep verified facts, reasonable inferences and unresolved questions distinct.
- When evidence conflicts, preserve the conflict until it is resolved; update the
  fact when a later verified decision supersedes it.
- Never widen an exact route, field, enum value, auth semantic, security
  behaviour or release commitment while summarizing it.

## Strict scope, extensible shape

- Implement and document only confirmed behaviour.
- Keep unconfirmed finance features, analytics, import/export exposure,
  deployment models and platform assumptions in `../backlog/` until selected.
- Preserve extensibility through clear domain ownership, stable names, versioned
  contracts, migrations and small adapters.
- Unconfirmed sensitive behaviour defaults to the narrowest safe scope, usually
  disabled, authenticated-only, or management-only.

## Stable boundaries

- App, server, website and spec stay independent project areas. The archived
  design prototype is historical evidence without parallel UI maintenance.
- Flutter work belongs in the owning feature and follows
  presentation → domain → data. Server work follows HTTP/CLI entry → service →
  mapper → database.
- Controllers and CLI commands are translation layers. Business behaviour belongs
  in services, persistence behaviour in mappers, and shared API/CLI capability
  must not fork into two business rules.
- Centralize the API base path and version configuration; business wrappers and
  route summaries do not restate version assumptions outside that boundary.
- Keep external JSON fields, API routes, environment variables and enum examples
  exactly named.
- Preserve MongoDB and MySQL behaviour for production-facing persistence changes
  unless the change is explicitly engine-specific and that boundary is written
  down.
- Never hand-edit generated Flutter files (`*.g.dart`, `*.freezed.dart`); change
  the source and regenerate.
- Documentation may describe implementation repositories but must never become a
  build or runtime dependency of them.

## Data, configuration and security

- Migrations and OpenAPI are authoritative implementation evidence for
  persistence and API contracts.
- Preserve user-data isolation in every server layer: controllers derive identity
  from authenticated request context, services carry it, mappers enforce the
  user filter on user-owned records.
- Preserve soft-delete filters and audit metadata when changing entity queries or
  mutations. Administrator accounts exist only through the bootstrap path; normal
  creation and registration stay user-role operations, generic updates cannot
  change roles, and administrator deletion stays blocked.
- Keep tracked environment templates free of secrets, and keep ignored local
  environment files structurally aligned without overwriting configured values.
- `.env.testing` and `.env.production` are owner-managed sensitive files: keep
  them ignored and never read, print, diff or synchronize their contents without
  explicit owner authorization for that exact access.
- Never place credentials in tracked files or logs.
- Keep token lifecycle, secure storage, CORS, operational endpoints, import and
  export, backup/restore and database restore behaviour bounded by explicit
  authorization, error, validation and audit assumptions before production use.
- Demo or mock data is selected intentionally. API failures surface loading,
  empty, error, retry or unsupported states instead of silently substituting demo
  data.

## Quality and delivery

- Select only the quality scenarios a change triggers; see
  `quality-attributes.md`.
- Test the positive behaviour and the first blocked, unauthorized, repeated or
  failed path whenever the contract makes those cases relevant.
- Keep unit tests deterministic and isolated from real databases, files, mail
  providers, clocks and randomness through small seams and in-memory fakes. Run
  database and filesystem behaviour through explicitly selected disposable
  integration or smoke checks.
- Package/unit suites and live integration coverage are separate evidence.
  Passing `go test ./...` or Flutter widget tests does not prove the
  Docker-backed API and database flow.
- Project-owned compiler warnings, stale facts, broken links, exposed secrets,
  contradictory policy owners and mismatched route summaries are defects.
- Keep workflow state, branch state, publication state and deployment state
  separate, and report each accurately: App and Website publish through CI and
  their platform integration, and the Server is started by the owner's own
  lifecycle scripts on the Linux host.
- Keep active automation portable through Bash, with Zsh as an interactive
  caller when useful. PowerShell or `pwsh` is never a delivery dependency.
- Coordinate product versions centrally while App, Server and Website runtime
  versions may differ. Advance only the repositories whose behaviour or artifact
  changes, and record retained component versions in the version's evidence.

## Containers and lifecycle

- App, Server, Website and the databases stay independently buildable and
  runnable. Cross-project rehearsal may orchestrate their public entry points but
  never becomes a runtime or build dependency.
- Build, start, stop, validation and publication are separate explicit
  operations. Start uses an already built candidate; stop preserves images and
  persistent data unless an explicitly named destructive operation says
  otherwise.
- Prefer lockfile-driven multi-stage builds with reusable dependency layers and a
  minimal runtime image, and verify required runtime contents after every
  candidate build.
- Use an allowlist build context or equally complete exclusions: environment
  files, credentials, Git state, logs, local data, caches, build outputs and
  unrelated workspace files never enter the Docker context or the final image.
- Embed the selected semantic version and exact source revision in image and
  runtime metadata. Image tags are mutable pointers, not provenance.
- Give every local rehearsal isolated project, container, network, port, volume,
  log and test-data identities, generate disposable secrets, and never reuse or
  inspect owner-managed Testing or Production configuration.
- Use explicit health/readiness checks, bounded resources, a graceful stop
  contract, deterministic dependency order, failure diagnostics and safe
  rerun/teardown.
- Test locally the same container and script contracts CI/CD will execute. CI
  changes the executor, not the acceptance semantics.

## Database and release evidence

- Every migration has an immutable identity, deterministic order, checksum,
  applied-state record, and an explicit fresh-install versus existing-install
  boundary. A dirty, missing, reordered or modified applied migration fails
  closed.
- Business logic stays independent of migration filenames and file enumeration;
  migration delivery and execution are operational concerns with their own
  evidence.
- Classify each database change as forward-compatible, compatibility-breaking,
  destructive, repair or baseline-only, and record existing-data behaviour,
  repeat safety, rollout order and rollback or forward-fix behaviour before
  delivery.
- Run database contract tests plus disposable fresh, repeat, upgrade, failure and
  recovery scenarios for every supported engine the change affects.
- Backup creation and restore success are separate evidence. A production-ready
  backup flow uses locking, an internally consistent snapshot, explicit
  format/version metadata, checksums, atomic publication, retention, failure
  notification and scheduled disposable restore drills.
- Produce one checksummed release evidence manifest tied to exact source commits,
  artifacts, images, migrations, tests and rehearsal results, containing no
  credentials or sensitive telemetry bodies.
- Implementation completion, candidate acceptance, tag creation, artifact
  publication, branch promotion, runtime deployment, database execution and
  production acceptance are distinct recorded states.
