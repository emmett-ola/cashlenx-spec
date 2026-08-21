# Flutter App

## Snapshot

`../cashlenx-app` is the cross-platform Flutter client for CashLenX.

Current stack:

- Flutter with Dart SDK `>=3.8.0 <4.0.0`.
- Runtime/displayed version `0.4.0+4` after transaction discovery parity.
- Feature-first Clean Architecture.
- Riverpod for state.
- GoRouter for routing.
- Dio through local API wrappers and interceptors.
- Freezed and json_serializable for generated models.
- `.env` loaded by `AppConfig.init()`.

## Important Entry Points

- `pubspec.yaml`: dependencies, assets, and launcher icon configuration.
- `.env.sample`: local environment template.
- `lib/main.dart`: config, provider scope, theme, i18n, and router startup.
- `lib/routing/app_router.dart`: GoRouter setup and auth redirects.
- `lib/core/i18n/app_i18n.dart`: translations and language selection.
- `lib/core/config/app_config.dart`: environment loading and API base URL composition.
- `lib/core/services/secure_storage_service.dart`: token and remember-me persistence.
- `lib/network/cashlenx_api.dart`: app API adapter methods.
- `lib/features/home/presentation/pages/home_page.dart`: authenticated shell and major finance UI surfaces.
- `lib/features/profile/presentation/pages/profile_page.dart`: profile and avatar/currency controls.
- `lib/features/demo/data/demo_data_store.dart`: editable demo-mode data store.
- `lib/theme/app_theme.dart`: theme mode and theme color providers.
- `lib/shared/widgets/app_surface.dart`: shared panels, cards, and list tiles.
- `lib/shared/widgets/app_color_picker.dart`: shared theme-color picker.
- `assets/images/avatars/`: fixed preset avatar library.

## Architecture

The app follows a feature-first structure:

```text
lib/
  core/                  # App-wide config, utilities, response wrappers, secure storage.
  core/infrastructure/   # Reusable HTTP, routing, error, logging, and persistence contracts.
  network/               # Dio setup, API adapter, interceptors.
  features/<feature>/    # Data, domain, presentation layers.
  shared/                # Reusable UI widgets.
  routing/               # GoRouter configuration.
  theme/                 # App theme and theme mode providers.
```

Expected dependency flow:

```text
UI -> Provider/Controller -> Use Case -> Repository -> Data Source -> API
```

Domain code should remain pure Dart and avoid Flutter dependencies.

## Current Implemented Behavior

- Splash, login, registration, password reset, and demo mode.
- Live-design onboarding uses three photographic Unsplash panels with branded
  loading/error fallbacks. Splash and shared auth branding are localized.
- First-login setup uses the official teal logo and exposes the complete
  21-currency catalog confirmed in the live design.
- Token-backed auth persistence with remember-me state.
- One silent token refresh attempt on eligible 401 responses.
- Authenticated home shell with Home, Category, Add, Budget, and Settings tabs.
- Real API-backed dashboard and finance flows for normal users.
- Session-local editable data for demo users. Choosing demo mode resets the demo store before entering the session, and demo mode does not call authenticated APIs.
- Transaction list, add, edit, delete, category selection, date selection, validation, and server error handling.
- Transaction discovery supports type, category, inclusive from/to date, and
  search filters. Authenticated ranges use `/cash/range`; demo ranges stay
  local. Removable active chips, localized result summaries, and filtered-empty
  recovery expose the current filter state.
- Add and edit transactions share amount/keypad, category, date, description, remark, and attachment-placeholder behavior. Their category selectors remember the last income and expense selections independently while the transaction type changes.
- Hierarchical category management.
- Localized transaction dates, calendar month titles, weekday labels, and first-day-of-week behavior through Flutter localizations.
- Profile fetch/update for `nickname`, `avatar_url`, and `gender`. Avatars come from the fixed preset library; the fallback asset is `assets/images/avatars/f9b59ca5421b2b7ef2e31c2ba4d827f48d22594a.png`.
- Theme color, currency, language, about, and logout settings.
- The selected theme color drives primary controls, accents, selected states, and highlights. Splash and pre-splash visuals remain brand-stable rather than following the selected theme color.
- Live Figma Make colors, 4 px spacing increments, and 8/16/24 px radii are
  centralized in `AppDesignTokens`. Shared auth fields and actions use the
  confirmed 8 px control radius.
- Cash-flow semantics are consistent across transaction list and detail
  surfaces: income uses success/green and expense uses error/red.
- Docker-based Flutter web deployment using `Dockerfile`, `compose.yml`, and nginx route fallback.
- GitHub Actions web release workflow that builds, analyzes, tests, and publishes static web output to the release repository.

## Known App Gaps

- Budget creation/editing is still coming-soon behavior.
- Expanded statistics uses test presentation data rather than the full statistics/chart API surface.
- Auth provider/repository unit coverage is lighter than live integration coverage.
- The home shell should be split by feature as areas mature.

## Generated Files

Do not hand-edit generated Dart files:

- `*.g.dart`
- `*.freezed.dart`

Regenerate from source with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For a longer generated-code session:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Standard Validation

See `../testing.md` for the canonical app analyze, test, and disposable database/API smoke commands and their evidence boundaries.
