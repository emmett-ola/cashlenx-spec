# Current System

This directory contains the current CashLenX system facts. These documents describe what is true now, not how a historical task got done. Update them when implemented behavior, product scope, API shape, architecture, operations, or durable decisions change.

## Documents

| Document | Purpose |
| --- | --- |
| `product-and-flows.md` | Product scope, users, current flows, and verified implementation limits. |
| `domain-model.md` | Canonical domain concepts and relationships. |
| `api-contract.md` | API versioning, response wrapper, auth model, and route surface summary. |
| `operations.md` | Local runtime, databases, container boundaries, deployment mechanics, configuration synchronization, and operational endpoints. |
| `deployment-profiles.md` | Supported single-node MongoDB and MySQL profiles, isolation, persistence, rollback, capacity, and unsupported topology. |
| `testing.md` | Validation commands, evidence boundaries, and app/server/integration testing strategy. |
| `collaboration.md` | Jira, Confluence, repository ownership, language, issue, version, and synchronization rules. |
| `app/README.md` | Flutter client architecture, behavior, generated-code boundary, and testing entry point. |
| `server/README.md` | Go server architecture, CLI/API entry points, persistence, security boundaries, and testing entry point. |
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
- Keep active versions, Standard and High-impact delivery status, and validation summaries in Jira. Add a repository-local version snapshot only when explicitly required.
- Keep future ideas in `backlog/` until they become active versions.
- If a system rule changes in code, update the affected `system/` file in the same delivery pass.
- Mark source-derived or design-derived assumptions clearly until confirmed by implementation or user decision.
