# Release Artifacts

This directory owns the coordinated product-version input and release-note
source used by the specification-owned release-candidate builder. Runtime
repositories remain independently buildable and do not read this directory.

## Candidate flow

1. Update `VERSION`, the matching release note, every affected implementation
   version source, OpenAPI, display copy, and changelog in one coordinated
   delivery.
2. Run `scripts/release-candidate.ps1`. The script fails before packaging when
   a repository is dirty or unsynchronized, a version or changelog conflicts,
   the OpenAPI copies differ, or the target tag already exists.
3. The script packages exact clean commits twice, compares image identities and
   artifact hashes, and retains one checksummed set plus a secret-free manifest
   under `.artifacts/release-candidates/`.
   App candidates include the selected public configuration profile and a
   normalized fingerprint in both their immutable tag and manifest identity.
4. Review the exact candidate evidence. Candidate acceptance does not create a
   tag, publish an artifact, promote a branch, deploy a runtime, or mutate data.

For the complete local release-readiness gate, first complete and record the
Jira blocker scan, then run:

```powershell
pwsh -File scripts/release-gate.ps1 -Database all -JiraPreflightReference "CLX-30 comment 12345"
```

This single entry point runs exact-toolchain repository validation, reproducible
candidate packaging, both production-like database profiles, and whole-product
browser acceptance. It writes a checksummed aggregate manifest under
`.artifacts/release-gates/` and performs no delivery action.

When Jira is temporarily unavailable, `-TechnicalOnly` may collect the same
technical evidence, but its manifest is explicitly not release-ready and cannot
substitute for a later blocker scan.

## Authorized release flow

After the complete release gate passes for the same commits and artifact
digests, create an annotated `vX.Y.Z` tag in each affected implementation
repository. A release tag is immutable: never move, replace, or delete it. Push
the already validated commits and tags, then publish the prebuilt artifacts by
their recorded SHA-256 digests. Do not rebuild between acceptance and
publication. Publication failure leaves source and tags unchanged; retry the
same bytes or correct the issue under a new semantic version.

Deployment is a separate action. `scripts/deploy-candidate.ps1` verifies the
candidate manifest sidecar, every listed artifact, package metadata, version,
revision, App public configuration fingerprint, and exact local image ID before
replacing any application container. It loads only a missing verified archive,
starts with pulling disabled, records checksummed target state and secret-free
evidence, and treats a repeated deployment of the same candidate as idempotent.
Non-destructive rollback selects the previously recorded App, Server, and
Website image identities without changing database services or volumes.
Rollback never rewrites a tag or overwrites an artifact. Any destructive or
ambiguous data action, secret change, security exception, force-push, existing
tag mutation, or failed-gate bypass still requires a new Human decision.

## CI/CD integration

Each implementation repository owns a manual, secret-free candidate job and a
repository-local `scripts/package-image.sh`. Future CI/CD can call those entry
points and the same release gate, then attach publication or deployment only as
separate jobs that consume the accepted manifest and exact artifact digests.

Example local controlled deployment and rollback:

```powershell
pwsh -File scripts/deploy-candidate.ps1 -Action Deploy -ManifestPath <manifest.json> -TargetName local
pwsh -File scripts/deploy-candidate.ps1 -Action Rollback -TargetName local
```

The three selected environment files remain repository-local and own target
names, ports, resource settings, and Server secrets. Their values are never
copied into the deployment state or evidence.
