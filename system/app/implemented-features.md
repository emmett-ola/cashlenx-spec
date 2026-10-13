# Implemented App Features

## Verified Baseline

- App version: `1.1.1+18`.
- Source commit: `a74effdd1d4be826e8158e22820458611bce9d05` on `develop`.
- Scope: committed Flutter App behavior only. Local uncommitted platform and
  tooling changes are excluded from this inventory.
- Runtime model: authenticated users use the live API; Demo users use an
  isolated, resettable in-memory data store.

## Startup and Onboarding

- [x] Localized splash screen with the official CashLenX brand mark.
- [x] Three-page photographic onboarding flow with branded loading and error
  fallbacks.
- [x] First-login setup with the complete 21-currency catalog.
- [x] Authenticated setup persists the selected currency before completion.
- [x] Existing users restore account-backed currency, language, theme, and setup
  state on a clean device.
- [x] Unknown-route recovery and authenticated route redirection.

## Authentication and Session

- [x] Sign in with email address or username and password.
- [x] Optional remember-me behavior backed by secure storage.
- [x] Registration with email verification, a focused six-digit code input,
  resend countdown, and return-to-edit-email action.
- [x] Password-reset request and completion flows.
- [x] Complete access-token and refresh-token session persistence.
- [x] Shared refresh for concurrent `401` responses.
- [x] Session expiry when refresh credentials are rejected while transient
  network failures retain the session for a later retry.
- [x] Logout clears local authority before the remote request completes.
- [x] Rejected login remains on the form, retains entered values, and presents
  the error without redirecting through Splash.

## Authenticated Navigation

- [x] Primary Home, Transactions, Add, Budget, and Settings destinations.
- [x] Primary destinations replace shell content without a whole-canvas
  horizontal transition.
- [x] URL-addressable Profile and transaction-detail destinations.
- [x] Transaction detail returns to its originating Home or Transactions context
  and keeps a stable fallback after a direct URL refresh.
- [x] Home Recent Activity links to the shared Transactions destination.

## Dashboard

- [x] Real API-backed finance dashboard for authenticated users.
- [x] Balance, income, and expense summaries for Day, Month, Year, and Total.
- [x] Day is the default dashboard period.
- [x] Recent transaction activity.
- [x] Compact Financial Insights entry into expanded Statistics.
- [x] Consistent income-green and expense-red cash-flow semantics.

## Transactions

- [x] Paginated transaction list with loading, empty, error, and retry states.
- [x] Add, view, edit, and delete transactions.
- [x] Shared add/edit experience for amount keypad, transaction type, category,
  date, description, remark, and attachment placeholder.
- [x] Independent remembered category selection for income and expense.
- [x] Search plus type, category, and inclusive date-range filters.
- [x] Removable active-filter chips, localized result summaries, and filtered
  empty-state recovery.
- [x] Authenticated range queries through `/cash/range` and equivalent local
  Demo filtering.
- [x] Category presentation reconciliation for compatible legacy cash-flow
  payloads that omit category display fields.

## Categories

- [x] Hierarchical income and expense category management.
- [x] Create, update, and delete operations.
- [x] Emoji and background-color customization.
- [x] Category appearance persists after authenticated list or tree reloads.
- [x] Equivalent editable category behavior in Demo mode.
- [x] Category management is available from Settings under Resource Management.

## Budgets

- [x] Monthly category-budget creation, editing, and deletion.
- [x] Month navigation with localized month labels.
- [x] Ledger-derived budget usage and progress.
- [x] Loading, empty, error, and retry states.
- [x] Selected-currency minor-unit precision, including zero-decimal currencies.
- [x] Mutable isolated Demo budgets.

## Statistics

- [x] Expanded Day, Month, and Year statistics.
- [x] Matching period selection and navigation for each range.
- [x] Summary, trend, and top-expense data for authenticated and Demo users.
- [x] Year mode normalizes compatible monthly responses into January through
  December and zero-fills missing months.
- [x] All twelve localized year labels remain visible on compact and wide layouts.
- [x] Dashboard Total opens Statistics in Year mode.

## Profile

- [x] Profile retrieval and update.
- [x] Editable nickname, preset avatar, phone number, location, and birth date.
- [x] Read-only account identity context, including email.
- [x] Presentation-only account statistics using the active currency symbol.
- [x] Fixed preset avatar library with a defined fallback asset.
- [x] Profile data retains API-supplied `gender`, although the current screen does
  not provide a gender editor.

## Settings and Configuration

- [x] Theme mode and user-selected accent color.
- [x] Currency selection from the 21-currency catalog.
- [x] English, Simplified Chinese, and Traditional Chinese language selection.
- [x] Authenticated configuration synchronization for currency, language, theme,
  and setup completion, with local state retained as an offline fallback.
- [x] Settings is the sole UI owner for currency, language, and theme preferences.
- [x] About view with independent App Version, API runtime Version, and
  artifact-generated UTC Build Date.
- [x] Logout action.

## Currency and Localization

- [x] One catalog symbol source across Home, Transactions, entry/editing,
  Statistics, Budget, and presentation-only Profile statistics.
- [x] Responsive display for multi-character currency symbols.
- [x] Zero-decimal handling for JPY, KRW, and VND.
- [x] Currency changes alter presentation and input precision without converting
  or rewriting stored numeric values.
- [x] Localized transaction dates, calendar month titles, weekday labels, and
  locale-specific first-day-of-week behavior.
- [x] Repository-owned Noto Sans SC and TC fonts loaded before the first Flutter
  frame, without a runtime font-network dependency.

## Demo Mode

- [x] Entry without authenticated credentials.
- [x] Real session credentials are cleared before Demo starts.
- [x] Finance, profile, category, budget, currency, and theme data reset for each
  Demo session.
- [x] The language selected before entry carries into the Demo configuration.
- [x] Transactions, categories, budgets, statistics, profile, and settings remain
  editable in memory.
- [x] Demo mode does not call authenticated APIs.

## Responsive UI, Themes, and Accessibility

- [x] Full-width phone presentation centered within a 430 px maximum mobile
  canvas on wider hosts.
- [x] Phone, tablet, desktop, light-theme, and representative dark-theme golden
  coverage.
- [x] Shared semantic light and dark surfaces across authenticated and
  unauthenticated flows.
- [x] User accent color applied to primary controls, accents, selected states,
  and highlights while Splash remains brand-stable.
- [x] Keyboard-inset and safe-area handling for transaction entry on phone,
  tablet, and desktop layouts.
- [x] Reachable navigation and actions under large text scaling.
- [x] Localized semantic labels for icon-only navigation and actions.
- [x] Reduced-motion support that removes scale and validation displacement while
  retaining immediate validation feedback.
- [x] Centralized colors, 4 px spacing increments, and 8/16/24 px radii in
  `AppDesignTokens`.

## Current Exclusions and Placeholders

- [ ] Transaction attachment selection, upload, preview, and download; the App
  currently exposes only an attachment placeholder.
- [ ] User-uploaded custom avatars; the App currently uses preset assets.
- [ ] User-facing data export and import workflows.
- [ ] User-facing email change, password change, and account deletion controls.
- [ ] A Profile gender editor, despite model support for API-supplied values.
- [ ] A durable offline finance database or persistent response cache.
- [ ] Additional statistics chart families beyond the implemented summary,
  trend, and top-expense views.

## Related Documents

- [App architecture and behavior summary](README.md)
- [Product scope and flows](../product-and-flows.md)
- [Testing strategy](../testing.md)
