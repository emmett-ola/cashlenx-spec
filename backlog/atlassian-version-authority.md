# Reconcile the Jira version surfaces with the ladder

Status: open, deferred by `1.1.4`.

## What changed

From `1.1.4` the version ladder (`../versions/README.md`) and the
`version/X.Y.Z` tag are the identity of a product version. The CLV Idea keeps
the version's outcome, roadmap position, lifecycle and links for people and
queries, and must match the ladder. Before `1.1.4`, the CLV Idea was declared the
authoritative catalog (decision `0005`, now folded into
`../facts/collaboration.md` §Version Model).

## What is outstanding

1. `1.1.4` has no CLV Idea. It is `specification only`, so creating one would be
   noise; record the convention for specification-only ladder rows instead.
2. The CLV Ideas for `1.0.0` … `1.1.3` still describe themselves as the version
   authority. Their identity fields must be checked against the ladder rows, and
   disagreeing metadata repaired in the ladder's favour.
3. Confluence states the same authority in its delivery guidance. Correct it to
   point at the ladder, keeping the page short.

## Why it is deferred

The repair direction is implementation → repository → Atlassian. The repository
side is corrected and verified; the Atlassian side is a separate write that was
not authorized as part of a structure-only change. Leaving the two surfaces
temporarily inconsistent is recorded here rather than hidden.

## Bound

Editing CLX work items, archiving CLV Ideas, or bulk-clearing either project is
outside this item. Archival still requires the version close gate.
