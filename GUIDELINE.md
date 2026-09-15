# CashLenX Engineering And Product Guideline

This is the reusable charter for CashLenX delivery. It records how to think about product, architecture, quality, and documentation. Execution workflow belongs in `WORKFLOW.md`, agent-enforced rules in `AGENTS.md`, current facts in `system/`, active versions and work in Jira, retained version evidence in `versions/`, durable decisions in `decisions/`, and deferred work in `backlog/`.

## 1. Evidence First

- Start from implementation code, OpenAPI contracts, tests, source docs, design reference, operations evidence, and explicit user decisions.
- Keep verified facts, reasonable inferences, and unresolved questions distinct.
- When evidence conflicts, preserve the conflict until resolved; update the canonical fact when a later verified decision supersedes it.
- Do not broaden exact routes, fields, enum values, auth semantics, security behavior, or release commitments while summarizing.

## 2. Strict Scope, Extensible Shape

- Implement and document only confirmed behavior.
- Keep unconfirmed finance features, analytics, import/export exposure, deployment models, and platform assumptions in `backlog/` until selected for a version.
- Preserve extensibility through clear domain ownership, stable names, versioned contracts, migrations, and small adapters.
- Unconfirmed sensitive behavior defaults to the narrowest safe scope, usually disabled, authenticated-only, or admin/management-only.
- Avoid scattering future ideas through current-fact documents; current-fact files describe what is true now.

## 3. One Owner Per Fact

- `system/` owns verified current product, domain, API, app, server, design, website, operations, and quality facts.
- `WORKFLOW.md` owns work levels, Human gates, evidence triggers, state semantics, and closeout flow.
- `backlog/` owns deferred scope, unopened delivery candidates, readiness work without a selected boundary, and unresolved questions.
- Jira project `CLX` owns selected product versions, executable work, priority, dependencies, acceptance criteria, and delivery state.
- `versions/` holds completed repository-local evidence and explicit closeout snapshots; it is not the active work tracker or current truth.
- `decisions/` owns durable decisions that should remain discoverable after a version closes.
- `sources/` contains copied source material from sibling projects. It is evidence input, not current truth by itself.
- `GUIDELINE.md` changes when reusable principles change; `AGENTS.md` changes when future agents need a different enforceable rule.
- Confluence owns maintained English instructions and shared context for users and developers, but it must link to canonical repository facts instead of becoming a duplicate technical specification.

## 4. Stable Boundaries

- Keep app, server, design reference, website, and spec as independent project areas.
- Respect each implementation repository's established architecture. Flutter work belongs in the owning feature and follows presentation-to-domain-to-data dependency direction; server work follows the HTTP/CLI entry layer, service, mapper, and database boundaries.
- Keep HTTP controllers and CLI commands as translation layers. Business behavior belongs in services, persistence behavior belongs in mappers, and shared API/CLI capabilities should not diverge into separate business rules.
- Centralize API base path and version configuration. Business API wrappers and route summaries should avoid duplicating version assumptions outside their configured boundary.
- Keep external JSON fields, API routes, environment variables, and enum examples exactly named.
- Preserve MongoDB and MySQL behavior for production-facing persistence changes unless a change is explicitly database-specific and that boundary is documented.
- Do not hand-edit generated Flutter files such as `*.g.dart` or `*.freezed.dart`; change their sources and regenerate them.
- Preserve implementation repositories as independently buildable and testable; documentation may describe them but must not become a runtime or build dependency.
- Use stable naming across Go, Dart, OpenAPI, database, and configuration boundaries.
- Remove obsolete placeholder notes and duplicate policy owners once their retained value is promoted into the canonical document.

## 5. Data, Configuration, And Security

- Treat migrations and OpenAPI as authoritative implementation evidence for persistence and API contracts.
- Preserve user-data isolation across every server layer: controllers derive identity from authenticated request context, services carry that identity, and mappers enforce user filters for user-owned records.
- Preserve soft-delete filters and audit metadata when changing entity queries or mutations. Administrator accounts are created only through the bootstrap path; normal creation and registration remain user-role operations, generic user updates cannot change roles, and administrator deletion remains blocked.
- Keep tracked environment templates free of secrets, and keep ignored local environment files structurally aligned without overwriting real local values.
- Environment-template synchronization is workspace coordination owned by `cashlenx-spec`, not runtime project functionality. After changing any project `.env.example`, run `cashlenx-spec/scripts/sync-env.sh` from the workspace so missing keys are added to ignored local `.env` files while existing configured values remain unchanged.
- `.env.testing` and `.env.production` are separate owner-managed sensitive deployment files. Keep them ignored and never inspect or synchronize their contents without explicit owner authorization.
- Never place credentials in tracked files or logs. Treat a potentially real exposed credential as compromised and rotate it before use.
- Keep token lifecycle, secure storage, CORS, operational endpoints, file import/export, backup/restore, and database restore behavior bounded by explicit authorization, error, validation, and audit assumptions before production use.
- Mock or demo data must be selected intentionally. API failures should expose loading, empty, error, retry, or unsupported states rather than silently substituting demo data.

## 6. Quality And Delivery

- Select only quality scenarios triggered by the change; not every task needs a broad release checklist.
- Test positive behavior and the first blocked, unauthorized, repeated, or failed path whenever the contract makes those cases relevant.
- Keep unit tests deterministic and isolated from real databases, files, email providers, clocks, randomness, and other external side effects through small seams and in-memory fakes. Run database and filesystem behavior through explicitly selected disposable integration or smoke checks.
- Treat normal package/unit suites and live integration coverage as separate evidence; passing `go test ./...` or Flutter widget tests does not prove the Docker-backed API/database flow.
- Treat project-owned compiler warnings, stale facts, broken links, exposed secrets, contradictory policy owners, and mismatched route summaries as defects.
- Keep workflow state separate from deployment state and report both accurately.
- Close work when its stated scope and evidence are complete; future scope belongs in `backlog/` or a new version.

## 7. Container And Lifecycle Governance

- Keep App, Server, Website, and database projects independently buildable and runnable. Cross-project rehearsal may orchestrate their public entry points but must not become a runtime or build dependency.
- Keep build, start, stop, validation, and publication as separate explicit operations. Start must use an already built candidate; stop must preserve images and persistent data unless an explicitly named destructive operation says otherwise.
- Prefer lockfile-driven multi-stage builds with reusable dependency layers and a minimal runtime image. Verify required runtime contents after every candidate build.
- Use an allowlist build context or equivalently complete exclusions. Environment files, credentials, Git state, logs, local data, caches, build outputs, and unrelated workspace files must not enter the Docker context or final image.
- Embed the selected semantic version and exact source revision in image and runtime metadata. Image tags alone are mutable pointers and are not sufficient provenance.
- Give every local rehearsal isolated project, container, network, port, volume, log, and test-data identities. Generate disposable secrets for the run and never reuse or inspect owner-managed Testing or Production configuration.
- Use explicit health/readiness checks, bounded resources, a graceful stop contract, deterministic dependency order, failure diagnostics, and safe rerun/teardown behavior.
- Test the same container and script contracts locally that future CI/CD will execute. CI integration changes the executor, not the acceptance semantics.

## 8. Database, Backup, And Release Evidence

- Give every database migration an immutable identity, deterministic order, checksum, applied-state record, and explicit fresh-install versus existing-install boundary. A dirty, missing, reordered, or modified applied migration fails closed.
- Keep runtime business logic independent from migration filenames and file enumeration. Migration delivery and execution are operational concerns with separate evidence.
- Classify each database change as forward-compatible, compatibility-breaking, destructive, repair, or baseline-only. Record existing-data behavior, repeat safety, rollout order, and rollback or forward-fix behavior before delivery.
- Run database contract tests and disposable fresh, repeat, upgrade, failure, and recovery scenarios for every supported engine affected by the change.
- Treat backup creation and restore success as separate evidence. A production-ready backup flow uses locking, an internally consistent snapshot, explicit format/version metadata, checksums, atomic publication, retention, failure notification, and scheduled disposable restore drills.
- Generate one checksummed release evidence manifest tied to exact source commits, artifacts, images, migrations, tests, and rehearsal results. Never include credentials or sensitive telemetry bodies.
- Keep implementation completion, candidate acceptance, tag creation, artifact publication, branch promotion, runtime deployment, database execution, and production acceptance as distinct recorded states.
