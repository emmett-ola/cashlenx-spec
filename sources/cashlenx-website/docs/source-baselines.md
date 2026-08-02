# CashLenX Source Baselines

Recorded on 2026-06-14 for future CashLenX website updates.

Use these commits as the starting point when refreshing website content from sibling projects. On the next update, compare each source project against the recorded commit instead of re-discovering the whole project from scratch.

## Git Repositories

| Project | Branch | Commit | Status | Last commit |
| --- | --- | --- | --- | --- |
| `cashlenx-website` | `master` | `6966358d063fbaba1349788a426a43878f56a0a0` | Clean at record time | `6966358 feat: scaffold cashlenx docs website` |
| `cashlenx-server` | `dev/v0.8.0` | `fc717f151d81f52fe3983123945ece65a917e81f` | Clean at record time | `fc717f1 docs: align roadmap with v0.8.0` |
| `cashlenx-app` | `develop` | `f729556d3347b75955d38f6c37efbd5a7e200229` | Clean at record time | `f729556 fix: refresh session on 401` |

## Non-Git Sibling Folders

These sibling folders existed at record time but were not Git repositories:

- `cashlenx-design`
- `cashlenx-docs`

## Refresh Workflow

1. Check each sibling repository's current commit and status.
2. Diff source docs/code from the recorded commit to the new commit.
3. Update this website from only the changed product, roadmap, API, CLI, and client-facing documentation surfaces.
4. Record the new baseline commits in this file after the website update is committed.
