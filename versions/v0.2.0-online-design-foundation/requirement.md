# Online Design Parity Audit

## Evidence Baseline

- Audit date: `2026-08-21`.
- Live source: Figma Make file `Zk98sZ5w9YVOZlTR0AARV8`.
- Live inventory: 130 source files and 54 image resources.
- Freshness check: 47 product-specific files under screens, atoms, molecules,
  organisms, shared components, constants, i18n, types, and core styles matched
  the local `cashlenx-design` export exactly by normalized length and FNV-1a
  hash.
- App baseline: `cashlenx-app` branch `develop`, clean at audit start.
- Spec baseline: `cashlenx-spec` branch `main`, clean at audit start.
- App validation baseline: `flutter analyze` passed; `flutter test` passed with
  28 tests.

## Verified Difference Matrix

| ID | Area | Verified difference | Disposition | Version |
| --- | --- | --- | --- | --- |
| F-01 | Design authority | Canonical spec pointed to a `/design/` URL although the source is a Figma Make file. | Make the live `/make/` URL authoritative and treat the local export as a verified cache. | `v0.2.0` |
| F-02 | Tokens | Figma defines a 4 px spacing grid, 8/16/24 px radii, typography scale, semantic colors, backgrounds, and shadows; Flutter centralizes only a subset. | Add reusable Flutter design tokens and consume them in shared controls first. | `v0.2.0` |
| F-03 | Semantic colors | Figma `TransactionTile` and the Flutter list show expense as green and income as red, while Flutter transaction detail uses the correct opposite mapping. | Treat the prototype/list mapping as a design defect; use income success/green and expense error/red everywhere. | `v0.2.0` |
| F-04 | Auth controls | Flutter shared auth buttons and fields use 28 px pill radii; the live design uses 8 px controls and 12 px form surfaces. | Align reusable auth control geometry without changing auth behavior. | `v0.2.0` |
| E-01 | Onboarding | Live design uses three photographic panels; Flutter uses abstract icon circles. | Add resilient design imagery with loading/error fallbacks and retain offline usability. | `v0.3.0` |
| E-02 | First setup | Live design uses the official logo; Flutter renders a `CX` placeholder. | Use the existing teal SVG asset and align the setup card/list geometry. | `v0.3.0` |
| E-03 | Auth behavior | The design uses mock/local authentication and labels password reset as coming soon; Flutter uses real auth, verification, reset, remember-me, and secure storage. | Preserve Flutter behavior and adapt only presentation. | `v0.3.0` |
| T-01 | Transaction filters | Live design exposes from/to date filters; Flutter filters only type, category, and search. | Add inclusive date-range filtering and range validation. | `v0.4.0` |
| T-02 | Filter feedback | Live design shows active-filter chips, result count, and filtered status; Flutter does not. | Add removable chips and localized result summary. | `v0.4.0` |
| T-03 | Empty recovery | Flutter passes no action to the filtered empty state, so its clear-filter CTA cannot recover the list. | Wire clear-filter recovery and test it. | `v0.4.0` |
| T-04 | Search | Flutter has a real search field; the live design stores search state but renders no search input. | Preserve the working Flutter capability and document the accepted deviation. | `v0.4.0` |
| S-01 | App structure | Authenticated presentation is concentrated in a 7,062-line `home_page.dart`; the design separates screens and reusable components. | Split by feature while preserving provider/API behavior, then align reusable surfaces. | `v0.5.0` |
| S-02 | Dashboard data | Live design uses hard-coded category/chart data and derived summary defaults; Flutter uses real APIs or the demo store. | Preserve Flutter data authority and port only visual intent. | `v0.5.0` |
| S-03 | Budget | Both surfaces present budget summaries; create/edit actions are not backed by an app/server mutation contract. | Implement a user-scoped server contract and connect real/demo app repositories; do not promote prototype local storage into authenticated behavior. | `v0.5.0` |
| S-04 | Statistics | The expanded app surface uses test presentation data although the server already exposes reporting and chart APIs. | Integrate the existing typed APIs and remove sample-only reporting as the authoritative path. | `v0.5.0` |
| P-01 | Profile persistence | Design fields for phone, location, and birth date are prototype-only. Flutter renders editable placeholders but the server saves only nickname, avatar, and gender. | Extend the versioned server/profile contract and both persistence backends, then connect Flutter without fake saves. | `v0.6.0` |
| P-02 | Version display | App `pubspec.yaml` is `0.1.0+1`, while the About panel hard-codes `1.0.0`. | Display package version/build metadata and advance it with affected versions. | `v0.6.0` |
| P-03 | Design source defect | Online `Settings.tsx` imports a missing, unused `ThemeColorSelector` module. | Do not reproduce the broken import in Flutter; retain the working shared color picker. | `v0.6.0` |
| I-01 | Localization | Design and app use different key vocabularies. The app defines all 210 statically referenced literal keys and supports English, simplified Chinese, and traditional Chinese. | Preserve app key ownership; validate new visible copy in all three languages. | All |
| Q-01 | Visual evidence | Existing tests verify behavior but do not provide multi-viewport visual regression evidence. | Add targeted widget/golden evidence and inspect 390, 430, and 768 px viewport classes. | `v0.7.0` |

## Series Constraints

- Online Figma Make is the visual source, not a runtime or build dependency.
- Implementation repositories remain independent of `cashlenx-spec`.
- Real API and security behavior override prototype local storage or mock logic.
- Prototype values must not be presented as persisted user data.
- Amount semantics use income success/green and expense error/red even where the
  prototype is reversed.
- Existing presentation may be replaced or removed while following the live
  design, but no product capability may be silently dropped.
- Missing server capabilities are implemented in the selected version or
  represented by a truthful disabled/prewired app boundary and the canonical
  API integration backlog.

## Done When

The series is done when versions `v0.2.0` through `v0.7.0` are closed in order,
their app/spec commits and validation evidence are recorded, and all remaining
differences are either implemented or explicitly accepted/deferred in canonical
spec owners.
