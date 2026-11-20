# Engineering baseline

Status: closed on 2026-11-20 by version `1.1.4` (app, server) and `1.1.5`
(website). Measured with ASIDE's `tools/check-baseline.py`, one run per
implementing repository.

| Repository | Result | Closing change |
| --- | --- | --- |
| `app/` | 7/7 | `scripts/test.sh` → `flutter test`, 164 tests |
| `server/` | 6/7 | `scripts/test.sh` → `go test ./...`; the remaining item is the declared per-engine migration divergence in `../facts/operations.md` |
| `website/` | 7/7 | `scripts/test.sh` → `tsc -b` + `bun test`, five render tests |

The Server row is not debt. `migrations: prefix shared by different migrations:
010` comes from the checker reading a single sequence, while the Server keeps
MongoDB `*.js` and MySQL `*.sql` sequences with separate ledgers. Renaming an
applied migration would change checksum identity and break existing
installations, so the shared number is kept and declared.

Keep this file while it explains a checker result a reader would otherwise
re-read as a regression. Once the checker learns per-engine sequences, it is
deleted rather than maintained.
