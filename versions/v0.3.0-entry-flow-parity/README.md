# v0.3.0 Entry Flow Parity

## Status

- Version: `v0.3.0`
- State: Closed
- Work Level: Standard
- Execution Owner: AI
- Validation Owner: AI
- Validated At: `2026-08-21`
- Human Gate: Not required
- Human Decision: N/A
- Human Decision By/At: N/A
- Deployment State: Not deployed
- Deployment Evidence: N/A
- Started: `2026-08-21`
- Target: Complete before `v0.4.0`
- Affected project areas: `cashlenx-spec`, `cashlenx-app`

## Task Contract

- Goal: Align splash, onboarding, authentication, and currency/setup entry
  surfaces with the live design.
- Context: The live design uses photographic onboarding panels, official logo
  artwork, and compact rounded controls. Flutter has the complete real auth and
  setup flows but uses substitute onboarding art and a setup logo placeholder.
- Constraints: The existing app presentation may be replaced or substantially
  refactored to follow the live design. Preserve or reconnect real verification,
  password reset, remember-me, secure storage, auth redirects, demo isolation,
  and localized copy. Network imagery must have deterministic loading/error
  behavior.
- Done when: Entry surfaces match confirmed geometry and visual hierarchy,
  official assets are used, all real behaviors remain operational, focused
  widget tests cover fallbacks and navigation, and app analyze/tests pass.

## Delivered Result

- Summary: Rebuilt the onboarding artwork hierarchy from the refreshed live
  source, localized shared entry branding, and aligned both currency setup
  paths with official assets and the complete currency catalog.
- Changed behavior: Onboarding now uses the three live-design Unsplash sources
  with deterministic in-app fallbacks; setup uses the official teal logo;
  currency selection covers all 21 confirmed options; English slide 2/3 copy
  now matches the live source; splash and auth branding react to app language.
- Compatibility: No API or schema change.
- Migration/rollback: No data migration; revert the app commit.
- Implementation refs: `cashlenx-app` commit `4a83ec1` (`feat: align entry
  flows with live design`). Runtime/displayed app version: `0.3.0+3`.

## Validation

- Commands and results: `flutter analyze` passed with no issues; focused entry,
  auth, and foundation tests passed (7 tests); final `flutter test` passed (33
  tests), all on `2026-08-21`.
- Known limits: Onboarding photos are remote Unsplash resources by design. A
  deterministic branded fallback remains visible while loading or on failure.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow and deployment states recorded.
- [x] Durable facts synchronized.
- [x] Implementation refs recorded.
