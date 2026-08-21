# Backlog

This directory contains deferred CashLenX candidates and open product questions. Promote an item into `versions/` when it has a clear delivery boundary.

The first beta boundary is tracked in `beta-baseline.md` until its implementation refs, affected project areas, and fresh validation evidence are selected.

## Product Gaps

The design-to-app-to-API capability matrix and selected delivery targets are
maintained in `design-parity-api-integration.md`.

- Explicit date-range filtering in the app transaction list.
- Complete the existing server statistics integration in the app: summary,
  trends, breakdown, top-expense screens, charts, and period controls.
- Export/import UI scope and priority.
- URL-addressable shell tabs.
- App home shell decomposition by feature.
- Additional auth provider/repository unit coverage.
- Accessibility review for contrast, labels, tap targets, keyboard navigation, and responsive behavior.
- Hardened secure storage and token lifecycle behavior per platform.
- MongoDB applied-version migration tracking.

## Engineering Debt

- Expand isolated server integration coverage for mapper and database-backed service paths while keeping live database checks outside the normal unit suite.
- Add service seams and fakes for remaining Cobra command and controller success/error paths that still depend directly on package-level services or mapper globals.
- Replace legacy database-helper `panic` and `log.Fatal` behavior with explicit error propagation where practical.
- Decide whether eager MongoDB initialization in the Cobra root command should remain asymmetric with MySQL initialization.
- Retire or rewrite `cashlenx-server/docker/mongodb/init-mongo-demo.js`; its legacy single-user fixture does not match current ownership, audit, category-type, or BSON date behavior.
- Select and document the future production email-provider strategy before treating SMTP delivery as a stable operational capability.

## Open Product Questions

- What should the final splash subtitle be?
- Which target platform should drive UI decisions first: mobile, web, or equal priority?
- What is the first complete budget workflow?
- Which statistics views are required for the first stable release?

## Candidate Future Version Areas

- Beta baseline: complete the boundary and gates in `beta-baseline.md`, then open a version record.
- Server `v0.10.0` hardening: cloud/self-hosted deployment defaults, CORS, rate limits, secrets, operational endpoints, and shared-cache decision only if multi-instance deployment is adopted.
- Stable `v1.0.0` readiness: deliver the accepted targets in `../decisions/0001-stable-release-api-auth-and-capability-policy.md` together with the selected statistics slice, transaction date-range filtering, release validation, changelog/version synchronization, and production-safe defaults.
- Post-stable maintenance: auth test coverage hardening, additional statistics polish, export/import UI if selected, URL-addressable shell tabs, shell decomposition, accessibility polish, and spec-to-website content pipeline.
- Larger finance/platform features: Budget as a major feature, Kubernetes/Helm support if selected, multi-instance assumptions, shared cache decisions, and MongoDB migration tracking.
