# Design Reference

## Snapshot

The live Figma Make project is the primary visual and interaction reference.
`../cashlenx-design` is its exported React/Vite cache and is not the runtime
product implementation.

Live Figma Make project:

```text
https://www.figma.com/make/Zk98sZ5w9YVOZlTR0AARV8/CashLenX-Design
```

## Usage Rule

Read the relevant live Figma Make source before changing UI geometry,
behavior, or visual style. The local export may be used for faster inspection
only after the relevant custom source files are verified against the live Make
resources. Match component sizes, border radii, spacing, and interactions as
closely as practical within Flutter constraints.

Do not promote design-reference-only features into current product facts unless the app/server implementation confirms them.

When the design prototype conflicts with product correctness, API contracts, or
truthful state, retain the implemented product rule and record the visual
deviation. Examples include mock account statistics, unpersisted profile fields,
and reversed income/expense semantic colors.

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
