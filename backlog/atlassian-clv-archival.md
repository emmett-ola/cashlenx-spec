# Retire CLV and reconcile the Jira version surfaces

Status: open — the decision is made, the Jira action is outstanding.

## Decision (owner, 2026-11-20)

The Jira Product Discovery project `CLV` (`CashLenX Versions`) is archived and no
longer maintained. Version identity lives in `../versions/README.md` and the
`version/X.Y.Z` tag; the repository stops keeping a second version line. This
supersedes decision `0005` (CLV authoritative version catalog) and the CLV parts
of `0002`/`0004`, which are folded into `../facts/collaboration.md`
§Version Model.

## What is left to do in Atlassian

1. Archive the CLV Ideas `CLV-7` … `CLV-21` (native `Idea archived`), or archive
   the project where the surface allows it. Their content stays readable.
2. Correct the Confluence delivery page where it still calls CLV the version
   authority; point it at the ladder and keep the page short.
3. Stop applying new `version-vX-Y-Z` / `release-line-vX-Y` labels to CLX items.
   Existing labels stay as history; they are query aids only.

## Why it is not done here

This session has no Atlassian integration, and a bulk archive of a project is an
owner-held external mutation. The repository side is corrected and verified; the
Atlassian side is one bounded action performed by the owner or a session holding
the Rovo surface.

## Bound

Do not move or copy CLX work into CLV, do not archive CLX items because a version
closed, and do not treat an archived Idea as proof of tag, publication,
deployment, migration or production acceptance.
