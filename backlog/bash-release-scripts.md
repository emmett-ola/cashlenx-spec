# Bash replacement for the retained release scripts

Status: open. This is the one gap that blocks a Server release from being
completed end to end.

`../facts/operations.md` states that persistence-changing Server releases and
controlled Server deployment fail closed until the legacy PowerShell rehearsal and
deployment capabilities have Bash replacements. The retained files in
`../scripts/` are `deploy-candidate.ps1`, `deploy-candidate-smoke.ps1`,
`rehearsal.ps1`, `release-candidate.ps1` and `release-gate.ps1`; the Bash side
already owns `release-gate.sh`, `environment-lifecycle.sh` and
`whole-product-acceptance.sh`.

Until this is closed, a Server release can reach the exact-candidate gate and a
verified `testing` fast-forward, and then must stop: the approved deploy entry
point does not exist, and the record has to say the release is incomplete rather
than substitute a `main` push or an App publication for deployment.

Closing it means, per script, a Bash entry point that keeps the same contract —
manifest and checksum verification, immutable image identity, no-pull start,
secret-free output, explicit target state, and non-destructive rollback — plus a
run against disposable data proving it. Then the `.ps1` files are deleted rather
than left beside their replacements, or declared historical in `../facts/` with a
reason.

Owner decision needed: whether the first Bash deployment entry point targets only
the single-node MongoDB profile or both supported engines before it may be used
for a release.
