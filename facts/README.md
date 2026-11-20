# Current facts

Each file here is the current truth for one module of CashLenX. A fact changes by
editing its document in place; Git keeps what it used to say. Every other mention
of these facts is a reference, never a copy.

| File | Owns |
| --- | --- |
| `product-and-flows.md` | Product scope, users, current flows, verified implementation limits. |
| `domain-model.md` | Canonical domain concepts and relationships. |
| `api-contract.md` | API versioning, stable-release API policy, response wrapper, auth model, route surface. |
| `operations.md` | Local runtime, databases, container boundaries, deployment mechanics, configuration synchronization, Bash automation contract, operational endpoints. |
| `deployment-profiles.md` | Supported single-node MongoDB and MySQL profiles, isolation, persistence, backup and recovery, rollback, capacity, unsupported topology. |
| `testing.md` | Validation commands, evidence boundaries, app/server/integration testing strategy. |
| `delivery.md` | Jira surfaces and states, owner-selected execution, promotion sequence, release-candidate gate, evidence states, Human gates. |
| `collaboration.md` | Surfaces and their one owner each, workspace identities, language, Jira item contract, synchronization. |
| `principles.md` | Reusable engineering and product principles that bind new work. |
| `quality-attributes.md` | Triggered quality scenarios and validation expectations. |
| `app/README.md` | Flutter client architecture, behavior, generated-code boundary, testing entry point. |
| `app/code-architecture.md` | App code structure and dependency direction (English). |
| `app/code-architecture.zh-cn.md` | The same structure explained in Chinese, for readers who prefer it. |
| `app/implemented-features.md` | Implemented product surfaces and their exact limits. |
| `server/README.md` | Go server architecture, CLI/API entry points, persistence, security boundaries, testing entry point. |
| `design/README.md` | Current UI authority and the archived prototype boundary. |
| `website/README.md` | Website documentation scaffold status. |

## Project areas

| Area | Local directory | Remote repository | State |
| --- | --- | --- | --- |
| App | `app/` | `cashlenx-app` | Active — owns current UI behavior and presentation. |
| Server | `server/` | `cashlenx-server` | Active — Go API, CLI, persistence, OpenAPI. |
| Website | `website/` | `cashlenx-website` | Active — public product and developer information. |
| Spec | `spec/` | `cashlenx-spec` | Active — this repository; facts, versions, backlog. |

archived-repo: design

`cashlenx-design` is the archived early React/Vite prototype. It is read-only
historical evidence, it is not maintained in parallel with the app, and it
imposes no parity requirement. It accepts no ongoing contributions and no
current fact cites it as its sole authority. See `design/README.md`.

## Source priorities

1. Implementation code and active contracts.
2. Accepted product and design decisions, as recorded in these facts or in a
   version record.
3. The archived prototype under `../design/`, understood as historical evidence.

Do not promote archived prototype behavior into current facts unless the app or
server implements it or the owner accepted it as a current requirement.

## Rules

- Implementation and active contracts are the runtime truth. When this spec
  disagrees with the code, read the code, then correct the fact here.
- One fact, one place. A second document holding the same rule is a defect, not
  a convenience.
- Separate fact, proposal and open question. Proposals live in `../versions/`
  (what a version will do) or `../backlog/` (deferred); they do not leak into a
  facts file.
- A fact written as a plan is believed by the next session. Write the present
  tense; keep targets in `../backlog/`.

- Sibling repositories are the authority for their own behaviour; this spec holds
  no imported copies of them. When a sibling `AGENTS.md` or README matters, read
  it in that repository.
- Real local state stays untracked. No credentials, tokens, raw conversations,
  owner-managed environment contents, logs or databases are recorded here.
