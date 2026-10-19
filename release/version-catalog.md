# Product Version Catalog

This index maps every exact stable product version currently registered in Jira
to its authoritative CLV Idea and any retained local release note. Jira owns
active scope and state; an entry here does not mean a version was completed,
promoted, tagged, deployed, or accepted. Historical pre-stable delivery records
remain indexed in [versions](../versions/README.md).

Catalog identity was checked against native Jira fields on 2026-10-19. All 15
registered versions from `1.0.0` through `1.1.3` have one CLV record. A local
release note is optional unless required by a selected candidate. `Jira only`
means no dedicated local note exists; it does not establish missing delivery
evidence, which must be assessed in the linked record.

| Product version | Authoritative record and outcome | Local release note |
| --- | --- | --- |
| `1.0.0` | [CLV-7](https://macacloud.atlassian.net/browse/CLV-7): First stable release | [Historical RC note](notes/1.0.0-rc.1.md) |
| `1.0.1` | [CLV-8](https://macacloud.atlassian.net/browse/CLV-8): Compatible follow-up maintenance | Jira only |
| `1.0.2` | [CLV-9](https://macacloud.atlassian.net/browse/CLV-9): Reproducible environment bootstrap | Jira only |
| `1.0.3` | [CLV-10](https://macacloud.atlassian.net/browse/CLV-10): Unified brand identity | [Release note](notes/1.0.3.md) |
| `1.0.4` | [CLV-11](https://macacloud.atlassian.net/browse/CLV-11): Category and statistics correctness | [Release note](notes/1.0.4.md) |
| `1.0.5` | [CLV-12](https://macacloud.atlassian.net/browse/CLV-12): Reliable localized entry experience | [Release note](notes/1.0.5.md) |
| `1.0.6` | [CLV-13](https://macacloud.atlassian.net/browse/CLV-13): Reliable transaction activity and responsive profile editing | Jira only |
| `1.0.7` | [CLV-14](https://macacloud.atlassian.net/browse/CLV-14): Consistent financial context across views and devices | Jira only |
| `1.0.8` | [CLV-15](https://macacloud.atlassian.net/browse/CLV-15): Clear finance navigation | [Release note](notes/1.0.8.md) |
| `1.0.9` | [CLV-16](https://macacloud.atlassian.net/browse/CLV-16): Reliable context and product identity | Jira only; cumulative App scope also appears in [1.1.0](notes/1.1.0.md) |
| `1.0.10` | [CLV-17](https://macacloud.atlassian.net/browse/CLV-17): Trustworthy currency and preference surfaces | Jira only; cumulative App scope also appears in [1.1.0](notes/1.1.0.md) |
| `1.1.0` | [CLV-18](https://macacloud.atlassian.net/browse/CLV-18): Polished verification journey | [Release note](notes/1.1.0.md) |
| `1.1.1` | [CLV-19](https://macacloud.atlassian.net/browse/CLV-19): Accessible and coherent app experience | [Release note](notes/1.1.1.md) |
| `1.1.2` | [CLV-20](https://macacloud.atlassian.net/browse/CLV-20): Fast and observable API experience | Jira only; prepared work is not selected by this reconciliation |
| `1.1.3` | [CLV-21](https://macacloud.atlassian.net/browse/CLV-21): Consistent environment-driven App configuration | [Release note, acceptance and Testing delivery](notes/1.1.3.md) |

## Audit Boundaries

- Product versions coordinate independently versioned components. The current
  source candidates retain App `1.1.3+19`, Server/OpenAPI `1.1.0`, and Website
  `1.0.9`; the catalog does not require all components to share a version.
- The `1.1.3` App implementation and `develop` synchronization are recorded.
  The 2026-10-19 reconciliation additionally preserves a historical Server
  Testing hotfix with MongoDB migration `018`. It must not be represented as
  a database-unchanged cumulative candidate.
- The later `1.1.3` exact-candidate gate passed static checks, image replay and
  full isolated MongoDB/MySQL acceptance. The release note links its checksummed
  manifest and separate Testing delivery evidence. Shared database execution
  and production acceptance are not inferred from that result.
- The `1.1.0` note now includes the later Server deployment evidence recorded
  in CLV-18 on 2026-10-13, while preserving the earlier incomplete-delivery
  observation as dated history.
- CLV-19 records successful Testing delivery of the earlier `1.1.1` candidate.
  Its subsequently added CLX-102 remains `Ready (App)` and is outside this
  request. Neither that inventory nor the prepared `1.1.2` API work is started
  or declared complete here.
- This is a version-identity and relevant-delivery-record audit. It does not
  independently revalidate every historical artifact or deployment, or replace
  the live Jira blocker scan and exact-candidate gate.
