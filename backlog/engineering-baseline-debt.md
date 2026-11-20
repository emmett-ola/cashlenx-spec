# Engineering baseline debt

Status: open, measured on 2026-11-20 with ASIDE's
`tools/check-baseline.py`, one run per implementing repository. These are real
gaps, not declared exemptions: none has a version scheduled to close it, and the
repository does not claim otherwise.

| Repository | Result | Unmet item |
| --- | --- | --- |
| `app/` | 5/7 | `scripts/test.sh` missing, although test sources exist — the gate has no single test entry point |
| `server/` | 4/7 | `scripts/test.sh` missing; two different migrations share the numeric prefix `010` |
| `website/` | 5/7 | `scripts/test.sh` missing; no unit or contract test sources |

What the pass rows already show: `.env.example` is tracked and every
per-environment file is ignored in all three, container definitions exist with
digest-pinned images, and dependency directories are self-closed.

Closing this needs a version that adds a single `scripts/test.sh` entry point per
repository, an ordered unique prefix for the duplicated migration, and website
test sources. The migration collision is the item with real delivery risk: an
ordered, immutable migration identity is what the database preflight relies on.

`app/` and `website/` keep no database, so the migration item does not apply to
them; `facts/README.md` records the archived prototype instead.
