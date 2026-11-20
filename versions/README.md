# Version ladder

One row per product version. The row and the `version/X.Y.Z` tag on a `develop`
commit are the identity of the version; `X.Y.Z.md` in this directory is its
record. Current behaviour is in `../facts/`; deferred work is in `../backlog/`.

Columns:

- **version** — the product version.
- **commit** — the version's identity commit, written in full when it is known.
  A pre-standard version whose commit could not be resolved from its record
  carries `—`; it stays untagged rather than guessed.
- **deployment** — the served identity where the version deployed, or `none`.
  Deployment is never implied by the row's status.
- **status** — `closed` / `accepted` for a version with an accepted record;
  `pre-standard` for a version whose record was converted from the older
  `versions/`, release-note or Jira-only layout; `specification only` for a
  version that changed no artifact bytes, `specification + test entry points`
  when it also added a repository test entry point without changing behaviour.
- **scope** — what the version delivered.
- **record** — the record file, or the Jira Idea that holds it for a version with
  no repository record.

## Ladder

| Version | Commit | Deployment | Status | Scope | Record |
| --- | --- | --- | --- | --- | --- |
| 0.2.0 | — | none | closed (pre-standard) | Online-source design authority, Flutter tokens, shared control geometry, cash-flow semantics | [0.2.0](0.2.0.md) |
| 0.3.0 | — | none | closed (pre-standard) | Splash, onboarding, authentication and currency/setup visual parity | [0.3.0](0.3.0.md) |
| 0.4.0 | — | none | closed (pre-standard) | Date-range filtering, filter chips, result summary, empty-state recovery | [0.4.0](0.4.0.md) |
| 0.5.0 | — | none | closed (pre-standard) | Finance surfaces split by feature, reporting APIs, user-scoped budgets | [0.5.0](0.5.0.md) |
| 0.6.0 | — | none | closed (pre-standard) | Profile and settings truth without unsupported persistence | [0.6.0](0.6.0.md) |
| 0.7.0 | — | none | closed (pre-standard) | Multi-viewport visual acceptance, regression closeout, fact synchronization | [0.7.0](0.7.0.md) |
| 0.8.0 | — | none | closed (pre-standard) | Uniform image build, health-gated start, persistence-safe stop | [0.8.0](0.8.0.md) |
| 0.8.1 | — | none | closed (pre-standard) | Tracked environment-example convention, lifecycle selection | [0.8.1](0.8.1.md) |
| 0.8.2 | — | none | closed (pre-standard) | In-template guidance for environment formats, units and meaning | [0.8.2](0.8.2.md) |
| 0.8.3 | — | none | closed (pre-standard) | Explicit MongoDB/MySQL lifecycle scripts, single-definition values | [0.8.3](0.8.3.md) |
| 0.8.4 | — | none | closed (pre-standard) | Active environment assignments, enable-aware validation, one timezone key | [0.8.4](0.8.4.md) |
| 0.8.5 | — | none | closed (pre-standard) | Shared UTC-or-IANA timezone contract for application and containers | [0.8.5](0.8.5.md) |
| 0.8.6 | — | none | closed (pre-standard) | Configurable named volumes and absolute host bind paths | [0.8.6](0.8.6.md) |
| 0.8.7 | — | none | closed (pre-standard) | Database URIs derived from atomic credentials, ports and names | [0.8.7](0.8.7.md) |
| 0.8.8 | — | none | closed (pre-standard) | APK-independent Server image with embedded timezone data | [0.8.8](0.8.8.md) |
| 0.8.9 | — | none | closed (pre-standard) | One shared external network, Docker definitions under each project | [0.8.9](0.8.9.md) |
| 1.0.0 | — | not recorded | pre-standard (release-candidate note) | First stable release: `/api/v1` with `/api/v0` alias, email-or-username login, reproducible candidate artifacts | [1.0.0](1.0.0.md) |
| 1.0.1 | — | not recorded | pre-standard (Jira only) | Compatible follow-up maintenance | CLV-8 (archived) |
| 1.0.2 | — | not recorded | pre-standard (Jira only) | Reproducible environment bootstrap | CLV-9 (archived) |
| 1.0.3 | — | not recorded | pre-standard | Unified brand identity across app, web metadata and website | [1.0.3](1.0.3.md) |
| 1.0.4 | — | not recorded | pre-standard | Category and statistics correctness | [1.0.4](1.0.4.md) |
| 1.0.5 | — | not recorded | pre-standard | Reliable localized entry experience | [1.0.5](1.0.5.md) |
| 1.0.6 | — | not recorded | pre-standard (Jira only) | Reliable transaction activity, responsive profile editing | CLV-13 (archived) |
| 1.0.7 | — | not recorded | pre-standard (Jira only) | Consistent financial context across views and devices | CLV-14 (archived) |
| 1.0.8 | — | not recorded | pre-standard | Transactions as primary navigation, category management under settings | [1.0.8](1.0.8.md) |
| 1.0.9 | — | not recorded | pre-standard (Jira only) | About, dashboard context, slogan and release identity | CLV-16 (archived) |
| 1.0.10 | — | not recorded | pre-standard (Jira only) | Selected-currency presentation and settings-owned preferences | CLV-17 (archived) |
| 1.1.0 | — | Server `b799edc9288342de5b6d701d625aa01a6c41db05` on Testing and Production; App static publication | pre-standard | Polished registration verification, branded HTML verification email | [1.1.0](1.1.0.md) |
| 1.1.1 | — | App Testing promotion and static publication | pre-standard | Accessibility, URL coherence, semantic dark surfaces, Budget precision, responsive entry, reduced motion | [1.1.1](1.1.1.md) |
| 1.1.2 | — | not recorded | pre-standard (Jira only) | Fast and observable API experience; prepared, not selected | CLV-20 (archived) |
| 1.1.3 | — | App `8e6e511a174c439d9f5bed9d3e67e584461781fd` on `main` and published `cashlenx-app-release-main/main`; Server and Website unchanged | pre-standard | Environment-driven App configuration patch, isolated dual-database candidate gate, verified Testing and Main delivery | [1.1.3](1.1.3.md) |
| 1.1.4 | `eaa59c9c925caeec433c236f4418e6d46083f70c` | none | specification + test entry points | Convert the specification repository to the ASIDE shape (`facts/`, one ladder, one record per version) and add the missing `scripts/test.sh` to `app/` and `server/` | [1.1.4](1.1.4.md) |

## Rules

- A version's commit column carries the version's identity — the commit its
  `version/X.Y.Z` tag points at, or the delivery commit when the version carries
  no tag. A record-only commit made afterwards is named in the version record and
  is never substituted here. The row that completes a record belongs to the row
  it updates and needs no separate listing.
- New work never adds a `not a version` row. A change that alters no artifact
  bytes rides the version it serves and is listed in that version's record.
- Rows above `1.1.4` are pre-standard: their records were converted mechanically
  from the earlier `versions/vX.Y.Z-*/` directories, the release notes and the
  Jira version catalog on 2026-11-20, and the conversion record states what moved
  where. Their acceptance, promotion and deployment states are the ones their
  record already stated; nothing was re-verified by the conversion.
- The Jira Product Discovery project `CLV` was archived on 2026-11-20. A row that
  points at a CLV Idea names a historical record, not an active surface; from
  `1.1.4` on, a version exists only as a row here plus its record.
- No `version/X.Y.Z` tag exists yet in any repository. Creating one is a separate
  controlled action; from `1.1.4` onward a tag is placed on the commit the row
  names, on `develop`.
- Version numbers express delivery scope. They do not imply acceptance,
  deployment, publication or promotion.
- `VERSION` in this directory holds the newest version in this table.
