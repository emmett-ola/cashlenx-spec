# UI Authority And Archived Prototype

## Current Authority

The Flutter implementation in `cashlenx-app` owns current UI behavior and
presentation. Active product requirements, shared app tokens and components,
acceptance evidence, and accepted decisions define new UI work together.

The UI must represent real product and API state truthfully. When evidence
conflicts, resolve the product rule first and update the app and this spec rather
than copying historical prototype behavior.

## Archived Prototype

`cashlenx-design` and its associated Figma project were used for early product
prototyping. The GitHub repository was archived on 2026-10-12 and is retained as
read-only historical evidence. It is not a current visual authority, a parallel
UI implementation, or a runtime dependency.

Historical Figma project:

```text
https://www.figma.com/make/Zk98sZ5w9YVOZlTR0AARV8/CashLenX-Design
```

## Usage Rule

Do not update the archived repository for new UI work and do not require visual
or behavioral parity with it. Consult it only when historical product intent is
relevant, and label any prototype-derived claim as historical until current app
evidence or an explicit decision confirms it.

Place reusable colors, typography, spacing, radii, icons, and component behavior
in the app's shared theme or token boundary so current screens have one
implementation authority.

Do not promote prototype-only features into current product facts unless the app
or server implementation confirms them or the product owner explicitly accepts
them as a new requirement.

## Key Visual Tokens

- Primary teal: `#008080`
- Secondary/light teal: `#4DB6AC`
- Accent/coral: `#FF8A65`

The product is mobile-first. The Flutter Windows runner uses an iPad portrait-like local testing size of `768x1024`.

The early parity series accepted a 430 px maximum app shell centered on a
`#D1D5DB` host at wider viewports. On `2026-08-21`, the live Make manifest
exposed 130 text sources and 54 images; `App.tsx`, `Profile.tsx`, and
`Settings.tsx` matched the local cache after newline normalization. These facts
describe the archived prototype and do not constrain current app work.

## Historical Reference Areas

- `src/app/components/screens/`
- `src/app/components/atoms/`
- `src/app/components/molecules/`
- `src/app/components/organisms/`
- `src/app/components/shared/`
- `src/app/constants/colors.ts`
- `src/app/constants/sharedStyles.ts`

## Design Documentation Sources

Copied source documents under `../../sources/cashlenx-design/` include attribution, code organization, data architecture, logo, storage design, changelog, and TODO notes.
