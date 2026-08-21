# v0.7.0 Design Parity Acceptance

## Status

- Version: `v0.7.0`
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
- Target: Close the online-design parity series
- Affected project areas: `cashlenx-spec`, `cashlenx-app`

## Task Contract

- Goal: Collect final visual and behavioral acceptance evidence and dispose of
  every residual audit item.
- Context: Existing tests emphasize behavior and do not yet provide complete
  multi-viewport visual evidence.
- Constraints: Refresh the live Figma Make source before acceptance. Preserve
  recorded product-correct deviations from prototype behavior. This version does
  not authorize deployment, publication, tagging, or branch promotion.
- Done when: Relevant screens are validated at phone, maximum shell width, and
  tablet/desktop host widths; analyze/tests pass; residual differences are fixed,
  accepted, or moved to backlog; canonical facts and implementation refs are
  complete.

## Delivered Result

- Summary: Refreshed the authoritative online Figma Make manifest, confirmed the
  critical cached source files still match online, added deterministic golden
  acceptance for the dashboard/settings/profile surfaces, and closed the full
  v0.2.0-v0.7.0 parity audit series.
- Changed behavior: No product behavior changed. The app now carries committed
  visual baselines at 390x844, 430x932, and a 768x1024 host. The tablet baseline
  proves the 430 px app shell remains centered on the gray host rather than
  stretching mobile geometry across the desktop width.
- Compatibility: Test-only additions plus app package advancement to
  `0.7.0+7`; runtime API compatibility is unchanged.
- Migration/rollback: No data migration. Revert the acceptance commit to remove
  the baselines; no database or deployed state is involved.
- Implementation refs: `cashlenx-app` commit `0d638a3` (`test: lock design
  parity viewports`). Resulting app version: `0.7.0+7`.

## Validation

- Commands and results: The online Make root returned 184 resources (130 text
  sources and 54 images) on `2026-08-21`. Online `App.tsx`, `Profile.tsx`, and
  `Settings.tsx` matched the local export exactly after newline normalization.
  Golden generation and a second comparison-only run passed for five images;
  `flutter analyze` passed with no issues; final `flutter test` passed all 47
  tests. The baselines were visually inspected for shell width, host centering,
  spacing, card geometry, navigation, semantic colors, and overflow.
- Known limits: Flutter widget goldens use the test font, so they lock layout,
  color, clipping, and relative typography geometry rather than platform font
  rasterization. No physical-device screenshot or deployment was authorized.
  Explicit attachment persistence, export/import UX, optional-profile clear
  semantics, durable offline configuration retry, additional statistic
  surfaces, broader live API smoke restoration, shell decomposition, and a full
  accessibility review remain named backlog—not omitted or represented as
  complete.

## Residual Audit Disposition

- Accepted product-correct deviations: real API/demo authorities replace Make
  mock state; income remains green and expense red; About uses installed package
  metadata; unsupported prototype account statistics render truthful unavailable
  values; the Make file's missing unused `ThemeColorSelector` import is not
  reproduced.
- Delivered surfaces: splash, onboarding, login, registration, password reset,
  setup/currency, dashboard, transaction discovery/detail/add/edit/delete,
  categories, budgets, expanded statistics, settings, profile, and bottom
  navigation.
- Deferred surfaces/contracts: every remaining item is owned by
  `backlog/design-parity-api-integration.md` or `backlog/README.md`.

## Close Gate

- [x] Done condition satisfied.
- [x] Relevant validation passed and known limits recorded.
- [x] Workflow and deployment states recorded.
- [x] Durable facts synchronized.
- [x] Residual scope moved to backlog or accepted explicitly.
- [x] Implementation refs and final repository states recorded.
