# Changelog

This changelog records coordinated CashLenX product versions. Component
changelogs provide repository-specific detail, while Jira owns active delivery
state and the evidence manifest owns exact candidate identities.

## [Unreleased]

### Changed

- Defined an authorized Production promotion as one ordered operation that
  verifies the App's branch-triggered publication and then deploys and verifies
  the exact Server `main` candidate when Server is affected.

### Fixed

- Centralized cross-repository path resolution so active Bash workflows prefer
  the short local checkout layout while remaining compatible with full
  remote-style checkout names.

## [1.1.3] - 2026-10-19

### Fixed

- Made native Flutter runs use the selected repository-local environment
  profile and the same five public settings as container builds, preserving
  explicitly empty API ports and configured device addresses.
- Limited Android cleartext traffic to debug builds while retaining the
  application Internet permission.

### Changed

- Recorded the owner-selected Testing-to-develop history reconciliation,
  including the existing Server MongoDB verification-token repair and migration
  `018`, with candidate acceptance and database execution still separate.
- Added a complete stable-version catalog pointing to the authoritative CLV
  records and corrected the dated Server `1.1.0` deployment evidence.
- Replaced owner-local runtime acceptance with exact-image isolated Bash/Compose
  MongoDB/MySQL migration, browser, backup and recovery validation, retaining
  each component version and checksummed candidate evidence.

## [1.1.1] - 2026-10-13

### Added

- Added focused App regression coverage for localized semantics, light and dark
  surfaces, reduced motion, large text, direct routes, and responsive
  transaction entry.

### Changed

- Made Profile and transaction detail URL-addressable while preserving return
  context and browser navigation.
- Applied coherent semantic dark surfaces throughout the App and constrained
  transaction entry to the mobile canvas on wider hosts.
- Localized Budget period labels consistently with Statistics and made startup
  and validation feedback honor reduced-motion preferences.

### Fixed

- Restored complete localized semantics across core App controls.
- Preserved selected-currency minor-unit precision in Budget summaries and
  progress.

## [1.1.0] - 2026-10-12

### Changed

- Redesigned registration email verification around a focused six-digit code
  step with clear localized confirmation and return-to-email actions.
- Added a responsive branded HTML verification message with a prominent
  selectable code, escaped dynamic values, and no active or tracking content.
- Prepared cumulative App delivery evidence for the completed 1.0.9 and 1.0.10
  client changes that had not previously reached the production branch.
- Promoted the accepted App and Server candidates to `main` and published the
  matching Production static Web release while retaining Server deployment,
  database execution, and production acceptance as separate actions.

### Fixed

- Refreshed Linux visual baselines for the Settings-owned preference boundary
  so remote candidate validation matches the accepted Profile presentation.

## [1.0.8] - 2026-10-12

### Changed

- Promoted the App transaction ledger to primary navigation, routed Home's
  recent-activity See All action to the same destination, and moved category
  administration under Settings > Resource Management.
- Replaced the dashboard category chart with a compact Financial Insights entry
  for the expanded Statistics destination.
- Added component-scoped release-candidate validation so post-v1.0 product
  versions advance only affected implementation repositories.

### Fixed

- Reconciled legacy cash-flow category presentation and replaced repository-text
  Chinese font subsets with pinned complete Simplified and Traditional Chinese
  assets.

## [1.0.4] - 2026-10-09

### Fixed

- Persisted category `emoji` and `bg_color` values through the App, API,
  MongoDB, MySQL, backup, restore, and category read paths with safe defaults
  for existing records.
- Normalized yearly monthly-comparison data to an ordered January-to-December
  series with zero-filled gaps and visible localized labels at compact widths.
- Added ordered migration `017` and retained separate evidence for source
  promotion, Website deployment, and unexecuted shared-environment migration.

## [1.0.3] - 2026-10-09

### Changed

- Coordinated the unified CashLenX camera-and-cash brand identity across App
  launcher and in-product surfaces, Flutter Web/PWA metadata, and Website
  branding.
- Aligned App, Server, Website, OpenAPI, Spec, changelogs, and release notes on
  the 1.0.3 testing candidate without changing API or database behavior.

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
- Aligned CI and deployable container builds on exact Flutter/Dart, Go, and Bun
  identities, canonical image entry points, and one fail-closed dependency lock
  contract per repository.
- Defined immutable MongoDB/MySQL image identities and a non-destructive,
  container-view MongoDB filesystem gate with final-daemon readiness and
  restart-persistence evidence.
- Updated candidate validation to require the Website's authoritative Bun lock
  and reject a competing npm lockfile.

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
