# 0008 Bash Automation And Independent Component Versions

## Status

Accepted on 2026-10-12 by the project owner.

## Context

CashLenX coordinates product scope through one CLV version Idea, but App,
Server, and Website are independently buildable and do not change in every
product version. The earlier release harness also depended on PowerShell and
Windows-specific tool paths, which prevented the same gate from running on the
current macOS host.

## Decision

- Bash is the portable automation contract for active validation, release, and
  deployment workflows. Zsh may invoke those Bash entry points interactively.
- Active workflows do not invoke, add, or require PowerShell or `pwsh`.
  Retained PowerShell scripts are legacy evidence only until replaced by Bash.
- CLV continues to own one coordinated product-version boundary.
- After the coordinated v1.0.0 baseline, only affected implementation
  repositories advance their runtime version, changelog, tag, artifacts, and
  promotion branches.
- Unaffected repositories keep their existing versions and source commits.
  Release notes and evidence manifests record those retained identities
  explicitly rather than manufacturing no-op version changes.
- Cross-repository compatibility checks remain required when an affected
  component consumes another component's contract, even when the provider's
  version does not advance.
- Local checkout directories are permanently mapped as `app/`, `server/`,
  `website/`, and `spec/`. Remote repositories and artifact identities remain
  `cashlenx-app`, `cashlenx-server`, `cashlenx-website`, and `cashlenx-spec`.
  Automation must map the two naming systems explicitly, prefer the short
  local directories, and accept full remote-style checkout names as a
  compatibility fallback.
- The current project-owner local Flutter/Dart installation is the selected
  toolchain baseline. Tracked version, framework revision, CI setup, and
  container build metadata move together when that baseline changes; release
  validation rejects any silent mismatch.

## Consequences

- An App-only product patch can advance and publish the App without changing or
  promoting Server or Website.
- Release gates accept an explicit affected-component set and fail when an
  affected component's version contract does not match the selected product
  version.
- A legacy PowerShell-only check cannot satisfy a new delivery gate. Its
  triggered capability must first receive a Bash replacement.
- Cross-repository scripts no longer fail because they confuse a short local
  checkout path with a full remote repository name.
- Product version, component runtime version, branch promotion, tag,
  publication, deployment, migration, and acceptance remain separate states.

## References

- `0003-v1-product-deployment-and-autonomous-release-charter.md`
- `0007-owner-selected-execution-and-explicit-promotion.md`
- `../WORKFLOW.md`
- `../release/README.md`
