# App Code Architecture

## Analysis Baseline

- App version: `1.1.1+18`.
- Source commit: `a74effdd1d4be826e8158e22820458611bce9d05` on `develop`.
- Analysis scope: committed App source under `lib/`, its declared dependencies,
  and committed tests. Uncommitted platform and tooling changes are excluded.
- The Server was not executed, modified, built, tested, deployed, or otherwise
  used as an active work area for this analysis.

## Executive Summary

The App uses a feature-first Flutter structure with Riverpod as the composition
and state-management mechanism. It applies Clean Architecture most completely
to authentication, uses smaller repository/domain boundaries for Budget and
Statistics, and keeps several mature UI flows in a presentation-owned Home
library. The resulting architecture is best described as a **feature-first,
selectively layered architecture**, not a uniform Clean Architecture stack.

The main runtime path is:

```text
Flutter UI
  -> Riverpod provider or local controller
  -> feature repository or direct feature orchestration
  -> CashlenxApi
  -> ApiClient / RestClient
  -> Dio + interceptors
  -> HTTP API
```

Demo mode follows a parallel local path:

```text
Flutter UI
  -> Riverpod provider or feature repository
  -> DemoDataStore
  -> in-memory API-shaped data
```

The architecture has strong application composition, routing, session handling,
design-system, and test foundations. Its primary maintainability constraint is
that the Home library and several feature pages combine presentation, response
mapping, state orchestration, and data-source selection in large files.

## Repository Structure

```text
lib/
  main.dart                  # Startup and root ProviderScope.
  core/                      # App-wide configuration and infrastructure contracts.
    config/
    i18n/
    infrastructure/
      errors/
      http/
      logging/
      persistence/
      routing/
    network/                 # Shared response envelope.
    services/                # Secure session persistence.
    utils/
  network/                   # Dio composition, API adapter, auth interceptor.
  routing/                   # GoRouter routes and redirect policy integration.
  features/
    auth/                    # Full data/domain/presentation layering.
    budget/                  # Domain models, repository, presentation.
    demo/                    # In-memory alternate data source.
    home/                    # Authenticated shell and finance UI library.
    onboarding/             # Local onboarding state and UI.
    profile/                # Domain profile model and presentation orchestration.
    settings/               # Account-backed preference synchronization.
    setup/                   # First-login setup state and UI.
    splash/                  # Startup presentation.
    statistics/             # Domain models, repository, query context, UI.
  shared/                    # Cross-feature formatters, assets, and widgets.
  theme/                     # Design tokens, semantic colors, fonts, theme state.
```

At the analyzed baseline, `lib/` contains 85 tracked Dart files, including 12
generated `*.g.dart` or `*.freezed.dart` files. The committed test suite contains
37 Dart test files plus browser and shell-based acceptance assets.

## Application Composition

### Startup

`lib/main.dart` is the composition root. Startup performs four ordered steps:

1. Initialize Flutter bindings.
2. Resolve compile-time runtime configuration through `AppConfig.init()`.
3. Load bundled regional fonts before the first frame.
4. Start the widget tree inside a root `ProviderScope`.

`CashLenXApp` watches router, theme mode, theme color, and language providers and
builds `MaterialApp.router`. Locale, theme, and navigation changes therefore
recompose from Riverpod state instead of a separate service locator.

Although `get_it` and `injectable` are declared dependencies, committed runtime
code does not import them. Active dependency injection is Riverpod-based.
Likewise, `fpdart` and `equatable` are declared but not imported by committed
`lib/` code.

### Routing and Access Control

`lib/routing/app_router.dart` owns route registration and global redirection.
Its redirect decision combines three asynchronous state sources:

- authentication state;
- onboarding completion;
- first-login setup completion.

The pure-Dart `AuthRedirectPolicy` holds the redirect rules, while GoRouter owns
URL parsing, history, and page construction. Protected route widgets perform a
second defensive session/setup check before rendering authenticated content.

Primary authenticated destinations use `NoTransitionPage` and reuse
`HomePage` with a `HomeSection` value. Profile and transaction detail are
secondary URL-addressable destinations. This keeps browser refresh and history
coherent, but also makes `HomePage` the central coordinator for several feature
surfaces.

## Layer Model

### Presentation

Presentation is implemented with Flutter widgets plus Riverpod providers. The
App uses both generated providers (`@riverpod`, `@Riverpod`) and manually
declared `Provider`, `FutureProvider`, and `NotifierProvider` instances.

Three state styles coexist:

| State type | Typical use | Examples |
| --- | --- | --- |
| Global reactive state | Session and durable user preferences | `AuthNotifier`, `i18nProvider`, `themeColorProvider`, `currencyProvider` |
| Request state | Asynchronous feature data | `_dashboardProvider`, `monthlyBudgetsProvider`, `statisticsProvider` |
| Widget-local state | Drafts, filters, navigation details, loading flags | Transaction sheets, Profile editing, category editor |

This mix is pragmatic. Riverpod owns state that crosses route or feature
boundaries, while short-lived interaction state remains close to its widgets.
The cost is inconsistent invalidation and error-handling patterns across
features.

### Domain

Domain code is small and Flutter-independent:

- Auth owns the generated `User` model and `AuthRepository` contract.
- Budget owns `BudgetItem` and `BudgetCategory`.
- Statistics owns `AnalyticsRange`, `StatisticsSnapshot`, and `TopExpense`.
- Profile owns `UserProfile`, which reuses the Auth `User` model as a fallback.

Budget, Statistics, and Profile domain objects currently parse wire-shaped maps
themselves. They are pure Dart, but they are not fully isolated from transport
field names. Auth is the only feature with a distinct DTO layer.

There is no explicit use-case/interactor layer. Business operations are handled
by Riverpod notifiers, repositories, services, and page controllers.

### Data and Infrastructure

The shared network stack is layered as follows:

```text
CashlenxApi
  -> ApiClient implements RestClient
  -> Dio
     -> RequestTrackingInterceptor
     -> AuthInterceptor
```

- `CashlenxApi` is the App-specific endpoint adapter and request-shaping layer.
- `ApiClient` provides HTTP verbs and maps Dio failures into App exceptions.
- `RestClient` is the transport abstraction used by `ApiClient`.
- `AuthInterceptor` attaches access tokens, serializes concurrent refreshes,
  retries eligible requests, and expires only the still-current session.
- `RequestTrackingInterceptor` centralizes request logging.
- `ResponseWrapper<T>` models the standard response envelope where typed
  decoding is used.

`AppConfig` builds the API base URL from compile-time `APP_ENV`, `API_SCHEME`,
`API_DOMAIN`, `API_PORT`, and `API_VERSION` definitions. Environment files are
operator/build inputs; they are not loaded as a Flutter runtime asset.

## Feature Boundaries

### Authentication: Complete Layered Feature

Authentication has the clearest dependency chain:

```text
Auth pages
  -> AuthNotifier
  -> AuthRepository interface
  -> AuthRepositoryImpl
  -> AuthRemoteDataSource
  -> CashlenxApi
```

Freezed/json_serializable models define request, response, and user data.
`AuthRepositoryImpl` coordinates secure token persistence and remote calls.
`SecureStorageService` depends on the `KeyValueStore` abstraction, allowing
memory-backed unit tests without platform storage.

The feature has one deliberate cross-feature dependency: `AuthNotifier` resets
`DemoDataStore` when the user enters Demo mode.

### Home: Shell and Integration Boundary

`HomePage` owns the authenticated shell, bottom navigation, secondary in-shell
destinations, Profile refresh, dashboard invalidation, and add-transaction
sheet. Its presentation is split into Dart `part` files:

- `dashboard_tab.part.dart`;
- `category_tab.part.dart`;
- `transactions.part.dart`;
- `settings_tab.part.dart`;
- `shared_widgets.part.dart`;
- `home_models.part.dart`.

These files form one private Dart library. The split reduces individual editing
scope, but it is not a module boundary: all private models and helpers remain
shared, and the parts cannot be imported or tested as independent libraries.

Home also directly depends on Auth, Budget, Demo, Profile, Settings, Statistics,
the API adapter, formatting, routing, and theme layers. It is therefore both a
UI shell and the principal application-integration boundary.

### Budget and Statistics: Lightweight Repository Features

Budget and Statistics each have pure domain models, a feature repository, and
a presentation surface. Their repositories select between `CashlenxApi` and
`DemoDataStore` and map API-shaped data into typed domain objects.

Statistics performs summary, series, and top-expense requests concurrently,
then normalizes data into a `StatisticsSnapshot`. Its query object gives
Riverpod family caching stable value equality.

These features are more isolated than Home, but their data-layer providers
depend directly on the Auth presentation provider to determine Demo mode.
That dependency points across feature layers and is a notable architectural
shortcut.

### Profile: Typed Model, Presentation-Owned Orchestration

Profile has a domain model but no repository or data source. `ProfilePage`
chooses live versus Demo data, invokes the data source, maps responses, validates
drafts, and owns loading/error/editing state. This is cohesive for a single
screen but concentrates multiple responsibilities in a large presentation file.

### Settings, Setup, and Onboarding

- Settings synchronizes language, currency, theme color, and setup state with
  the account or Demo configuration, while retaining local values as fallback.
- Setup combines account-backed configuration with a per-user local completion
  marker.
- Onboarding uses a small SharedPreferences-backed service.

These are service-oriented feature slices rather than complete
data/domain/presentation stacks. Settings and Setup import providers owned by
Auth, Home, i18n, and Theme, so user-configuration state is distributed across
several feature and application-level modules.

### Demo Mode: Parallel In-Memory Backend

`DemoDataStore` is a singleton Riverpod-provided in-memory store. It implements
profile, configuration, dashboard, transaction, category, budget, and
statistics behavior using API-shaped maps. `demoDataRevisionProvider` acts as a
manual invalidation signal after mutations.

This design provides meaningful offline demonstration without authenticated
requests and allows live and Demo presentation paths to share mapping logic. Its
tradeoff is schema coupling: Demo imports the network `ApiJson` alias and must
manually track response shapes and business behavior exposed by the live API.

## Persistence Model

| Storage | Data | Lifetime |
| --- | --- | --- |
| Secure storage | Access token, refresh token, remember-me flag | Across launches |
| SharedPreferences | Onboarding, per-user setup completion, language, currency, theme color | Across launches |
| Account configuration API | Language, currency, theme color, setup completion | Across devices |
| Riverpod memory | Session state, async request state, navigation context | Process/session |
| `DemoDataStore` | Demo finance, profile, category, budget, and configuration data | Current Demo session |

The App treats account configuration as authoritative when available and keeps
local preferences as an offline fallback. Secure session writes persist the
rotating refresh credential before the access token and clear partial writes.

## Design System and Localization

`AppDesignTokens` centralizes semantic colors, a 4 px spacing grid, radii, motion
durations, and the 430 px mobile canvas boundary. `AppSurfaceColors` is a
`ThemeExtension` that provides semantic light and dark surfaces. Shared widgets
package recurring panels, cards, inputs, buttons, logos, and responsive shells.

Localization is provider-driven and currently stores translation maps in
`app_i18n.dart`. English, Simplified Chinese, and Traditional Chinese share the
same lookup API. Bundled regional Noto Sans fonts are loaded before the first
frame and selected by the active locale.

The centralized theme and shell architecture is strong. The monolithic
translation file is a scaling concern because locale data, locale state, and
translation access live in one source file.

## Code Generation

Riverpod Generator creates provider glue, while Freezed and json_serializable
generate immutable Auth models and JSON codecs. Generated files are committed
and excluded from analyzer input. Source files remain the edit boundary; the
generated `*.g.dart` and `*.freezed.dart` files must not be edited manually.

## Testing Architecture

The test suite mirrors the production structure across core infrastructure,
features, networking, routing, shared widgets, theme, and visual baselines.
Notable seams supporting isolation include:

- `KeyValueStore` with secure and memory implementations;
- `RestClient` around Dio operations;
- injectable Dio factories in `AuthInterceptor` tests;
- Riverpod provider overrides;
- pure redirect, formatting, and response-normalization logic;
- golden coverage at phone, shell, tablet, desktop, light, and dark sizes;
- a containerized browser journey for real-account and Demo behavior.

The current design gives the strongest unit isolation to infrastructure, Auth,
Budget, and Statistics. Large Home and Profile presentation files rely more on
widget-level coverage.

## Architectural Strengths

1. Riverpod provides a consistent composition mechanism and avoids a hidden
   global service locator in active code.
2. Auth has clear contracts, typed models, testable persistence, and robust
   rotating-token concurrency behavior.
3. Routing is URL-aware and separates pure redirect policy from GoRouter wiring.
4. Domain objects are Flutter-independent.
5. Demo mode is isolated from authenticated credentials and supports meaningful
   editable journeys.
6. Design tokens, semantic surfaces, responsive shell behavior, localization,
   and bundled fonts are centralized.
7. Tests cover infrastructure contracts, major feature behavior, routing,
   accessibility-sensitive widgets, and visual regression.

## Coupling and Maintainability Risks

### 1. Home Is a Large Shared Library

The largest committed source files are the transaction part at approximately
3,073 lines and the category part at approximately 1,286 lines. Because all
Home parts share one private library, data models, API orchestration, widgets,
and local state remain tightly coupled despite the physical file split.

### 2. Layering Is Inconsistent

Auth uses repository and data-source abstractions, while Home and Profile call
`CashlenxApi` and `DemoDataStore` directly. Budget and Statistics sit between
those approaches. Cross-feature imports also reach from data modules into Auth
presentation state and from Settings/Setup into Home-owned currency state.

### 3. Transport Shapes Leak Upward

`ApiJson` maps and response-envelope unwrapping appear in repositories,
presentation-owned models, Profile, and Demo code. This raises the cost of API
shape changes and makes Demo parity a manual responsibility.

### 4. The API Adapter Is Broad

`CashlenxApi` is approximately 750 lines and contains system, authentication,
user, admin, cash-flow, category, budget, and statistics endpoints. It provides
a useful single request contract today, but its change surface grows with every
feature.

### 5. State Ownership Is Distributed

Account configuration spans Settings synchronization, Home-owned currency,
core i18n, Theme, Setup, SharedPreferences, and remote configuration. The
behavior is implemented and tested, but no single domain-facing configuration
controller owns the entire lifecycle.

### 6. Declared Dependencies Exceed Active Architecture

`get_it`, `injectable`, `fpdart`, and `equatable` are declared but not used by
committed `lib/` code. Keeping unused architectural dependencies can obscure
the intended standard and increases dependency maintenance.

## Recommended Evolution

These are maintainability recommendations, not claims of missing user-facing
functionality.

1. Extract Transactions and Categories from the Home private library into
   independent feature modules with public typed contracts.
2. Introduce feature repositories for Profile, Transactions, Categories, and
   Dashboard before adding more presentation behavior.
3. Replace repeated live-versus-Demo branching with feature data-source
   interfaces whose implementations are selected by providers.
4. Move API response parsing into data-layer DTOs and mappers so domain and
   presentation code receive typed objects.
5. Create one application-level user-configuration controller that owns local
   fallback, account synchronization, currency, language, theme, and setup
   completion.
6. Split `CashlenxApi` into feature-oriented clients while retaining `ApiClient`
   and shared interceptors.
7. Split translations by locale or generated localization resources when the
   translation catalog grows materially.
8. Remove unused dependencies or adopt them deliberately; Riverpod should remain
   the single dependency-injection convention unless a documented need changes
   that decision.
9. Preserve current routing, secure-session, design-token, accessibility, and
   golden-test boundaries during refactoring.

## Intended Dependency Direction

The preferred direction for new or extracted features is:

```text
presentation
  -> application controller / provider
  -> domain repository contract
  <- data repository implementation
     -> remote or Demo data source
        -> shared network / persistence infrastructure
```

Framework and transport types should remain at the edges. Domain models and
repository contracts should remain pure Dart, and feature-to-feature access
should use stable contracts rather than another feature's presentation provider.

## Related Documents

- [App summary](README.md)
- [Implemented feature inventory](implemented-features.md)
- [System testing strategy](../testing.md)
- [Product scope and flows](../product-and-flows.md)
