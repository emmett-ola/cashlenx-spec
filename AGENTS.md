# CashLenX Spec — operating guide

This repository is the specification and version-record repository for CashLenX,
the multi-repository project in the parent workspace. It holds current facts, the
version ladder and one record per version, and the deferred backlog. It holds no
runtime code and deploys nothing.

This project follows the ASIDE standard; run
`python3 /Users/emmett/workspace/macacloud/maca-project-aside/tools/check-aside.py .`
from this directory to compare the stamp below with the framework checkout.

aside: df7ad7a3485c232a229aab88d12715bdb26c3787

## Reading order

1. `README.md` — what CashLenX is and how the workspace is laid out.
2. `facts/README.md` — the fact index and the rules for this directory.
3. The fact module the task touches, starting with `facts/delivery.md` when the
   task concerns work selection, promotion, release or evidence.
4. `versions/README.md` — the ladder; then the record of the version in scope.
5. `backlog/README.md` — deferred work and open questions.

Read delivery history only when the task changes or investigates that scope.

## Language

- Every artifact in `cashlenx-spec` is written in English.
- Conversation with the owner may be in Chinese; do not translate engineering
  files unless a translation is the requested deliverable.
- Preserve exact route names, field names, enum values, command names, package
  names and paths.

## Where a fact lives

| Area | Owns |
| --- | --- |
| `facts/` | Current truth: product, domain, API, operations, delivery, testing, principles, quality, per-area facts. Rewritten in place. |
| `versions/` | The ladder and one record per version: scope, decisions, full commit SHAs, verification, acceptance, deployment identity. |
| `backlog/` | Deferred work, unselected candidates, open questions — with the reason. |
| Jira `CLX` | Executable work, priorities, dependencies, acceptance criteria, owner decisions, delivery state. |
| Jira `CLV` | Archived on 2026-11-20. Historical version records only; not a maintained surface, and new versions are not created there. |
| Confluence | Maintained English guidance for users and developers, linked to repository facts. |
| Implementation repositories | Exact runtime truth: routes, fields, artifacts, behaviour. |

One fact, one place. A second document that restates a rule is a defect. Proposals
never live in `facts/`: what a version will do belongs in its record, what is
deferred belongs in `backlog/`.

## Repository boundaries

- Active areas: `spec/`, `app/`, `server/`, `website/` — each its own Git
  repository. `design/` is archived historical evidence, declared
  `archived-repo: design` in `facts/README.md`.
- The parent workspace is not a Git repository. Never assume otherwise.
- Local directories are `app/`, `server/`, `website/`, `spec/`; remotes and
  artifacts are `cashlenx-app`, `cashlenx-server`, `cashlenx-website`,
  `cashlenx-spec`. Automation maps the two explicitly and never derives one from
  the other.
- Implementation repositories must not import, read, link to, build from or test
  against this repository, and must not carry its workflow rules, paths or agent
  attribution.
- Before touching a sibling repository, read its nearest `AGENTS.md`, check its
  branch and clean state, and keep edits inside the repository the task named.
- Paths in documents are relative to `cashlenx-spec` or the logical workspace
  root, never host-specific absolute paths.

## Branches and versions

- `app/`, `server/`, `website/`: work on `develop`; `testing` is the verified
  fast-forward target for a complete version; `main` moves only after explicit
  owner confirmation of that production release. The legacy branch name `test`
  is not used.
- `spec/`: a single `main` branch. Specification commits never represent a
  release or a deployment.
- Promotion is fast-forward only, `develop` → `testing` → `main`, and never
  while an earlier version is unaccepted. A `dev/*` branch merges back into
  `develop` and is then deleted, locally and on the remote.
- Every change belongs to a version. The ladder row plus the `version/X.Y.Z` tag
  on a `develop` commit is that version's identity; `versions/X.Y.Z.md` is its
  record. A change that alters no artifact bytes rides the version it serves and
  is listed in that version's record.
- Records and ladder rows carry full 40-character SHAs; a short form is display
  only. A version whose commit cannot be resolved stays untagged, and the row says
  so.
- Acceptance is recorded against an exact commit by someone who did not implement
  it. Accepted is not deployed.
- Delivery is per area: the App and Website publish through GitHub CI and their
  platform integration, while the Server is started by the owner running the
  repository's own `scripts/build.sh` and `scripts/start.sh` on the Linux host.
  Maintain the CI workflows and shell scripts; never claim a publication or a
  deployment from a `main` push. `spec/` ships no deployment automation.

## Working on a task

- Preflight: fetch remote refs, confirm a clean worktree on the expected branch,
  equal to its upstream. Fast-forward a branch that is only behind; stop on
  dirty, divergent, unexpected-branch or missing-upstream state instead of
  resetting, stashing or overwriting unrelated work.
- Investigate before acting: inspect the implementation and active contracts
  first, then correct the fact. Separate verified facts, inferences and open
  questions.
- Selected work only. A prepared Ready item authorizes nothing; the owner selects
  the item or batch. Jira state, a commit, a green workflow or a merged branch
  proves no promotion, tag, publication, deployment, migration or acceptance.
- Check the spec against reality rather than trusting it: an inherited sentence
  that reads like a plan is often a stale fact.
- Never record credentials, tokens, raw conversations, owner-managed environment
  contents, logs or databases in tracked files. `.env.testing` and
  `.env.production` are owner-managed: do not read, print, diff or synchronize
  them without explicit authorization for that exact access.
- After editing a sibling `.env.example`, run `scripts/sync-env.sh` from this
  directory. Do not add spec-workflow scripts to implementation repositories.

## Editing and committing

- Keep edits scoped to `cashlenx-spec` unless the owner asks for sibling changes.
- Prefer small, stable documents over large mixed notes; delete what a version
  made obsolete instead of narrating it.
- Commit the completed change set by default unless the owner opts out. Spec
  commits use `main`; implementation commits use `develop`. Stage only intended
  files, keep LF line endings through `.gitattributes`, and end files with one
  newline.
- Report honestly: what changed, what is proven and how, what is not, and what
  needs a decision.

## Verification

- Spec-only work: check structure, links and moved paths, unintended non-English
  content, and `git diff --check`.
- Framework conformance:
  `python3 <aside>/tools/check-project.py <workspace-root>` for the layout and
  `python3 <aside>/tools/check-baseline.py <code-repository>` for each
  implementing repository.
- Use Docker Compose for local and production-like container execution, with
  nerdctl 2.2+ as a compatibility target verified by fake frontend contract
  tests; a real local nerdctl runtime is never required.
- Do not run app, server or website builds for a spec-only change unless the
  documentation claim depends on fresh evidence.
- Validate in proportion to the behaviour and risk the change touches.

## Security reports

Report a vulnerability through the repository's private reporting or security
advisory feature, never a public issue containing exploit details, credentials,
personal data, private URLs or production logs. See `facts/collaboration.md` for
the reporting shape.
