# Docker Build Context Environment Hardening Backlog

## Purpose

Git ignore rules do not control Docker build contexts. The runtime repositories
use broad source copies during image builds, while their Docker ignore rules do
not consistently exclude `.env.testing`, `.env.production`, and other ignored
environment files.

## Deferred Outcome

- Exclude ignored environment variants from every Docker build context.
- Preserve the Flutter web build's ability to consume its selected environment
  file without exposing unrelated environment files to the builder.
- Validate Server and Website images without sending runtime secret files to the
  Docker daemon.
- Select BuildKit secrets or another explicit App environment injection design
  before implementation.

This work is deliberately excluded from `v0.8.1`; that version changes Git
tracking, template structure, and repository-local environment selection only.
