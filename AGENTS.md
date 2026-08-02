# CashLenX Spec Agent Guide

This file is for agent behavior and operating rules only. Delivery workflow belongs in `WORKFLOW.md`, reusable engineering principles in `GUIDELINE.md`, current facts in `system/`, delivery evidence in `versions/`, deferred work in `backlog/`, durable decisions in `decisions/`, and copied source material in `sources/`.

## Startup Rules

- Start by reading `README.md`, then `WORKFLOW.md`, then `GUIDELINE.md`, then `system/README.md`, then `versions/README.md`.
- Before changing or investigating a sibling project, read that project's nearest `AGENTS.md` when one exists. Treat it as repository-local operating guidance and reconcile its durable content with this spec's canonical document owners.
- Use `sources/` as imported source material, not as current truth.
- If specs conflict with implementation, inspect the implementation first and then update the affected spec.
- Do not assume the outer workspace is a Git root.
- Keep edits scoped to `cashlenx-spec` unless the user explicitly asks to update sibling projects.
- Use paths relative to `cashlenx-spec` or the logical workspace root in repository documents. Do not record host-specific drive-letter paths.
- Inspect repository evidence before acting. Separate verified facts, reasonable inferences, and unresolved questions.
- Read delivery history only when the task changes or investigates that scope; Lightweight work does not require unrelated version history.

## Language Rules

- All repository artifacts in `cashlenx-spec` must be written in English.
- User conversation may be in Chinese, but engineering files and spec files must remain English-only unless the user explicitly requests a translation deliverable.
- Preserve exact API route names, field names, enum values, command names, package names, and file paths.

## Repository Boundaries

- Treat `cashlenx-spec`, `cashlenx-app`, `cashlenx-server`, `cashlenx-design`, and `cashlenx-website` as separate project areas.
- Use an existing `develop` branch as the default implementation working branch. Inspect branch and worktree state before switching; do not create, replace, or switch branches when doing so would displace unrelated user work.
- `cashlenx-spec` is the specification workspace and should not contain runtime code.
- Sibling repositories are source-of-truth inputs for implementation facts.
- Sibling implementation repositories must not import, read, link to, build from, test against, or otherwise depend on `cashlenx-spec`.
- Do not put spec workflow rules, spec paths, or AI/Codex attribution into implementation code, configuration, scripts, CI, product copy, or commit messages.
- Do not overwrite unrelated local changes.

## Spec Layering

- `system/` contains durable current facts.
- `versions/` contains delivery records, release scopes, validation evidence, and version-specific notes after a concrete boundary is selected.
- `backlog/` contains deferred candidates, readiness work without a selected delivery boundary, and open product questions.
- `decisions/` contains ADR-style durable product or architecture decisions.
- `sources/` contains copied Markdown source documents from sibling projects.
- `WORKFLOW.md` owns work levels, Human gates, evidence triggers, state semantics, and closeout flow.
- `GUIDELINE.md` owns reusable engineering and product principles.

## Version Workflow Rules

- Open new work as `versions/vX.Y.Z-short-name/` when it has a concrete delivery boundary.
- Use `versions/_template/` for version directories that need a task contract, delivery result, triggered evidence, and closeout record.
- Move durable behavior into `system/` before closing a version.
- Move deferred or rejected ideas into `backlog/`.
- Add ADRs under `decisions/` only for choices that should remain discoverable after a version closes.
- Do not treat a version design document as the current source of truth after implementation; `system/` is the current-facts layer.

## Editing Practices

- Prefer small, stable documents over large mixed notes.
- After completing a request or coherent change set, create a repository-local commit by default unless the user explicitly asks not to commit. Implementation commits use the existing `develop` branch by default; spec-only commits use the current spec governance branch. Stage only intended files. A commit does not authorize push, merge, tag, publication, or deployment.
- Keep product requirements separate from implementation notes.
- At the spec root, keep conventional governance entry points uppercase (`AGENTS.md`, `README.md`, `WORKFLOW.md`, and `GUIDELINE.md`). Below the root, reserve uppercase `README.md` for directory indexes and use lowercase names for other project-authored documents.
- Keep tracked text files on LF line endings through `.gitattributes`, and end files with exactly one newline.
- Keep copied source documents intact unless the user asks for a cleanup pass.
- When importing a sibling `AGENTS.md`, keep an exact snapshot under `sources/<project>/AGENTS.md`, then deduplicate its durable facts, principles, workflow rules, decisions, and deferred work into their canonical spec layers. Do not promote branch names, session narration, or stale implementation claims without verification.
- When importing facts from sources, deduplicate and rewrite them into the current spec structure instead of editing copied source files in place.
- Before finishing a documentation task, check edited files for accidental non-English content.
- Do not keep empty placeholder documentation directories. Create a new information area only when a concrete artifact and authority boundary exist.
- Never copy credentials supplied in chat, tickets, screenshots, examples, `.env`, or logs into tracked files.
- Treat sibling `.env.testing` and `.env.production` files as owner-managed sensitive configuration. Do not read, print, diff, parse, synchronize, or expose their contents unless the project owner explicitly authorizes that exact access. Existence and Git-ignore checks are allowed without reading contents.
- Treat local `.env` structural synchronization as spec-owned workspace coordination. After editing any sibling `.env.sample`, run `scripts/sync-env.sh` from this spec area; do not add spec-workflow scripts to implementation repositories.

## Validation Habits

- For spec-only work, inspect the resulting file tree and run text checks for non-English/CJK content where practical.
- If the spec repository is under Git, run `git diff --check` when write access and Git metadata are available.
- Do not run app/server/design/website builds for spec-only edits unless the documentation change depends on fresh implementation validation.
- Validate in proportion to changed behavior and risk. Use `WORKFLOW.md` to decide whether a compact version record or enhanced evidence is required.
