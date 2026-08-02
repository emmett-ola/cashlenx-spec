# Website

## Snapshot

`../cashlenx-website` is a Vite/React/TypeScript product-introduction website for CashLenX product, landscape, roadmap, API, and developer workflow content.

Current stack:

- Vite.
- React.
- TypeScript.
- `lucide-react` icons.

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
