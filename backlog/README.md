# Backlog

This directory contains deferred CashLenX candidates and open product questions. Promote an item into `versions/` when it has a clear delivery boundary.

The first beta boundary is tracked in `beta-baseline.md` until its implementation refs, affected project areas, and fresh validation evidence are selected.

## Product Gaps

The design-to-app-to-API capability matrix and selected delivery targets are
maintained in `design-parity-api-integration.md`.

- Select app surfaces for the remaining server statistic chart types beyond the
  delivered yearly summary, monthly comparison, and top expenses.
- Export/import UI scope and priority.
- App home shell decomposition by feature.
- Additional auth provider/repository unit coverage.
- Accessibility review for contrast, labels, tap targets, keyboard navigation, and responsive behavior.
- Hardened secure storage and token lifecycle behavior per platform.

## Engineering Debt

- Expand isolated server integration coverage for mapper and database-backed service paths while keeping live database checks outside the normal unit suite.
- Add service seams and fakes for remaining Cobra command and controller success/error paths that still depend directly on package-level services or mapper globals.
- Replace legacy database-helper `panic` and `log.Fatal` behavior with explicit error propagation where practical.
- Decide whether eager MongoDB initialization in the Cobra root command should remain asymmetric with MySQL initialization.
- Retire or rewrite `cashlenx-server/docker/mongodb/init-mongo-demo.js`; its legacy single-user fixture does not match current ownership, audit, category-type, or BSON date behavior.
- Provider-specific email integrations remain deferred; the stable contract is
  vendor-neutral SMTP with deployment-owned credentials.

## Open Product Questions

- What should the final splash subtitle be?

## Candidate Future Version Areas

- Beta baseline: complete the boundary and gates in `beta-baseline.md`, then open a version record.
- Server hardening: cloud/self-hosted deployment defaults, CORS, rate limits,
  secrets, operational endpoints, and shared-cache decisions only if
  multi-instance deployment is adopted.
- Stable `v1.0.0` readiness: deliver the accepted targets in
  `../decisions/0001-stable-release-api-auth-and-capability-policy.md` together
  with the selected statistics slice, release validation, changelog/version
  synchronization, and production-safe defaults.
- Post-stable maintenance: auth test coverage hardening, additional statistics
  polish, export/import UI if selected, shell decomposition, accessibility
  polish, and a spec-to-website content pipeline.
- Larger platform features: Kubernetes/Helm support if selected,
  multi-instance assumptions, shared cache decisions, and organization-level
  multi-tenancy.
