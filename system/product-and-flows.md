# Product And Flows

## Product Intent

CashLenX is a personal-finance application for recording cash flows, organizing them by category, viewing summaries, and managing account preferences.

Current English authentication branding uses the subtitle `Your Financial Companion`. Localized variants remain owned by the app's localization resources.

## Primary Users

- Individuals who want a lightweight way to track income and expenses.
- Users who need category-based spending visibility.
- Users who want basic personal finance summaries before advanced reporting.

## Current User-Facing Capabilities

### Authentication

- Register with purpose-scoped email verification.
- Login with username/password.
- Refresh a session through refresh token login.
- Persist access token, refresh token, and remember-me state in secure storage.
- Logout intentionally through the backend logout endpoint when a refresh token is available, then clear local session state.
- Reset password through request and confirm flows.
- Enter demo mode without authenticated backend calls.

### App Shell

- Authenticated users land in a mobile-first home shell.
- Current tabs are Home, Transactions, Add, Budget, and Settings.
- The Transactions tab owns the full cash-flow ledger. Home's recent-activity
  `See All` action opens that same stable destination.
- Category administration is a secondary surface under Settings > Resource
  Management > Category Management.
- The shell contains dashboard, transactions, transaction entry/editing,
  category management, monthly budget management, settings, and profile
  interactions.
- Stable surfaces may not present unfinished placeholder behavior as complete.
- The selected Flutter Web top-level and detail surfaces must become
  URL-addressable and pass refresh, back-navigation, and deep-link acceptance
  before `v1.0.0` closes.

### Cash Flow Tracking

- Create income and expense records.
- View, edit, and delete transactions.
- Search and filter the transaction list by type and category.
- Select hierarchical categories while creating or editing transactions.
- Capture amount, transaction type, category, date, description, remark, and an attachment placeholder in the app UI.
- Refresh dashboard and list state after mutations.

### Categories

- Create, edit, and delete categories.
- Open category administration from Settings > Resource Management rather than
  from primary bottom navigation.
- Use parent/child hierarchy.
- Select a parent to expose children; selecting the active parent can return to the previous level in the app category selector.
- Select an emoji and background color that persist after category refresh,
  screen re-entry, and later sign-in.
- Use the current category icon and color on dashboard and transaction surfaces,
  including with compatible legacy cash-flow responses that expose only the
  category ID.

### Dashboard

- Show balance summaries.
- Show income/expense overview.
- Show the five most recent transactions and link the full list to the primary
  Transactions tab.
- End with a compact Financial Insights entry that opens expanded Statistics;
  the dashboard does not duplicate a category chart.
- Support loading, error, retry, and empty states.
- Use real API data for normal users and session-local demo data for demo users.

### Profile And Preferences

- Fetch and update API-supported profile fields: `nickname`, `avatar_url`,
  `gender`, `phone_number`, `location`, and `birth_date`.
- Use fixed preset avatar assets; user-uploaded avatars are not supported.
- Store selected avatar preset path in `avatar_url`.
- Synchronize currency, theme color, and language through the authenticated user
  configuration API while retaining local offline values.
- Resolve the account-backed setup-completion signal before authenticated route
  selection. A persisted configuration restores currency, language, and theme
  on a clean device; an unconfigured account still enters first-login setup.
- Keep demo profile and configuration changes in the isolated session store.
- Display installed package version and build number in About.

### Statistics And Reporting

- The server exposes statistics summary, breakdown, trends, top expenses, dashboard, chart, import, and export endpoints.
- The app's expanded statistics screen inherits Day, Month, or Year from the
  dashboard and exposes a range selector plus matching date, month, or year
  navigation. Each range uses matching summary, trend, and top-expense data,
  with an isolated ledger-derived demo equivalent.
- Year mode preserves January through December in order, including zero-value
  months, with every localized month label visible on compact and wide layouts.

### Budgeting

- Users can browse budgets by month and create, edit, or delete one limit per
  expense category and month.
- Budget usage is derived from the cash-flow ledger and exposes spent,
  remaining, progress, and over-budget feedback.
- Authenticated users persist budgets through `/budget`; demo users use an
  isolated mutable in-memory equivalent.

## Known Product Limits

- Additional existing statistics breakdown and chart types do not yet have
  selected app surfaces beyond the delivered summary, trend, and top-expense
  views.
- Export/import remains management capability; normal app user UI is deferred.
- Dashboard, category, transaction, and settings presentation remain
  concentrated in the legacy home-shell file; budget and expanded statistics
  have been extracted.

These remain implementation gaps and must not be described as completed capabilities. Stable-release decisions are owned by `../decisions/0001-stable-release-api-auth-and-capability-policy.md`; deferred scope, beta allowances, and open product questions are owned by `../backlog/`.
The complete accepted `v1.0.0` product and platform boundary is owned by
`../decisions/0003-v1-product-deployment-and-autonomous-release-charter.md`.
