# 0003 v1 Product, Deployment, And Autonomous Release Charter

## Status

Accepted on 2026-09-16 by the project owner through Jira CLX-31.

## Context

CashLenX needs one stable product boundary and one reusable release contract so
implementation can proceed through `v1.0.0` without repeated routine Human
intervention. The charter must distinguish standing delivery authority from
actions that remain exceptional because they can destroy data, weaken security,
rewrite history, expose secrets, or bypass failed evidence.

## Decision

### Stable Product Surface

- `v1.0.0` includes the implemented monthly category-budget workflow.
- The stable statistics surface includes yearly summary, monthly comparison,
  and top expenses. Additional chart types remain deferred.
- Import and export remain management capabilities without normal-user app UI.
- Visible placeholders are removed or intentionally disabled before stable
  acceptance.
- Supported Flutter Web top-level and detail surfaces are URL-addressable and
  covered by refresh, back-navigation, and deep-link acceptance.

### Certified Client Platforms

- Flutter Web is the only production-certified `v1.0.0` client distribution.
- Android, iOS, Windows, macOS, and Linux remain preview or build-compatible
  targets until each has signing, packaging, platform-integration, and release
  acceptance evidence.
- The Web experience remains mobile-first and responsive.

### Deployment And Database Profile

- The certified `v1.0.0` topology is one single-node, single-application
  instance serving multiple isolated users.
- Local rehearsal, self-hosted production, and a cloud VM or container host use
  the same container contract.
- MongoDB is the primary production database profile. MySQL remains a required
  compatibility profile.
- Multi-instance orchestration, Kubernetes, Helm, shared cache, and
  organization-level multi-tenancy are outside `v1.0.0`.
- Email uses vendor-neutral SMTP. Local rehearsal uses disposable mail capture;
  real SMTP credentials remain deployment-owned configuration.

### Migration, Backup, And Recovery

- Database migrations have immutable ordered identities, checksums, and durable
  applied-version state. Dirty, missing, reordered, or modified applied state
  fails closed.
- Automatic migration is limited to changes classified as forward-compatible
  and non-destructive. Destructive or compatibility-breaking changes require a
  specific migration plan and Human gate.
- The production default is encrypted daily backup with 7 daily, 4 weekly, and
  12 monthly restore points, failure notification, and a quarterly disposable
  restore drill.
- The recovery-point objective is 24 hours and the recovery-time objective is
  4 hours. Local rehearsal proves backup and restore with disposable data.

### Autonomous Delivery And Release Authority

- Within an accepted Jira scope and after every applicable release-candidate
  gate passes, the agent may autonomously refine Jira work, edit and validate
  implementation, commit and push `develop`, run disposable local containers,
  create immutable semantic release tags, publish release artifacts, and
  fast-forward `testing` and `main` when ancestry is clean.
- After CI/CD targets and credentials are configured, the same standing
  authority covers non-destructive testing and production deployments whose
  exact commits, images, evidence manifest, rollback readiness, and health
  checks pass.
- Standing authority never permits force-push, moving or deleting an existing
  release tag, exposing or changing secrets, a destructive or ambiguous
  production-data migration, accepting a security exception, or bypassing a
  failed gate. Each such action requires a new explicit Human decision.

### Version And Release Identity

- Every affected implementation repository uses an immutable annotated
  `vX.Y.Z` Git tag.
- For the coordinated first stable release, App, Server, and Website all expose
  `1.0.0`; images carry that product version and the exact source revision; the
  release evidence records repository commits and artifact digests.
- After `v1.0.0`, only affected repositories advance while Jira retains the
  product-version boundary.

## Consequences

- CLX-31 is the authority record for this approval. Dependent Jira work may
  become agent-ready only after its remaining technical blockers are checked.
- Local production-like rehearsal may generate and use disposable secrets but
  must not read owner-managed Testing or Production environment files.
- Implementation completion, candidate acceptance, tag creation, artifact
  publication, branch promotion, runtime deployment, database execution, and
  production acceptance remain separate evidenced states.
- External targets and credentials are prerequisites, not product decisions;
  their absence blocks the affected deployment action without reopening this
  charter.

## References

- `0001-stable-release-api-auth-and-capability-policy.md`
- `0002-jira-controlled-delivery-with-project-local-advancement.md`
- `../WORKFLOW.md`
- `../system/collaboration.md`
- Jira CLX-31
