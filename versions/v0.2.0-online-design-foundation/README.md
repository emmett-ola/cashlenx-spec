# v0.2.0 Online Design Foundation

## Status

- Version: `v0.2.0`
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
- Target: Complete before `v0.3.0`
- Affected project areas: `cashlenx-spec`, `cashlenx-app`

## Task Contract

- Goal: Establish a reliable live-design baseline and reusable Flutter visual
  foundation before screen-by-screen parity work.
- Context: The live Figma Make source is readable. Forty-seven custom design
  files were compared with the local export using normalized text length and
  FNV-1a hashes on `2026-08-21`; all 47 matched exactly. Flutter currently
  duplicates many tokens, uses auth control geometry that differs from the
  design, and renders contradictory cash-flow colors between transaction lists
  and details.
- Constraints: Preserve Riverpod, GoRouter, Dio, real API behavior, demo-mode
  isolation, i18n, and existing repository boundaries. Do not copy React code
  or prototype persistence into Flutter. Do not adopt known design defects.
- Done when: The live-source rule is canonical, Flutter exposes the confirmed
  visual tokens, shared auth controls use the confirmed geometry, income is
  consistently success/green, expense is consistently error/red, focused tests
  cover the changed rules, and app analyze/tests pass.

## Optional Files

- Requirement: `requirement.md` contains the cross-version audit and accepted
  migration boundaries.

## Delivered Result

- Summary: Established the live Figma Make token foundation in Flutter, aligned
  shared auth control geometry, and corrected cash-flow color semantics.
- Changed behavior: Shared auth fields and actions now use 8 px radii and the
  confirmed live-design fills; app theme colors, spacing, and radii have named
  tokens; income renders success/green and expense renders error/red.
- Compatibility: UI-only foundation; no API or data-schema change.
- Migration/rollback: No data migration. Revert the app commit to restore the
  prior visual constants and semantic colors.
- Implementation refs: `cashlenx-app` commit `4aea738` (`feat: establish online
  design foundation`). Runtime/displayed app version: `0.2.0+2`.

## Validation

- Baseline `flutter analyze`: Passed on `2026-08-21` with no issues.
- Baseline `flutter test`: Passed on `2026-08-21`; 28 tests passed.
- Final `flutter analyze`: Passed on `2026-08-21` with no issues.
- Focused design-foundation, theme, auth, and home tests: Passed on
  `2026-08-21`; 5 tests passed.
- Final `flutter test`: Passed on `2026-08-21`; 30 tests passed.
- Negative/auth/compatibility evidence when applicable: Demo/API boundaries are
  unchanged.
- Known limits: Screen-specific parity is intentionally deferred to later
  versions in this series.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow state and deployment state recorded separately.
- [x] Durable facts updated in the canonical `system/` document.
- [x] Deferred work moved to `backlog/` or recorded as an open question.
- [x] Implementation refs and final repository state recorded.
- [x] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
