# 0005 CLV Authoritative Version Catalog

## Status

Accepted on 2026-09-17.

## Context

The authorized Atlassian Rovo integration can operate Jira issues, Product Discovery Ideas, delivery links, labels, comments, transitions, Confluence, and native Idea archival. It does not expose Jira project release administration, saved-filter creation, or board creation. The earlier workflow selected CLX `Fix Version/s` as the exact version authority and proposed a separate archive board per completed release line, leaving routine version creation and archive-board administration outside the available Rovo workflow.

The product owner created Jira Product Discovery project `CLV` (`CashLenX Versions`) and authorized its complete conversion from sample data into the CashLenX version roadmap and archive.

## Decision

- CLV is the authoritative exact product-version catalog and roadmap.
- One CLV Idea represents one exact semantic version and is named `vX.Y.Z — outcome`.
- The CLV Idea records the version outcome, scope, lifecycle, evidence, and separate implementation, candidate, tag, publication, promotion, deployment, migration, and production-acceptance states.
- CLX remains authoritative for raw requirement intake, executable work, priority, dependencies, acceptance criteria, Human decisions, validation, and delivery state.
- Selected CLX work connects to its CLV version Idea through Product Discovery delivery links and carries matching `version-vX-Y-Z` and `release-line-vX-Y` labels for queries.
- The CLV Idea is authoritative when a label or other derived view disagrees. Correct the derived metadata rather than creating a second version authority.
- Planned and active versions remain visible on the CLV Roadmap. A version Idea is archived through Product Discovery's native `Idea archived` field only after its close gate passes, final evidence and all separate delivery states are recorded, durable facts are synchronized, and the next delivery boundary has opened.
- Completed CLX work remains in CLX with its full history, links, and labels. Do not move or copy it into CLV and do not create a separate archive board per version.
- Archiving a CLV Idea does not imply that a tag, publication, promotion, deployment, migration, or production acceptance occurred.

## Migration

- Native-archive the six Jira Product Discovery sample Ideas that existed when CLV was created.
- Create CLV-7 as the authoritative `v1.0.0` record and keep it visible because publication and deployment have not occurred.
- Create CLV-8 as the authoritative `v1.0.1` follow-up record.
- Replace CLX temporary `planned-version-vX-Y-Z` labels with permanent query labels `version-vX-Y-Z`.
- Connect CLV-7 to CLX-12, CLX-29, and CLX-30 and connect CLV-8 to CLX-21 and CLX-38 through Product Discovery delivery links.

## Consequences

- Version planning and completed-version archival are fully operable through Rovo without recurring Jira board administration.
- The CLV Roadmap stays compact because completed versions use the native archive while remaining restorable.
- Exact version identity no longer depends on CLX `Fix Version/s`.
- Release-line and exact-version labels remain controlled query metadata and must match CLV.
- The version close gate must verify CLV content, CLX delivery links, labels, and separately evidenced delivery states before archival.

## References

- `../AGENTS.md`
- `../WORKFLOW.md`
- `../system/collaboration.md`
- `../versions/README.md`
- `0002-jira-controlled-delivery-with-project-local-advancement.md`
- `0004-agent-led-jira-intake-and-version-archives.md`
