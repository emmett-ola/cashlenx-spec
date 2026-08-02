# Decisions

This directory is for ADR-style decisions that should remain discoverable after a version closes.

## When To Add A Decision

Add a decision when a choice is durable and would otherwise be rediscovered or debated repeatedly, such as:

- API versioning policy.
- Authentication/session semantics.
- Budget workflow ownership.
- Import/export format guarantees.
- Database support commitments.
- Major documentation workflow changes.

Do not add a decision for routine implementation details or temporary delivery notes. Keep those in the relevant version directory.

## Format

Use numbered files:

```text
0001-short-title.md
```

Recommended sections:

- Status.
- Context.
- Decision.
- Consequences.
- References.

## Current Decisions

- `0001-stable-release-api-auth-and-capability-policy.md`
- `0002-spec-controlled-versioning-with-project-local-advancement.md`
