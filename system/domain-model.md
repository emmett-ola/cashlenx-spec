# Domain Model

This document records current domain concepts at specification level. Exact persistence fields should be checked against the server models, OpenAPI contract, and client DTOs before implementation work.

## Core Concepts

### User

A registered account that owns profile data, configuration, cash flows, categories, and user-scoped import/export data.

Related behavior:

- Registration and login.
- Profile query/update.
- Password reset/change.
- Email change request/confirm.
- Account deletion.
- User database backup/restore.

Role lifecycle:

- Startup bootstraps an administrator only when no administrator account exists.
- Registration and normal user-management creation create `user` accounts, not administrators.
- Generic user updates cannot change roles, and administrator accounts cannot be deleted through the normal delete flow.

### Session And Token

Authentication uses JWT access tokens plus persisted refresh tokens.

Related behavior:

- Normal login returns access and refresh tokens.
- Refresh login is performed by passing `refresh_token` to `POST /open/auth/login`.
- The Flutter app stores access token, refresh token, and remember-me state in secure storage.
- The app auth interceptor injects bearer tokens and attempts one silent refresh on eligible 401 responses.
- Password changes and account deletion revoke the user's persisted refresh tokens.

### Verification Code

A purpose-scoped record used by sign-up, password-reset, and email-change flows.

- New active codes supersede earlier active codes for the same purpose and subject.
- Codes have an expiry and are marked used after successful completion.

### Profile

User-facing identity preferences supported by the app and API.

Current app-supported fields:

- `nickname`
- `avatar_url`
- `gender`

Avatar behavior:

- Avatars are selected from fixed preset assets.
- User-uploaded avatars are not supported.
- The selected preset asset path is stored in `avatar_url`.

### Configuration And Preferences

The server exposes user configuration endpoints. The app currently keeps some preferences locally.

Current app-local preferences include:

- Currency.
- Theme color.
- Language.

### Cash Flow

A user-owned income or expense record.

Money calculations use decimal values rather than binary floating-point values.

Current behavior includes:

- Create income.
- Create expense.
- List cash flows.
- Query by ID, date, and range.
- Update cash flow.
- Delete cash flow.
- Summarize total, daily, monthly, and yearly values.

Important current enum values use lowercase examples:

- `income`
- `expense`

### Category

A user-owned classification for cash flows.

Current behavior includes:

- Create, list, query, update, and delete.
- Lookup by name.
- Lookup children by parent ID.
- Query the category tree.
- Support hierarchical parent/child categories in the app selector.

### Statistic

Derived reporting data over cash flows.

Current server capabilities include:

- Summary by daily, monthly, and yearly period.
- Breakdown by daily, monthly, and yearly period.
- Trends by daily, monthly, and yearly period.
- Top expenses by daily, monthly, and yearly period.
- Dashboard data by period and date.
- Chart data for income/expense, category distribution, monthly comparison, and spending heatmap.

### Import, Export, Backup, And Restore

The server exposes:

- User-scoped statistic export/import.
- User-scoped database backup/restore.
- Admin database backup/restore.

File download endpoints may return binary content instead of the JSON response wrapper.

### Entity Lifecycle And IDs

- Core persisted entities use soft deletion through `is_delete` plus deletion audit metadata.
- Normal reads exclude soft-deleted records; administrative backup and explicit include-deleted operations are exceptions.
- Server startup initializes a Snowflake ID generator, while some current entity and validation paths still retain MongoDB ObjectID assumptions. ID changes must account for both behaviors until the legacy dependency is removed.

### Admin User

An authenticated admin can manage users and perform full database backup/restore operations.
