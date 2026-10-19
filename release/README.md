# Release Artifacts

This directory owns the coordinated product-version input and release-note
source used by the specification-owned release-candidate builder. Runtime
repositories remain independently buildable and do not read this directory.

The [product version catalog](version-catalog.md) indexes every exact stable
version registered in Jira and links retained local release notes. It separates
version identity from implementation, candidate acceptance, and deployment.

## Candidate flow

1. Update `VERSION`, the matching release note, and the version source,
   display copy, and changelog of every affected implementation repository.
   Update OpenAPI only when the Server contract changes. Record every unaffected
   component at its retained version.
2. Run `scripts/release-gate.sh` with the exact affected-component set. The
   script fails before packaging when a repository is dirty or unsynchronized,
   a component version or changelog conflicts, or the OpenAPI copies differ.
3. The Bash gate packages all three exact clean compatibility images twice,
   compares image identities and artifact hashes, and retains one checksummed set plus a
   secret-free manifest under `.artifacts/release-gates/`.
   App candidates include the selected public configuration profile and a
   normalized fingerprint in both their immutable tag and manifest identity.
4. Review the exact candidate evidence. Candidate acceptance does not create a
   tag, publish an artifact, promote a branch, deploy a runtime, or mutate data.

For the complete local release-readiness gate, first complete and record the
Jira blocker scan, then run:

```bash
bash scripts/release-gate.sh \
  --affected-components app \
  --database unchanged \
  --jira-preflight-reference "CLV-15 comment 10250"
```

This single entry point runs exact-toolchain validation for affected
repositories, reproducible candidate packaging, compatibility checks against
retained repositories, and whole-product browser acceptance. A release with no
database or persistence-boundary change uses `--database unchanged`. When the
Server is selected, the gate compares the delivered `origin/main` commit to the
candidate and rejects that scope if a database-sensitive path changed. A
persistence-changing release selects `--database mongodb`, `mysql`, or `all`.
The Bash runtime acceptance exercises both supported database profiles with
generated secrets, isolated Compose resources and unnetworked restores. The
gate writes a checksummed aggregate manifest under
`.artifacts/release-gates/` and performs no delivery action.

Pass every implementation repository changed by the product version through
`--affected-components`. The gate runs static and unit checks for those
components and packages all three compatibility images at their independent component versions. It records
every repository commit and retained runtime version in the evidence. Existing
release tags do not prevent untagged source validation or Testing promotion;
separately authorized tag creation must still reject an existing identity.

## Authorized release flow

Only after separate tag/publication authorization and a complete release gate
for the same commits and artifact digests, create an annotated `vX.Y.Z` tag in
each affected implementation repository. A release tag is immutable: never move, replace, or delete it. Push
the already validated commits and tags, then publish the prebuilt artifacts by
their recorded SHA-256 digests. Do not rebuild between acceptance and
publication. Publication failure leaves source and tags unchanged; retry the
same bytes or correct the issue under a new semantic version.

Deployment remains a separate action. The retained PowerShell deployment
scripts are legacy evidence and are not active entry points. Runtime deployment
or rollback must wait for a Bash replacement that preserves manifest,
checksum, immutable-image, no-pull, target-state, and non-destructive rollback
semantics. This does not block branch-driven static App publication, but an
accepted release with an affected Server remains incomplete until the exact
Server `main` candidate is deployed and verified. The explicit `main`
promotion instruction covers that normal non-destructive deployment once the
approved Bash entry point and access profile are available.

## CI/CD integration

Each implementation repository owns a manual, secret-free candidate job and a
repository-local `scripts/package-image.sh`. Future CI/CD can call those entry
points and the same release gate, then attach publication or deployment only as
separate jobs that consume the accepted manifest and exact artifact digests.

The three selected environment files remain repository-local and own target
names, ports, resource settings, and Server secrets. Their values are never
copied into the deployment state or evidence.
