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
4. Review the exact candidate evidence. Candidate acceptance does not create a
   tag, publish an artifact, promote a branch, deploy a runtime, or mutate data.

## Authorized release flow

After the complete release gate passes for the same commits and artifact
digests, create an annotated `vX.Y.Z` tag in each affected implementation
repository. A release tag is immutable: never move, replace, or delete it. Push
the already validated commits and tags, then publish the prebuilt artifacts by
their recorded SHA-256 digests. Do not rebuild between acceptance and
publication. Publication failure leaves source and tags unchanged; retry the
same bytes or correct the issue under a new semantic version.

Deployment is a separate action. Non-destructive rollback selects a previously
accepted immutable artifact and tag whose database compatibility is verified.
Rollback never rewrites a tag or overwrites an artifact. Any destructive or
ambiguous data action, secret change, security exception, force-push, existing
tag mutation, or failed-gate bypass still requires a new Human decision.

## CI/CD integration

Each implementation repository owns a manual, secret-free candidate job and a
repository-local `scripts/package-image.sh`. Future CI/CD can call those entry
points and the same release gate, then attach publication or deployment only as
separate jobs that consume the accepted manifest and exact artifact digests.
