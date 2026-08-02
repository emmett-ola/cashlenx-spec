# Flutter App

## Snapshot

`../cashlenx-app` is the cross-platform Flutter client for CashLenX.

Current stack:

- Flutter with Dart SDK `>=3.8.0 <4.0.0`.
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
- `lib/core/config/app_config.dart`: environment loading and API base URL composition.
- `lib/network/cashlenx_api.dart`: app API adapter methods.
- `lib/features/home/presentation/pages/home_page.dart`: authenticated shell and major finance UI surfaces.
- `lib/features/profile/presentation/pages/profile_page.dart`: profile and avatar/currency controls.
- `lib/features/demo/data/demo_data_store.dart`: editable demo-mode data store.
- `lib/theme/app_theme.dart`: theme mode and theme color providers.

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
- Token-backed auth persistence with remember-me state.
- One silent token refresh attempt on eligible 401 responses.
- Authenticated home shell with Home, Category, Add, Budget, and Settings tabs.
- Real API-backed dashboard and finance flows for normal users.
- Session-local editable data for demo users.
- Transaction list, add, edit, delete, category selection, date selection, validation, and server error handling.
- Hierarchical category management.
- Profile fetch/update for supported fields.
- Theme color, currency, language, about, and logout settings.
- Docker-based Flutter web deployment using `Dockerfile`, `compose.yml`, and nginx route fallback.
- GitHub Actions web release workflow that builds, analyzes, tests, and publishes static web output to the release repository.

## Known App Gaps

- Budget creation/editing is still coming-soon behavior.
- Expanded statistics uses test presentation data rather than the full statistics/chart API surface.
- Auth provider/repository unit coverage is lighter than live integration coverage.
- The home shell should be split by feature as areas mature.
- Date-range filtering should be added explicitly to the transaction list.

## Generated Files

Do not hand-edit generated Dart files:

- `*.g.dart`
- `*.freezed.dart`

Regenerate from source with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Standard Validation

```bash
flutter analyze
flutter test
```

Run the disposable Flutter-to-server smoke flow on Windows with Docker available:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1
```

Use MySQL 8 instead of MongoDB with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/smoke-api.ps1 -Database mysql
```
