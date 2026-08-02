# CashLenX Logo System

## Overview
The CashLenX logo system provides a centralized, easy-to-update logo component with multiple color variants for different backgrounds.

## Usage

### Basic Usage
```tsx
import { Logo } from './components/atoms/Logo';

// Teal variant (default) - for light backgrounds
<Logo size="md" variant="teal" />

// White variant - for dark backgrounds
<Logo size="lg" variant="white" />
```

### Props
- **size**: `'sm' | 'md' | 'lg'`
  - `sm`: 48x48px (w-12 h-12)
  - `md`: 80x80px (w-20 h-20)
  - `lg`: 96x96px (w-24 h-24)
  
- **variant**: `'teal' | 'white'`
  - `teal`: For light backgrounds (Login, Dashboard, etc.)
  - `white`: For dark backgrounds (Splash screens, hero sections, etc.)

- **className**: Optional additional CSS classes

## Current Implementations

### Splash Screens
```tsx
<Logo size="lg" variant="white" />
```
Used in:
- `/components/screens/Splash.tsx`
- `/components/screens/SplashScreen.tsx`

### Login Screen
```tsx
<Logo size="md" variant="teal" />
```
Used in:
- `/components/screens/Login.tsx`

## Logo Files

### Component Files
- `/components/atoms/Logo.tsx` - Main logo component (UPDATE THIS TO CHANGE LOGO)
- `/imports/CashlenxLogoTeal.tsx` - Teal color variant
- `/imports/CashlenxLogoWhite.tsx` - White color variant
- `/imports/CashlenxNoTop1.tsx` - Original imported logo component
- `/imports/svg-sne19g9uhw.ts` - SVG path data

### Favicon & PWA Icons
- `/public/favicon.svg` - Browser favicon
- `/public/icon-192.png.svg` - PWA icon (192x192)
- `/public/icon-512.png.svg` - PWA icon (512x512)
- `/public/apple-touch-icon.png.svg` - Apple touch icon (180x180)
- `/public/manifest.json` - PWA manifest file
- `/public/meta-tags.html` - HTML meta tags reference

## How to Replace the Logo

### Step 1: Update the Logo Components
If you need to replace the logo with a new design:

1. Update `/imports/CashlenxLogoTeal.tsx` with your new teal logo
2. Update `/imports/CashlenxLogoWhite.tsx` with your new white logo
3. (Optional) Update the imports in `/components/atoms/Logo.tsx` if file names change

### Step 2: Update Favicon Files
1. Replace the SVG files in `/public/` with your new logo
2. Ensure the icons maintain the proper colors:
   - `favicon.svg`: Teal logo
   - `icon-192.png.svg`, `icon-512.png.svg`, `apple-touch-icon.png.svg`: White logo on teal background

### Step 3: Test All Screens
Verify the logo appears correctly on:
- ✅ Splash screens (white variant)
- ✅ Login page (teal variant)
- ✅ Browser tab (favicon)
- ✅ PWA home screen (app icons)

## Color Specifications

### Teal Variant
- Primary color: `#79BCB8`
- Accent (inner circle): `white`

### White Variant
- Primary color: `white`
- Accent (inner circle): `rgba(0, 128, 128, 0.3)` (semi-transparent teal)

### Brand Colors
- Theme color: `#008080` (Teal)
- Accent color: `#FF8A65` (Coral)
- Gradient: `135deg, #008080 0%, #4DB6AC 100%`

## Best Practices

1. **Always use the Logo component** instead of importing logo files directly
2. **Choose the correct variant** based on background color:
   - Light backgrounds → `variant="teal"`
   - Dark backgrounds → `variant="white"`
3. **Maintain aspect ratio** - the logo component handles this automatically
4. **Test on multiple screens** after making changes
5. **Update all favicon files** when changing the logo

## Technical Details

- The logo uses SVG format for crisp scaling
- Components use `preserveAspectRatio="xMidYMid meet"` for proper centering
- The original SVG viewBox is `0 0 1020 880`
- All variants use the same SVG paths from `/imports/svg-sne19g9uhw.ts`
