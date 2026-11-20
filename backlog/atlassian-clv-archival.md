# Retire CLV and reconcile the Jira version surfaces

Status: Jira done 2026-11-20; Confluence blocked by a tool failure.

## Decision (owner, 2026-11-20)

The Jira Product Discovery project `CLV` (`CashLenX Versions`) is archived and no
longer maintained. Version identity lives in `../versions/README.md` and the
`version/X.Y.Z` tag; the repository stops keeping a second version line. This
supersedes decision `0005` (CLV authoritative version catalog) and the CLV parts
of `0002`/`0004`, which are folded into `../facts/collaboration.md`
§Version Model.

## Done

- All 21 CLV Ideas were archived through `twg` by setting the native
  `customfield_10106` (`想法已归档` / Idea archived) to `Yes`. `CLV-7` was set
  first and read back before the rest ran; the full run finished with 21
  archived and no failures. Nothing was deleted or re-summarised.
- New `version-vX-Y-Z` / `release-line-vX-Y` labels are not applied any more.
  Existing labels stay as history.

## Blocked: the Confluence page

`Delivery and Jira Workflow` (page 52166678) still says CLV "owns the
authoritative exact-version catalog" and keeps a `CLV version catalog` section.
Three update attempts through `twg` — one full-body replacement and two targeted
`--edits` runs, all validated by `--dry-run` — returned `internal_error` while
leaving the page unchanged (`version 10`, 2026-10-13). The page also contains
corrupted paragraphs from an earlier edit (duplicated words in at least three
nodes), which may be what the collaborative update chokes on.

The replacement text is prepared and only needs a working surface:

| Element | New text |
| --- | --- |
| Ownership bullet | CLV "was archived on 2026-11-20 and is no longer maintained; its Ideas stay readable as historical version records. The version ladder in `cashlenx-spec/versions/README.md` owns version identity." |
| Section heading | `CLV version catalog` → `Version identity` |
| Identity paragraph | the ladder plus the `version/X.Y.Z` tag on a develop commit; `versions/X.Y.Z.md` carries scope, decisions, full SHAs and evidence |
| Authority paragraph | the repository ladder is authoritative; CLX labels are query aids that must match it |
| Archive section | `Completed-version archive` → `Closing a version`: record outcome, commits and evidence in `versions/X.Y.Z.md`; no CLV archive step |
| Ownership paths | `cashlenx-spec/system/` → `cashlenx-spec/facts/`; the `decisions/` bullet → `cashlenx-spec/versions/` |
| Tooling line | "the authorized Atlassian CLI (`twg`)" instead of Rovo |

## Why it is not done here

This session has no Atlassian integration, and a bulk archive of a project is an
owner-held external mutation. The repository side is corrected and verified; the
Atlassian side is one bounded action performed by the owner or a session holding
the Rovo surface.

## Bound

Do not move or copy CLX work into CLV, do not archive CLX items because a version
closed, and do not treat an archived Idea as proof of tag, publication,
deployment, migration or production acceptance.
