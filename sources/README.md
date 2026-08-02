# Imported Sources

This directory contains copied Markdown evidence from sibling CashLenX projects. Imported files remain source snapshots; they do not override verified implementation or the canonical current facts under `../system/`.

## AGENTS.md Imports

Among the sibling projects, the workspace scan on `2026-08-02` found repository-local agent guides only for the app and server projects.

| Source snapshot | Origin | Canonical promotion targets |
| --- | --- | --- |
| `cashlenx-app/AGENTS.md` | `../../cashlenx-app/AGENTS.md` | `../system/app/README.md`, `../system/product-and-flows.md`, `../system/api-contract.md`, `../system/design/README.md`, `../system/operations.md`, `../system/testing.md`, `../GUIDELINE.md`, and `../backlog/README.md` |
| `cashlenx-server/AGENTS.md` | `../../cashlenx-server/AGENTS.md` | `../system/server/README.md`, `../system/domain-model.md`, `../system/api-contract.md`, `../system/operations.md`, `../system/testing.md`, `../GUIDELINE.md`, `../WORKFLOW.md`, `../versions/README.md`, and `../backlog/README.md` |

No `AGENTS.md` was present in `cashlenx-design` or `cashlenx-website` during that scan.

## Import Rules

- Keep imported files as exact snapshots of their sibling source files.
- Verify implementation claims before promoting them into `../system/`.
- Deduplicate reusable principles into `../GUIDELINE.md`, workflow rules into `../WORKFLOW.md`, durable decisions into `../decisions/`, and deferred work into `../backlog/`.
- Do not promote session narration, repository-local commit preferences, or stale branch declarations into canonical current facts.
- When a source changes, refresh the snapshot and recheck only the canonical documents affected by that change.
