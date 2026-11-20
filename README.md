# CashLenX Spec

The specification and version-record repository for CashLenX, a personal-finance
product for recording income and expenses, organizing cash flows by category,
viewing summaries and reports, and managing account preferences.

CashLenX is developed as independently buildable repositories with explicit
ownership boundaries:

| Repository | Responsibility |
| --- | --- |
| [cashlenx-app](https://github.com/emmett-ola/cashlenx-app) | Flutter client and user experience. Owns current UI behaviour and presentation. |
| [cashlenx-server](https://github.com/emmett-ola/cashlenx-server) | Go REST API, Cobra CLI, authentication, finance services, MongoDB/MySQL persistence, OpenAPI. |
| [cashlenx-website](https://github.com/emmett-ola/cashlenx-website) | Public product and developer-information website. |
| [cashlenx-design](https://github.com/emmett-ola/cashlenx-design) | Archived early React/Vite prototype, retained as historical evidence. |
| cashlenx-spec | This repository: current facts, the version ladder and records, deferred work. |

Cross-repository contracts are coordinated through OpenAPI and the version
records here. Runtime repositories never depend on this repository at build time
or run time, and the parent workspace is not a Git repository.

## Where to start

| If you want | Read |
| --- | --- |
| The operating rules for agents and contributors | [`AGENTS.md`](AGENTS.md) |
| What is true now | [`facts/README.md`](facts/README.md) and the module you need |
| How work is selected, promoted and released | [`facts/delivery.md`](facts/delivery.md) |
| What a version delivered, and its evidence | [`versions/README.md`](versions/README.md) |
| What is deferred, and why | [`backlog/README.md`](backlog/README.md) |
| How to build, run and test each area | [`facts/operations.md`](facts/operations.md), [`facts/testing.md`](facts/testing.md), and each area's `README.md` under `facts/` |

## Layout

```text
AGENTS.md             operating guide; the ASIDE revision stamp lives here
README.md             this file
facts/                current truth, one module per area, rewritten in place
versions/README.md    the version ladder
versions/X.Y.Z.md     the delivery record for that version
versions/evidence/    machine-readable release evidence, per version
backlog/              deferred work and open questions, with the reason
scripts/  docker/  test/   specification-side release and validation tooling
```

## Working language

Every artifact in this repository is English. Conversation with the owner may be
in Chinese; translated content is only produced when it is the requested
deliverable.

## Licence

MIT. Commercial use, modification and redistribution are permitted when the
copyright and licence notices are retained.
