# Quality Attributes

This catalog helps select validation scenarios. It is not a universal checklist; use only the categories triggered by the change.

## Correctness

- User-facing finance flows preserve amount, type, category, date, description, remark, and attachment-placeholder behavior across create, edit, list, filter, and delete paths.
- Summary, dashboard, and statistics views distinguish loading, empty, error, retry, and populated states.
- Demo mode uses intentional session-local data and does not mask real API failures for authenticated users.

## Authentication And Authorization

- Authenticated routes require bearer access tokens unless explicitly documented as public.
- Logout remains idempotent and preserves supported single-session and all-session revocation semantics.
- Remember-me restoration is controlled by the server refresh-token lifetime;
  non-remembered persisted tokens are cleared at app startup.
- Concurrent client 401 responses share one refresh rotation. Transient transport
  failure does not sign the user out, while rejected, expired, revoked, or
  replayed refresh credentials fail signed out.
- Refresh credentials are stored server-side as digests, are redacted from
  session inventory and logs, and are revoked before password/account security
  mutations are persisted.
- Admin and management capabilities, including database backup/restore and normal-user export/import exposure, remain explicitly bounded.

## API Compatibility

- API paths, field names, response wrapper shape, enum casing, and error response expectations must match OpenAPI and implementation.
- Stable API changes require compatibility or deprecation evidence.
- File download endpoints may return binary content instead of the JSON response wrapper.

## Data Integrity

- Cash flow and category mutations must remain user-scoped.
- Category hierarchy operations should avoid orphaning or misrepresenting parent/child relationships.
- Import, export, backup, restore, and migration behavior require positive, negative, and recovery evidence when touched.

## Security And Configuration

- Secrets stay out of tracked files, logs, and examples.
- Production startup fails closed for weak authentication/bootstrap secrets, unsafe CORS origins, invalid rate limits, and unprotected metrics exposure. Pprof remains development-only, request logs exclude query strings, and token storage, refresh behavior, and file access retain explicit security review boundaries.
- `.env.example` and ignored local `.env` structure should remain aligned without overwriting local secret values.

## Operations

- Server, app, website, and database startup commands should remain accurate for their owning repositories.
- Deployment state is separate from workflow state.
- Production deployment, release tags, branch promotion, and shared-environment
  mutation require recorded standing or per-action authority and all applicable
  gates to pass. A failed gate, destructive or ambiguous production-data
  action, security exception, secret change, history rewrite, or tag mutation
  requires a new explicit Human decision.

## Maintainability

- Keep one authoritative document per fact.
- Avoid duplicating route lists, policy owners, and roadmap commitments across unrelated files.
- Preserve generated-file boundaries in app/server docs.
- Keep copied source material intact unless a cleanup task explicitly targets it.

## Documentation Validation

- Spec-only work should check Markdown structure, local links or moved paths, stale/conflicting facts, accidental non-English content, and `git diff --check` when Git metadata is available.
- Documentation derived for the website or release notes must be reviewed against current `system/` facts before publication.
