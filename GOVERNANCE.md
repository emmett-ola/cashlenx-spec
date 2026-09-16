# CashLenX Governance

CashLenX is maintained as a multi-repository, pre-production open-source
project. This document explains decision authority, repository ownership, and
the evidence-based workflow used to keep a broad product manageable for an
individual maintainer.

## Maintainer Model

The primary maintainer owns product direction, security and privacy decisions,
release acceptance, credentials, shared-environment actions, and the final
decision to merge or deploy a change. Contributors may propose and implement
changes, but a contribution does not authorize a release, migration, or
deployment.

## Repository Ownership

| Repository | Authority |
| --- | --- |
| [cashlenx-app](https://github.com/emmett-ola/cashlenx-app) | Flutter client behavior, presentation, local state, and API consumption. |
| [cashlenx-server](https://github.com/emmett-ola/cashlenx-server) | Go API/CLI behavior, authentication, finance services, persistence, and OpenAPI. |
| [cashlenx-design](https://github.com/emmett-ola/cashlenx-design) | Visual and interaction reference; it is not a runtime dependency. |
| [cashlenx-website](https://github.com/emmett-ola/cashlenx-website) | Public product and developer-information website. |
| [cashlenx-spec](https://github.com/emmett-ola/cashlenx-spec) | Canonical facts, workflow, decisions, delivery evidence, and deferred scope. |

Implementation repositories remain independently buildable. CashLenX Spec
coordinates facts and delivery evidence but is not imported by application
code, builds, tests, or runtime services.

## Codex-Assisted Maintenance

Codex is used as an ongoing engineering collaborator across the project
lifecycle. It helps the maintainer inspect evidence, refine product and
architecture decisions, implement bounded changes, review code and contracts,
add tests, keep documentation synchronized, rehearse container delivery, and
assemble validation and operational evidence.

AI assistance does not replace maintainer accountability. The maintainer keeps
authority over material product choices, security/privacy boundaries, secrets,
production actions, license changes, and final acceptance. AI-generated or
AI-modified work must remain reviewable, traceable to repository evidence, and
validated in proportion to its risk.

This collaboration makes a broad lifecycle practical for an individual
maintainer:

1. **Design:** reconcile product intent, visual reference, system facts, and
   unresolved questions.
2. **Plan:** define the outcome, ownership boundary, compatibility constraints,
   Human gates, and observable completion evidence.
3. **Implement:** make scoped changes in the owning repository without creating
   runtime dependencies between project areas.
4. **Validate:** run focused tests, contract checks, database scenarios,
   security checks, and cross-repository acceptance when triggered.
5. **Deliver:** verify versions, artifacts, migrations, container boundaries,
   rollback readiness, and explicit delivery authority.
6. **Observe and learn:** correlate health, logs, metrics, request identifiers,
   and user feedback, then return durable findings to system facts, decisions,
   or deferred work.

## Evidence And Human Gates

The detailed delivery process is defined in [WORKFLOW.md](WORKFLOW.md). Its
core rules are:

- evidence before opinion;
- one authoritative owner per fact;
- the smallest complete and reversible change;
- validation proportional to behavior and risk;
- explicit Human decisions for breaking, destructive, security-sensitive,
  production, release, and major-direction actions;
- separate records for implementation, release, deployment, migration, and
  production acceptance.

Current verified behavior belongs in `system/`, durable decisions in
`decisions/`, deferred scope in `backlog/`, and retained closeout evidence in
`versions/`. Active work may use the maintainer's collaboration systems, while
public issues and pull requests remain the entry point for community
contributions.

## Community Contributions

Contributors should follow [CONTRIBUTING.md](CONTRIBUTING.md) and report
vulnerabilities through [SECURITY.md](SECURITY.md). The maintainer reviews each
change for repository ownership, contract impact, validation evidence, and any
triggered Human gate before merge or delivery.
