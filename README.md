# CashLenX Spec

This directory is the specification and delivery-control workspace for CashLenX. It consolidates current product rules, architecture facts, API summaries, delivery scope, validation evidence, durable decisions, and historical source material for the CashLenX app, server, design reference, and website.

CashLenX is a personal-finance product for recording income and expenses, organizing cash flows by category, viewing summaries and reports, and managing account preferences.

## CashLenX Project

CashLenX is developed as a set of independently buildable repositories with
explicit ownership boundaries:

| Repository | Responsibility |
| --- | --- |
| [cashlenx-app](https://github.com/emmett-ola/cashlenx-app) | Cross-platform Flutter client and user experience. |
| [cashlenx-server](https://github.com/emmett-ola/cashlenx-server) | Go REST API, Cobra CLI, authentication, finance services, and MongoDB/MySQL persistence. |
| [cashlenx-design](https://github.com/emmett-ola/cashlenx-design) | Figma-exported React/Vite visual and interaction reference. |
| [cashlenx-website](https://github.com/emmett-ola/cashlenx-website) | Public product and developer-information website. |
| [cashlenx-spec](https://github.com/emmett-ola/cashlenx-spec) | Product and system facts, delivery workflow, decisions, and retained evidence. |

This repository owns the canonical specification and delivery-control layer.
Cross-repository contracts are coordinated through OpenAPI and the workflow in
this repository. Runtime repositories remain independently buildable and do
not depend on the spec or design reference at build time or runtime. The outer
local workspace is not assumed to be a Git repository.

The code repositories (`cashlenx-app`, `cashlenx-server`, and `cashlenx-website`) use `develop` as the default working branch, `testing` as the shared test-environment branch, and `main` as the production release branch. Changes are promoted in the direction `develop` -> `testing` -> `main`; the legacy branch name `test` is not retained. `cashlenx-spec` uses `main` as its only branch. Repository-local commits and branch pushes do not by themselves authorize promotion, publication, or deployment.

## Current Map

| Area | Purpose |
| --- | --- |
| `WORKFLOW.md` | Risk-proportionate delivery workflow, evidence rules, Human gates, state semantics, and closeout rules. |
| `GUIDELINE.md` | Reusable engineering and product principles. |
| `system/` | Durable current facts: product flows, domain model, API contract, app, server, design, website, operations, and testing. |
| `versions/` | Completed repository-local delivery records, validation evidence, and templates for explicit snapshots. |
| `backlog/` | Deferred candidates, known gaps, and open product questions. |
| `decisions/` | ADR-style durable decisions. |
| `release/` | Coordinated product-version input, release notes, immutable tag rules, and artifact-publication contract. |
| `sources/` | Copied Markdown source material and import inventory from sibling projects, excluding their `README.md` files. |
| Jira `CLX` | Active product versions, executable work, acceptance criteria, priorities, dependencies, and workflow state. |
| Confluence | Maintained English instructions and collaboration context for users and developers. |

## Reading Order

1. `AGENTS.md`: agent operating rules and repository boundaries.
2. `WORKFLOW.md`: work levels, evidence triggers, Human gates, version states, and closeout rules.
3. `GOVERNANCE.md`: maintainer authority, repository ownership, Codex-assisted maintenance, and community participation.
4. `GUIDELINE.md`: reusable product and engineering principles.
5. `system/README.md`: stable current system facts.
6. `system/collaboration.md`: Jira, Confluence, and repository ownership rules.
7. `versions/README.md`: retained delivery evidence and optional snapshot policy.
8. `backlog/README.md`: deferred work and open questions.
9. `decisions/README.md`: durable decisions.

Community contributions follow [CONTRIBUTING.md](CONTRIBUTING.md). Report
vulnerabilities according to [SECURITY.md](SECURITY.md).

## Source Of Truth Rules

- `system/` is the canonical current-facts layer.
- Jira `CLX` owns active product-version and task delivery control.
- `versions/` preserves completed repository-local delivery evidence and explicit closeout snapshots.
- `backlog/` owns deferred scope and unresolved questions.
- `decisions/` owns durable decisions that should remain discoverable after a version closes.
- `sources/` and design reference material are evidence inputs, not proof of current implementation by themselves.
- For server routes and behavior, inspect `../cashlenx-server/controller/server.go` and `../cashlenx-server/docs/openapi.yaml` first.
- For client API usage and user-facing app behavior, inspect `../cashlenx-app/lib/network/cashlenx_api.dart` and active feature files.
- For visual and interaction reference, inspect `../cashlenx-design/src/app/components/` and shared design constants.
- For website documentation structure, inspect `../cashlenx-website/src/App.tsx` and `../cashlenx-website/docs/`.
- When this spec conflicts with implementation, implementation wins until the spec is corrected.

Current implementation maturity belongs in `system/`; unopened delivery candidates and readiness work belong in `backlog/`; selected versions and delivery work belong in Jira; completed durable facts return to `system/` and `decisions/`.

## Working Rule

Keep all files in this spec workspace in English. English is also the default for code, Jira, Confluence, commits, and engineering artifacts unless selected i18n work requires localized content. Agent-specific rules belong in `AGENTS.md`; workflow rules belong in `WORKFLOW.md`; reusable principles belong in `GUIDELINE.md`; current facts belong in `system/`; active delivery belongs in Jira; retained closeout evidence belongs in `versions/`; deferred work belongs in `backlog/`; durable choices belong in `decisions/`.

## License

This project is licensed under the [MIT License](LICENSE). Commercial use,
modification, and redistribution are permitted when the copyright and license
notices are retained.
