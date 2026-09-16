# Website

## Snapshot

`../cashlenx-website` is a Vite/React/TypeScript product-introduction website for CashLenX product, landscape, roadmap, API, and developer workflow content.

Current stack:

- Vite.
- React.
- TypeScript.
- `lucide-react` icons.
- Runtime artifact version `1.0.0-rc.1` on the coordinated, untagged v1
  release-candidate line.

## Current Content Model

The first scaffold keeps content in `src/App.tsx` so the documentation structure is easy to revise while the source of truth is still settling.

Future MDX, generated OpenAPI summaries, and spec-to-website content pipelines remain deferred in `../../backlog/`; they are not current website behavior.

## Standard Commands

```bash
npm install
npm run dev
npm run build
```

Use this site as a derived documentation surface. Current facts should be maintained in `cashlenx-spec/system/` first.

The tracked `.env.example` keeps every website container assignment active;
operators change values directly rather than uncommenting settings.
Docker build and Compose definitions live under `docker/`. Website project and
container names are explicit, and the service joins the absolute
`DOCKER_NETWORK_NAME`; its start script creates that network when needed and its
stop script removes it only when no containers remain attached.

GitHub Actions runs dependency audit and build validation on delivery branches.
A manual secret-free job packages the verified container image without tagging,
publishing, promoting, or deploying it.
