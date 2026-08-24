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

The code repositories (`cashlenx-app`, `cashlenx-server`, and `cashlenx-website`) use `develop` as the default working branch, `testing` as the shared test-environment branch, and `main` as the production release branch. Changes are promoted in the direction `develop` -> `testing` -> `main`; the legacy branch name `test` is not retained. `cashlenx-spec` uses `main` as its only branch. Repository-local commits and branch pushes do not by themselves authorize promotion, publication, or deployment.

## Current Map

| Area | Purpose |
| --- | --- |
| `WORKFLOW.md` | Risk-proportionate delivery workflow, evidence rules, Human gates, state semantics, and closeout rules. |
| `GUIDELINE.md` | Reusable engineering and product principles. |
| `system/` | Durable current facts: product flows, domain model, API contract, app, server, design, website, operations, and testing. |
| `versions/` | Versioned delivery records, validation evidence, and templates. |
| `backlog/` | Deferred candidates, known gaps, and open product questions. |
| `decisions/` | ADR-style durable decisions. |
| `sources/` | Copied Markdown source material and import inventory from sibling projects, excluding their `README.md` files. |

## Reading Order

1. `AGENTS.md`: agent operating rules and repository boundaries.
2. `WORKFLOW.md`: work levels, evidence triggers, Human gates, version states, and closeout rules.
3. `GUIDELINE.md`: reusable product and engineering principles.
4. `system/README.md`: stable current system facts.
5. `versions/README.md`: version-record policy, state semantics, templates, and close gate.
6. `backlog/README.md`: deferred work and open questions.
7. `decisions/README.md`: durable decisions.

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

Current implementation maturity belongs in `system/`; unopened delivery candidates and readiness work belong in `backlog/`; opened delivery state and evidence belong in `versions/`.

## Working Rule

Keep all files in this spec workspace in English. Agent-specific rules belong in `AGENTS.md`; workflow rules belong in `WORKFLOW.md`; reusable principles belong in `GUIDELINE.md`; current facts belong in `system/`; opened delivery evidence belongs in `versions/`; deferred work belongs in `backlog/`; durable choices belong in `decisions/`.
