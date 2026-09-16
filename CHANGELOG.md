# Changelog

This changelog records coordinated CashLenX product versions. Component
changelogs provide repository-specific detail, while Jira owns active delivery
state and the evidence manifest owns exact candidate identities.

## [Unreleased]

### Changed

- Added fail-closed candidate deployment and non-destructive application
  rollback using verified manifests, immutable image identities, public App
  configuration fingerprints, no-pull startup, checksummed target state, and
  secret-free operation evidence.
- Defined Docker Compose and nerdctl 2.2 as the portable repository-local
  lifecycle contract, including pre-mutation validation, configured image
  identity, value-safe start output, and cross-frontend regression coverage.
- Added portable status, doctor, and bounded-log operations plus selected
  dependency visibility and bounded, observable graceful/forced/idempotent stop
  semantics across all five runtime lifecycle groups.

## [1.0.0-rc.1] - 2026-09-16

### Added

- Stable `/api/v1` routing with a frozen `/api/v0` previous-client alias.
- Username-or-email login and normalized unique email identifiers.
- Reproducible, checksummed App, Server, Website, and Spec candidate artifacts.
- Exact semantic version, revision, image identity, build-input, and artifact
  provenance in a secret-free evidence manifest.
- Manual, secret-free candidate packaging jobs ready for future CI/CD wiring.

### Changed

- Aligned App, Server, OpenAPI, Website, Spec, and release notes on the
  coordinated v1 release-candidate line.
- Separated validation, tagging, artifact publication, branch promotion,
  deployment, migration, and production acceptance as independent states.
