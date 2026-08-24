# v0.8.9 Shared Docker Network And Layout

## Status

- Version: `v0.8.9`
- State: Closed
- Work Level: Standard
- Execution Owner: AI
- Validation Owner: AI
- Validated At: `2026-08-24`
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: `2026-08-24`
- Target: Shared container connectivity and project-local Docker layout
- Affected project areas: app, server, website, spec
- Resulting runtime/displayed versions: app `0.7.0+7`, server `0.11.0`, and
  website `0.1.0` (unchanged because this delivery changes deployment structure
  only)

## Task Contract

- Goal: Attach CashLenX application and dependency containers to one explicitly
  named Docker network and keep Dockerfile and Compose definitions under each
  project's `docker/` tree.
- Context: Independently created project networks prevent reliable container-DNS
  connections, while root-level Docker definitions split deployment assets
  across unrelated repository locations.
- Constraints: Preserve explicit dependency lifecycle ownership, selected
  `ENV_FILE` behavior, configured persistent storage, image identities, host
  bindings, API/product behavior, and runtime versions. Do not start or stop the
  shared test environment.
- Done when: every application and database service renders on the configured
  external network; start scripts create it idempotently; stop scripts remove it
  only when unused; Server database routes use container DNS and internal ports;
  Dockerfiles and Compose files reside under `docker/` or dependency
  subdirectories; documentation, source snapshots, and lifecycle tests pass.

## Delivered Result

- Summary: Moved each root Dockerfile and App/Website Compose file into its
  owning `docker/` tree, attached every application and database service to one
  configurable external network, and replaced Server host-gateway database
  routes with container DNS and configurable internal ports.
- Changed behavior: App, Server, Website, MongoDB, and MySQL each expose an
  explicit Compose project name and container name with a default. All expose
  the same absolute `DOCKER_NETWORK_NAME`. Any start script creates that network
  when absent and joins its service to it. Stop removes only its Compose project
  and attempts shared-network removal only when Docker reports zero connected
  containers. Server containers
  reach project-managed databases through `MONGO_CONTAINER_NAME`/
  `MYSQL_CONTAINER_NAME` and the matching internal-port keys. Direct host
  runtime continues to use the published database ports.
- Compatibility: The supported build/start/stop and repository-local
  `ENV_FILE` interfaces, explicit dependency ownership, host bindings, images,
  persistent storage, API/client behavior, and runtime versions are unchanged.
  The distinct project identities prevent one repository's
  `--remove-orphans` operation from removing sibling CashLenX services. Direct
  Compose diagnostics must now use `-f docker/compose.yml` for App,
  Server, and Website. Root `.dockerignore` files intentionally remain beside
  the repository build contexts.
- Migration/rollback: Existing containers must be recreated to join the shared
  network. Persistent volumes and configured bind paths are retained. Rollback
  restores the prior Compose paths and host-routed database connection values.
- Implementation refs: `cashlenx-app` commit `3416bd3`; `cashlenx-server`
  commit `50d14fc`; `cashlenx-website` commit `0651f4d`.

## Validation

- Commands and results: All lifecycle files passed `bash -n`; Server dependency
  lifecycle smoke passed; Server `go test ./...` passed; Website `npm run build`
  passed; App and Server Dockerfile checks passed; all five Compose projects
  rendered successfully from `.env.example`; every existing ignored environment
  variant rendered its selected network and ports/routes; custom database
  internal-port derivation and default/custom explicit project, container, and
  network-name rendering passed; the actual Server `scripts/build.sh` completed
  from `docker/Dockerfile`, and its image revision label matched `50d14fc`.
  Repository diff checks, Spec English checks, and source-snapshot comparisons
  passed.
- Negative/auth/compatibility evidence when applicable: Lifecycle smoke proved
  missing-network creation, occupied-network preservation, unused-network
  removal, invalid network-name rejection by key only, and unchanged separation
  between API and dependency lifecycle. Every local `.env*` retained existing
  values while gaining template coverage; Docker database URIs were normalized
  to derived container routes. Current runtime repositories contain no
  `host.docker.internal` route, and no root Dockerfile or Compose definition
  remains.
- Known limits: Browser clients cannot resolve Docker container names directly;
  the Flutter API URL remains a browser-reachable address. Containers attached
  to the same network can address each other, so host firewall or reverse-proxy
  policy still owns external exposure. A full App Flutter image build was not
  run under the repository's heavy-build guidance. Website Dockerfile metadata
  validation was attempted twice but Docker Hub's anonymous-token endpoint timed
  out both times; its Compose rendering and local production build passed. No
  application or database container was started, stopped, or deployed.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
