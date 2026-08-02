# Design Reference

## Snapshot

`../cashlenx-design` is a Figma-exported React/Vite reference implementation. It is source material for visual direction and interaction patterns, not the runtime product implementation.

Original Figma project:

```text
https://www.figma.com/design/Zk98sZ5w9YVOZlTR0AARV8/CashLenX-Design
```

## Usage Rule

Check the design reference before changing UI geometry, behavior, or visual style. Match component sizes, border radii, spacing, and interactions as closely as practical within Flutter constraints.

Do not promote design-reference-only features into current product facts unless the app/server implementation confirms them.

## Key Visual Tokens

- Primary teal: `#008080`
- Secondary/light teal: `#4DB6AC`
- Accent/coral: `#FF8A65`

The product is mobile-first. The Flutter Windows runner uses an iPad portrait-like local testing size of `768x1024`.

## Useful Reference Areas

- `src/app/components/screens/`
- `src/app/components/atoms/`
- `src/app/components/molecules/`
- `src/app/components/organisms/`
- `src/app/components/shared/`
- `src/app/constants/colors.ts`
- `src/app/constants/sharedStyles.ts`

## Design Documentation Sources

Copied source documents under `../../sources/cashlenx-design/` include attribution, code organization, data architecture, logo, storage design, changelog, and TODO notes.
