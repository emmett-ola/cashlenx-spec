# CashLenX Engineering And Product Guideline

This is the reusable charter for CashLenX delivery. It records how to think about product, architecture, quality, and documentation. Execution workflow belongs in `WORKFLOW.md`, agent-enforced rules in `AGENTS.md`, current facts in `system/`, version evidence in `versions/`, durable decisions in `decisions/`, and deferred work in `backlog/`.

## 1. Evidence First

- Start from implementation code, OpenAPI contracts, tests, source docs, design reference, operations evidence, and explicit user decisions.
- Keep verified facts, reasonable inferences, and unresolved questions distinct.
- When evidence conflicts, preserve the conflict until resolved; update the canonical fact when a later verified decision supersedes it.
- Do not broaden exact routes, fields, enum values, auth semantics, security behavior, or release commitments while summarizing.

## 2. Strict Scope, Extensible Shape

- Implement and document only confirmed behavior.
- Keep unconfirmed finance features, analytics, import/export exposure, deployment models, and platform assumptions in `backlog/` until selected for a version.
- Preserve extensibility through clear domain ownership, stable names, versioned contracts, migrations, and small adapters.
- Unconfirmed sensitive behavior defaults to the narrowest safe scope, usually disabled, authenticated-only, or admin/management-only.
- Avoid scattering future ideas through current-fact documents; current-fact files describe what is true now.

## 3. One Owner Per Fact

- `system/` owns verified current product, domain, API, app, server, design, website, operations, and quality facts.
- `WORKFLOW.md` owns work levels, Human gates, evidence triggers, state semantics, and closeout flow.
- `versions/` holds proportionate delivery evidence; closed versions are history, not current truth.
- `decisions/` owns durable decisions that should remain discoverable after a version closes.
- `sources/` contains copied source material from sibling projects. It is evidence input, not current truth by itself.
- `GUIDELINE.md` changes when reusable principles change; `AGENTS.md` changes when future agents need a different enforceable rule.

## 4. Stable Boundaries

- Keep app, server, design reference, website, and spec as independent project areas.
- Centralize API base path and version configuration. Business API wrappers and route summaries should avoid duplicating version assumptions outside their configured boundary.
- Keep external JSON fields, API routes, environment variables, and enum examples exactly named.
- Preserve implementation repositories as independently buildable and testable; documentation may describe them but must not become a runtime or build dependency.
- Use stable naming across Go, Dart, OpenAPI, database, and configuration boundaries.
- Remove obsolete placeholder notes and duplicate policy owners once their retained value is promoted into the canonical document.

## 5. Data, Configuration, And Security

- Treat migrations and OpenAPI as authoritative implementation evidence for persistence and API contracts.
- Keep tracked environment templates free of secrets, and keep ignored local environment files structurally aligned without overwriting real local values.
- Environment-template synchronization is workspace coordination owned by `cashlenx-spec`, not runtime project functionality. After changing any project `.env.sample`, run `cashlenx-spec/scripts/sync-env.sh` from the workspace so missing keys are added to ignored local `.env` files while existing configured values remain unchanged.
- `.env.testing` and `.env.production` are separate owner-managed sensitive deployment files. Keep them ignored and never inspect or synchronize their contents without explicit owner authorization.
- Never place credentials in tracked files or logs. Treat a potentially real exposed credential as compromised and rotate it before use.
- Keep token lifecycle, secure storage, CORS, operational endpoints, file import/export, backup/restore, and database restore behavior bounded by explicit authorization, error, validation, and audit assumptions before production use.
- Mock or demo data must be selected intentionally. API failures should expose loading, empty, error, retry, or unsupported states rather than silently substituting demo data.

## 6. Quality And Delivery

- Select only quality scenarios triggered by the change; not every task needs a broad release checklist.
- Test positive behavior and the first blocked, unauthorized, repeated, or failed path whenever the contract makes those cases relevant.
- Treat project-owned compiler warnings, stale facts, broken links, exposed secrets, contradictory policy owners, and mismatched route summaries as defects.
- Keep workflow state separate from deployment state and report both accurately.
- Close work when its stated scope and evidence are complete; future scope belongs in `backlog/` or a new version.
