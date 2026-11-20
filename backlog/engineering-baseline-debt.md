# Engineering baseline debt

Status: one open item, measured on 2026-11-20 with ASIDE's
`tools/check-baseline.py`, one run per implementing repository.

| Repository | Result | State |
| --- | --- | --- |
| `app/` | 7/7 | closed in `1.1.4` — `scripts/test.sh` added (`flutter test`, 164 tests passed) |
| `server/` | 6/7 | closed in `1.1.4` — `scripts/test.sh` added (`go test ./...`, every package ok); the remaining item is a declared divergence, below |
| `website/` | 5/7 | open — no `scripts/test.sh` and no unit or contract test sources |

## The server item is a declared divergence, not debt

`migrations: prefix shared by different migrations: 010` comes from the checker
reading one migration sequence. The Server keeps two: MongoDB orders `*.js`
under its own ledger, MySQL orders `*.sql` under its own `schema_migrations`
table. A shared number across engines is not a collision, and renaming an
applied migration would change checksum identity and break existing
installations. Recorded in `../facts/operations.md` §Migration identity.

## What closes the website item

`website/` is a Vite/React/TypeScript site with `bun` as its build tool and no
test sources. Closing the item needs two owner decisions, not an agent guess:

1. Which runner: `bun test` (no new dependency, no DOM by default) or `vitest` +
   `@testing-library/react` (adds dev dependencies to a shipped repository).
2. What the first suite must cover. Recommended minimum: the build-time type
   check, rendering of the documented routes, and one assertion that the page
   does not claim data it does not own.

Until both are answered, a `scripts/test.sh` here would run nothing and the
`tests:` item would stay failed — a script that lies is worse than a missing one.
