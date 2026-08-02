# Backlog

This directory contains deferred CashLenX candidates and open product questions. Promote an item into `versions/` when it has a clear delivery boundary.

## Product Gaps

- Explicit date-range filtering in the app transaction list.
- Full statistics summary, trends, breakdown, top-expense screens, chart-backed reporting, and period controls.
- Export/import UI scope and priority.
- URL-addressable shell tabs.
- App home shell decomposition by feature.
- Additional auth provider/repository unit coverage.
- Accessibility review for contrast, labels, tap targets, keyboard navigation, and responsive behavior.
- Hardened secure storage and token lifecycle behavior per platform.
- MongoDB applied-version migration tracking.

Explicit transaction date-range filtering and complete statistics/reporting remain deferred for the beta baseline. Their existing app/web entry points may continue to use the coming-soon toast until implementation is selected for a later delivery.

## Open Product Questions

- What should the final splash subtitle be?
- Which target platform should drive UI decisions first: mobile, web, or equal priority?
- Which statistics views are required for the first stable release?

## Candidate Future Version Areas

- Beta baseline: record the first coherent app/server/spec beta baseline once develop readiness is confirmed.
- Server `v0.10.0` hardening: cloud/self-hosted deployment defaults, CORS, rate limits, secrets, operational endpoints, and shared-cache decision only if multi-instance deployment is adopted.
- Stable `v1.0.0` readiness: statistics first slice, transaction date-range filtering, stable `/api/v1`, username/email login, release validation, changelog/version sync, and production-safe defaults.
- Post-stable maintenance: auth test coverage hardening, additional statistics polish, export/import UI if selected, URL-addressable shell tabs, shell decomposition, accessibility polish, and spec-to-website content pipeline.
- Larger finance/platform features: Budget as a major feature, Kubernetes/Helm support if selected, multi-instance assumptions, shared cache decisions, and MongoDB migration tracking.
