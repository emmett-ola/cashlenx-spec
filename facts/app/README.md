# Flutter App

## Snapshot

`../cashlenx-app` is the cross-platform Flutter client for CashLenX.

See [implemented-features.md](implemented-features.md) for the detailed,
versioned inventory of user-facing App capabilities and current exclusions.
See [code-architecture.md](code-architecture.md) for the implementation-level
architecture, dependency flows, state model, and maintainability assessment.
An accompanying [Simplified Chinese translation](code-architecture.zh-cn.md) is
available for readers who prefer Chinese; the English document remains canonical.

Current stack:

- Flutter with Dart SDK `>=3.13.0 <4.0.0`.
- Runtime/displayed version `1.1.3+19` on the coordinated 1.1.3 delivery boundary.
- Feature-first architecture with selectively applied Clean Architecture layers.
- Riverpod for state.
- GoRouter for routing.
- Dio through local API wrappers and interceptors.
- Freezed and json_serializable for generated models.
- Compile-time environment definitions resolved by `AppConfig.init()`.
- `scripts/run.sh` selects a repository-local `ENV_FILE` (default `.env`) and
  forwards only the five public App/API settings to Flutter. Container builds
  and candidate packaging use the same parser; explicit shell values override
  the file, and an empty `API_PORT` remains empty. Device addresses are used
  unchanged. Android permits HTTP only in debug builds; profile and release
  builds retain the platform HTTPS policy.

## Important Entry Points

- `pubspec.yaml`: dependencies, assets, and launcher icon configuration.
- `.env.example`: local environment template with every assignment active;
  operators change values directly rather than uncommenting settings.
- `lib/main.dart`: config, provider scope, theme, i18n, and router startup.
- `lib/routing/app_router.dart`: GoRouter setup and auth redirects.
- `lib/core/i18n/app_i18n.dart`: translations and language selection.
- `lib/core/config/app_config.dart`: environment loading and API base URL composition.
- `lib/core/services/secure_storage_service.dart`: token and remember-me persistence.
- `lib/network/cashlenx_api.dart`: app API adapter methods.
- `lib/features/home/presentation/pages/home_page.dart`: authenticated shell,
  route-section coordination, and owning library for the Home presentation
  parts.
- `lib/features/home/presentation/pages/home/`: dashboard, category,
  transaction, settings, shared-widget, and model presentation parts. They
  remain one private Dart library and are not imported independently.
- `lib/features/budget/`: typed budget domain/data/presentation boundary.
- `lib/features/statistics/`: typed expanded-statistics domain/data/presentation boundary.
- `lib/features/profile/presentation/pages/profile_page.dart`: account identity,
  profile information, avatar selection, and presentation-only account statistics.
- `lib/features/settings/data/user_configuration_sync.dart`: authenticated and
  demo configuration synchronization while retaining local offline fallback.
- `lib/features/demo/data/demo_data_store.dart`: editable demo-mode data store.
- `lib/theme/app_theme.dart`: theme mode, theme color, and locale-aware
  typography.
- `lib/theme/app_fonts.dart`: startup loading and locale selection for bundled
  Chinese interface fonts.
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

Target dependency flow for fully layered features:

```text
UI -> Provider/Controller -> Use Case -> Repository -> Data Source -> API
```

The current implementation does not have a separate use-case layer, and some
features intentionally use a shorter UI/provider -> API or Demo-store flow.
Domain code should remain pure Dart and avoid Flutter dependencies.

## Current Implemented Behavior

- Splash, login, registration, password reset, and demo mode. Registration's
  email-verification step presents the destination email as read-only context,
  accepts a focused six-character ASCII alphanumeric code while preserving its
  case, retains resend countdown feedback, and offers localized Confirm and
  Return to edit email actions without changing the verification API contract.
- The official camera-and-cash brand mark is shared by splash, authentication,
  first-login setup, About, and Flutter Web bootstrap surfaces. Platform icon
  assets cover Android adaptive and round launchers, iOS light/dark/tinted
  appearances, macOS, Windows, and Flutter Web/PWA metadata.
- Live-design onboarding uses three photographic Unsplash panels with branded
  loading/error fallbacks. Splash and shared auth branding are localized.
- First-login setup uses the official teal logo and exposes the complete
  21-currency catalog confirmed in the live design. It persists the selected
  authenticated-user currency before marking setup complete; a failed write
  keeps the user on setup with an error.
- Authenticated routing resolves account-backed configuration before choosing
  Home or first-login setup. Existing users on a clean device restore currency,
  language, theme, and setup completion without repeating setup; local state is
  retained only as a failure fallback.
- The selected currency's catalog symbol is the single presentation source for
  finance amounts on Home, Recent Activity, Transactions, transaction entry and
  editing, Statistics, and Budget surfaces. Multi-character symbols remain
  responsive; stored numeric values are not converted or rewritten.
- Token-backed auth persistence with remember-me state. Session pairs are saved
  refresh-first and partial writes fail signed out; remembered startup restores
  only a complete refresh-backed session.
- Interactive login submission keeps the signed-out route state stable. A
  rejected login remains on the mounted form, preserves its current field
  values, and presents the server error without a splash-screen redirect.
- Eligible concurrent 401 responses share one rotating refresh attempt. Stale
  requests reuse the newly stored access token, rejected refresh credentials
  expire the session, and transient network failure retains it for later retry.
- Explicit logout clears local authority before contacting the API so an
  in-flight refresh cannot restore the session. Demo entry also clears real
  session credentials before creating isolated in-memory demo state.
- Authenticated home shell with Home, Transactions, Add, Budget, and Settings
  tabs. Home's recent-activity `See All` action opens the same Transactions
  destination, while category administration is available under Settings >
  Resource Management > Category Management.
- Primary authenticated routes replace shell content in place without a
  horizontal whole-canvas transition; route URLs, refresh, and browser history
  remain active.
- Profile and transaction detail are URL-addressable secondary destinations.
  Transaction detail preserves whether it originated from Home or Transactions
  when navigating back, while a refreshed direct detail URL retains a stable
  fallback destination.
- Post-splash routes share a full-height responsive shell. Interactive content
  fills phone widths and stays centered within a 430 px mobile canvas on wider
  viewports, while excess horizontal space uses the active theme background.
  Splash remains a full-viewport presentation outside this shell.
- Real API-backed dashboard and finance flows for normal users.
- The dashboard summary defaults to Day and keeps balance, income, and expense
  aligned for Day, Month, Year, and Total. The dashboard ends with a compact
  Financial Insights entry for expanded Statistics instead of duplicating a
  category chart.
- Session-local editable data for demo users. Choosing demo mode clears any real
  session and resets finance, profile, currency, and theme data before entering
  the session. The reset carries the language selected on the unauthenticated
  screen into the new demo configuration, and demo mode does not call
  authenticated APIs.
- Primary-tab transaction list plus add, edit, delete, category selection, date
  selection, validation, and server error handling. Transaction details remain
  focused secondary surfaces and return to the originating Home or Transactions
  context.
- Transaction discovery supports type, category, inclusive from/to date, and
  search filters. Authenticated ranges use `/cash/range`; demo ranges stay
  local. Removable active chips, localized result summaries, and filtered-empty
  recovery expose the current filter state.
- Add Transaction opens as a full-screen modal flow with income/expense tabs and
  a four-column category grid. Parent categories navigate to their children;
  choosing a leaf opens a bottom amount panel with a localized date control,
  note field, and sequential addition/subtraction calculator. The computed
  positive amount and note use the existing cash-flow request contract.
- Edit Transaction retains the detailed amount keypad, category, date,
  description, remark, and attachment-placeholder experience. Transaction
  entry remains centered within the 430 px mobile canvas on wider hosts and
  preserves safe areas, keyboard insets, and reachable actions under large
  text.
- Hierarchical category management.
- Category emoji and background-color customization persists through the Server
  and remains visible after list/tree reloads; demo categories use the same
  presentation fields in memory. Authenticated transaction surfaces reconcile
  cash flows with the current category list by normalized category ID, so
  compatible legacy cash-flow payloads that omit category presentation still
  show the current icon and color.
- Monthly category-budget CRUD for authenticated users through `/budget`, with
  ledger-derived usage, month navigation, loading/error/empty recovery, and a
  mutable isolated demo equivalent. Visible month labels follow the active
  English, Simplified Chinese, or Traditional Chinese locale through the shared
  period-formatting boundary, while query and persistence periods remain
  canonical `YYYY-MM`. Aggregates and progress use the selected currency's
  minor-unit precision, including zero-decimal currencies.
- Expanded statistics inherit Day, Month, or Year from the dashboard and let
  users change the range and matching period. Summary, trend, and top-expense
  data always use that period for authenticated and Demo users. Year mode
  normalizes compatible monthly-comparison responses into January through
  December with zero-filled gaps, and all twelve localized labels remain
  visible on compact and wide layouts. Dashboard Total opens Year mode.
- Localized transaction dates, calendar month titles, weekday labels, and first-day-of-week behavior through Flutter localizations.
- Simplified and Traditional Chinese text uses complete repository-owned Noto
  Sans SC/TC fonts loaded and integrity-checked before the first Flutter frame.
  The shared theme selects the regional family and retains both as fallbacks,
  covering dynamic API and user-provided text without runtime font-network
  dependencies or transient missing glyphs.
- Profile fetch/update for `nickname`, `avatar_url`, `phone_number`, `location`,
  and `birth_date`. The profile data model retains `gender` when supplied by the
  API, but the current Profile screen does not expose a gender editor. Profile
  does not edit currency, theme, language, or persist user configuration;
  Settings is the sole UI owner for those preferences. Presentation-only account
  statistics may display the active currency symbol without making it a Profile
  control. Avatars come from the fixed preset library; the fallback asset is
  `assets/images/avatars/f9b59ca5421b2b7ef2e31c2ba4d827f48d22594a.png`.
- Theme color, currency, and language synchronize through the authenticated user
  configuration API before authenticated route selection. The additive
  `setup_completed` response field distinguishes an explicit default-looking
  choice from an unconfigured account; local preferences remain the offline
  fallback and demo configuration is isolated in memory. Its first synchronization preserves the
  language selected at demo entry, and later in-session language changes update
  both local preferences and demo configuration. About shows the installed App
  Version, the connected API runtime Version, and the artifact-generated UTC
  Build Date independently; API loading and failure never hide the App identity.
  Logout remains available.
- The selected theme color drives primary controls, accents, selected states, and highlights. Splash and pre-splash visuals remain brand-stable rather than following the selected theme color.
- Semantic surface colors provide coherent light and dark presentation across
  authenticated routes, authentication, onboarding, setup, dialogs, sheets,
  toast feedback, and loading, empty, and error states. Brand gradients,
  splash foregrounds, and user-selected accent color remain intentionally
  distinct from semantic surfaces.
- Icon-only navigation and actions expose localized names and one actionable
  semantics node. Auth inputs expose their visible labels, composite controls
  avoid duplicate announcements, and navigation remains reachable with scaled
  text.
- Startup uses one brief scale-and-fade entrance instead of persistent motion.
  Reduced-motion preferences remove scale and validation displacement while
  retaining immediate error text, borders, and a short fade.
- Live Figma Make colors, 4 px spacing increments, and 8/16/24 px radii are
  centralized in `AppDesignTokens`. Shared auth fields and actions use the
  confirmed 8 px control radius. Entered auth text uses a high-contrast
  theme-aware foreground while placeholders remain visually secondary.
- Cash-flow semantics are consistent across dashboard, transaction list, and
  detail surfaces: income uses success/green and expense uses error/red. When a
  compatible legacy cash-flow payload omits the resolved category type, the App
  derives it from the current category matched by normalized category ID.
- Golden visual baselines cover light dashboard layout at 390 px, the 430 px
  maximum shell width, a 768 px tablet host, and a 1440 px desktop host, plus
  light Settings and Profile at shell width. Representative dark baselines
  cover Home at 390 px and Profile at 430 px. Focused widget coverage also
  protects localized semantics, reduced motion, large text, direct routes, and
  the add-transaction sheet at phone, tablet, and desktop widths.
- Docker-based Flutter web deployment using `docker/Dockerfile`,
  `docker/compose.yml`, explicit project/container names, the shared absolute
  `DOCKER_NETWORK_NAME`, and nginx route fallback.
- GitHub Actions validation for analyze, tests, and the canonical `/api/v1` web
  build, plus a manual secret-free candidate-image artifact job. Successful
  push and pull-request validation covers every branch. Only successful
  pushes to `main` and `testing` publish the branch-configured static client:
  `main` targets `emmett-ola/cashlenx-app-release-main`, while `testing` targets
  `emmett-ola/cashlenx-app-release-test`. Both destination branches are `main`;
  other branches, pull requests and manual dispatches do not publish to a
  release repository. The publication step fixes the Git author
  and committer to `emmett-ola <emmett-ola@users.noreply.github.com>` regardless
  of the workflow actor; push authentication still uses `RELEASE_REPO_TOKEN`,
  which requires Contents read/write access to both destinations. Both release
  repositories must be provisioned before their first publication.
  Source validation, static publication, and runtime deployment remain separate
  evidenced states.

## Known App Gaps

- Auth provider/repository unit coverage is lighter than live integration coverage.
- Dashboard, category, transaction, and settings presentation are separated
  into focused Home library parts. Their private models and shared widgets
  still belong to the Home library; budget and expanded statistics retain
  independent feature boundaries.
- Transaction attachments and export/import do not yet have selected mobile/web
  product workflows.

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
