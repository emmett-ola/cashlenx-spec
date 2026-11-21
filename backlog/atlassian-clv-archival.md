# Retire CLV and reconcile the Jira version surfaces

Status: closed 2026-11-20.

## Decision (owner, 2026-11-20)

The Jira Product Discovery project `CLV` (`CashLenX Versions`) is archived and no
longer maintained. Version identity lives in `../versions/README.md` and the
`version/X.Y.Z` tag; the repository stops keeping a second version line. This
supersedes decision `0005` (CLV authoritative version catalog) and the CLV parts
of `0002`/`0004`, which are folded into `../facts/collaboration.md`
§Version Model.

## What was done

- All 21 CLV Ideas were archived through `twg` by setting the native
  `customfield_10106` (`想法已归档` / Idea archived) to `Yes`: `CLV-7` first,
  read back, then the rest. The final read-back reported 21/21 archived; nothing
  was deleted, moved or re-summarised.
- New `version-vX-Y-Z` / `release-line-vX-Y` labels are not applied any more.
  Existing labels stay as history.
- The Confluence page that still described CLV as the version authority was
  replaced rather than repaired: `Delivery and Jira Workflow` (page 52166678) is
  in the space trash, and page **66027523** — same title, same space — carries
  the corrected content.

## Why the page was replaced

Three `twg` writes on the old page — one full-body replacement and two targeted
`--edits` runs, each validated with `--dry-run` — returned `internal_error` and
left it unchanged at `version 10`; `twg` then advises not to replay the request.
The old body also carried corrupted paragraphs from an earlier edit (duplicated
words in at least three nodes). The owner authorized deleting it and creating a
fresh page, which is what happened.

## Bound

Do not recreate CLV content, do not move or copy CLX work into it, and do not
treat a historical CLV Idea as proof of tag, publication, deployment, migration
or production acceptance. The trashed page 52166678 stays recoverable from the
space trash if its history is ever needed.
