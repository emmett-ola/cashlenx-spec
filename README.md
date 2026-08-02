# CashLenX Spec

This directory is the specification and delivery-control workspace for CashLenX. It consolidates current product rules, architecture facts, API summaries, delivery scope, validation evidence, durable decisions, and historical source material for the CashLenX app, server, design reference, and website.

CashLenX is a personal-finance product for recording income and expenses, organizing cash flows by category, viewing summaries and reports, and managing account preferences.

## Workspace

The local workspace contains these project areas:

| Path | Purpose |
| --- | --- |
| `../cashlenx-app` | Cross-platform Flutter client. |
| `../cashlenx-server` | Go REST API server and Cobra CLI. |
| `../cashlenx-design` | Figma-exported React/Vite visual reference. |
| `../cashlenx-website` | Vite/React public documentation scaffold. |
| `../cashlenx-spec` | Product, system, and delivery specifications. |

The outer workspace is not assumed to be a Git repository.

## Current Map

| Area | Purpose |
| --- | --- |
| `WORKFLOW.md` | Risk-proportionate delivery workflow, evidence rules, Human gates, state semantics, and closeout rules. |
| `GUIDELINE.md` | Reusable engineering and product principles. |
| `system/` | Durable current facts: product flows, domain model, API contract, app, server, design, website, operations, and testing. |
| `versions/` | Versioned delivery records, validation evidence, and templates. |
| `backlog/` | Deferred candidates, known gaps, and open product questions. |
| `decisions/` | ADR-style durable decisions. |
| `sources/` | Copied Markdown source material from sibling projects, excluding their `README.md` files. |

## Reading Order

1. `AGENTS.md`: agent operating rules and repository boundaries.
2. `WORKFLOW.md`: work levels, evidence triggers, Human gates, version states, and closeout rules.
3. `GUIDELINE.md`: reusable product and engineering principles.
4. `system/README.md`: stable current system facts.
5. `versions/README.md`: version workflow and current version plan.
6. `backlog/README.md`: deferred work and open questions.
7. `decisions/README.md`: durable decisions.

## Current Planning Position

- Product status: active `v0.x` development.
- Server API path: `/api/v0`.
- Server status: `v0.9.0` implementation and local verification are complete; `v0.10.0` cloud and self-hosted hardening is the active server milestone.
- App status: authenticated shell and core finance flows are implemented, with budget mutation and full statistics UI still incomplete.
- Default development database: MongoDB; MySQL 8 is also supported and covered by the Flutter/API smoke flow.
- Spec status: pre-baseline. Create the first formal baseline later after the beta readiness boundary is selected.

## Source Of Truth Rules

- `system/` is the canonical current-facts layer.
- `versions/` is delivery history and active delivery control after durable facts are promoted.
- `backlog/` owns deferred scope and unresolved questions.
- `decisions/` owns durable decisions that should remain discoverable after a version closes.
- `sources/` and design reference material are evidence inputs, not proof of current implementation by themselves.
- For server routes and behavior, inspect `../cashlenx-server/controller/server.go` and `../cashlenx-server/docs/openapi.yaml` first.
- For client API usage and user-facing app behavior, inspect `../cashlenx-app/lib/network/cashlenx_api.dart` and active feature files.
- For visual and interaction reference, inspect `../cashlenx-design/src/app/components/` and shared design constants.
- For website documentation structure, inspect `../cashlenx-website/src/App.tsx` and `../cashlenx-website/docs/`.
- When this spec conflicts with implementation, implementation wins until the spec is corrected.

## Working Rule

Keep all files in this spec workspace in English. Agent-specific rules belong in `AGENTS.md`; workflow rules belong in `WORKFLOW.md`; reusable principles belong in `GUIDELINE.md`; project facts belong in `system/`, `versions/`, `backlog/`, or `decisions/`.
