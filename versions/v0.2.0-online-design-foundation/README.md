# v0.2.0 Online Design Foundation

## Status

- Version: `v0.2.0`
- State: WIP
- Work Level: Standard
- Execution Owner: AI
- Validation Owner: AI
- Validated At: Pending
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

- Summary: In progress.
- Changed behavior: Pending.
- Compatibility: UI-only foundation; no API or data-schema change.
- Migration/rollback: No data migration. Revert the app commit to restore the
  prior visual constants and semantic colors.
- Implementation refs: Pending.

## Validation

- Baseline `flutter analyze`: Passed on `2026-08-21` with no issues.
- Baseline `flutter test`: Passed on `2026-08-21`; 28 tests passed.
- Negative/auth/compatibility evidence when applicable: Demo/API boundaries are
  unchanged.
- Known limits: Screen-specific parity is intentionally deferred to later
  versions in this series.

## Close Gate

- [ ] Done condition satisfied.
- [ ] Relevant validation passed and known limits recorded.
- [ ] Workflow state and deployment state recorded separately.
- [ ] Durable facts updated in the canonical `system/` document.
- [ ] Deferred work moved to `backlog/` or recorded as an open question.
- [ ] Implementation refs and final repository state recorded.
- [ ] Triggered contract, migration, security, compatibility, recovery, or deployment evidence recorded.
- [x] Human decision recorded only when a Human gate was triggered.
