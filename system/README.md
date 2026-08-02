# Current System

This directory contains the current CashLenX system facts. These documents describe what is true now, not how a historical task got done. Update them when implemented behavior, product scope, API shape, architecture, operations, or durable decisions change.

## Documents

| Document | Purpose |
| --- | --- |
| `product-and-flows.md` | Product scope, users, current flows, known limits, and open product questions. |
| `domain-model.md` | Canonical domain concepts and relationships. |
| `api-contract.md` | API versioning, response wrapper, auth model, and route surface summary. |
| `operations-and-testing.md` | Local runtime, databases, deployment notes, and validation commands. |
| `app/README.md` | Flutter client architecture, behavior, and validation facts. |
| `server/README.md` | Go server architecture, CLI/API entry points, persistence, and validation facts. |
| `design/README.md` | Design reference, visual tokens, and UI guidance. |
| `website/README.md` | Website documentation scaffold status. |
| `quality-attributes.md` | Triggered quality scenarios and validation expectations for correctness, auth, data integrity, operations, maintainability, and documentation. |

## Current Source Priorities

1. Implementation code and active contracts.
2. Sibling project docs copied under `../sources/`.
3. Archived staging notes.

Do not promote design-prototype behavior into current facts unless it is implemented or explicitly marked as reference-only.

## Maintenance Rules

- Keep durable facts here after a version is finished.
- Keep Standard and High-impact delivery status and evidence in `versions/`; Lightweight work does not need an empty historical record.
- Keep future ideas in `backlog/` until they become active versions.
- If a system rule changes in code, update the affected `system/` file in the same delivery pass.
- Mark source-derived or design-derived assumptions clearly until confirmed by implementation or user decision.
