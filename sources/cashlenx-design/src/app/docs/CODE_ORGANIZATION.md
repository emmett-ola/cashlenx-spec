# CashLenX - Code Organization

## 📁 Project Structure

```
/
├── components/
│   ├── atoms/               # Atomic design - smallest UI components
│   │   ├── Button.tsx
│   │   ├── Chip.tsx
│   │   ├── Input.tsx
│   │   └── Logo.tsx
│   ├── molecules/          # Combinations of atoms
│   │   ├── AuthLayout.tsx
│   │   ├── DatePicker.tsx
│   │   ├── SummaryCard.tsx
│   │   └── TransactionTile.tsx
│   ├── organisms/          # Complex UI components
│   │   ├── BottomNav.tsx
│   │   └── NumericKeypad.tsx
│   ├── screens/            # Full page components
│   │   ├── AddTransaction.tsx
│   │   ├── Budget.tsx
│   │   ├── CategoryManagement.tsx
│   │   ├── CurrencySetup.tsx
│   │   ├── Dashboard.tsx
│   │   ├── Login.tsx
│   │   ├── MoreStatistics.tsx
│   │   ├── Onboarding.tsx
│   │   ├── Profile.tsx
│   │   ├── Settings.tsx
│   │   ├── SignUp.tsx
│   │   ├── Splash.tsx
│   │   └── Transactions.tsx
│   ├── shared/             # Reusable shared components
│   │   ├── ColorPicker.tsx
│   │   ├── ConfirmDialog.tsx
│   │   ├── EmptyState.tsx
│   │   ├── Modal.tsx
│   │   └── index.ts
│   ├── ui/                 # shadcn/ui components (auto-generated)
│   └── figma/              # Figma-specific components (protected)
│       └── ImageWithFallback.tsx
├── constants/
│   ├── avatars.ts          # Avatar presets and constants
│   ├── colors.ts           # Color palette definitions
│   └── sharedStyles.ts     # Shared style constants and design tokens
├── data/
│   └── demoData.ts         # Demo/fixture data
├── docs/
│   ├── Attributions.md
│   ├── CODE_ORGANIZATION.md (this file)
│   ├── DATA_ARCHITECTURE.md
│   ├── LOGO.md
│   ├── STORAGE_DESIGN.md
│   └── TODO.md
├── imports/                # Figma-imported assets
│   ├── CashlenxLogoTeal.tsx
│   ├── CashlenxLogoWhite.tsx
│   └── ...
├── services/
│   ├── dataService.ts      # Data abstraction layer
│   └── localStorage.ts     # localStorage CRUD operations
├── types/
│   └── entities.ts         # TypeScript entity definitions
├── utils/
│   ├── storage.ts          # Generic storage utilities
│   └── supabase/
├── styles/
│   └── globals.css         # Global styles and CSS variables
├── public/                 # Static assets
└── App.tsx                 # Main application component
```

---

## 🎯 Component Organization Principles

### Atomic Design Hierarchy

1. **Atoms** (`/components/atoms/`)
   - Smallest, indivisible UI components
   - Pure, reusable, no business logic
   - Examples: Button, Input, Logo

2. **Molecules** (`/components/molecules/`)
   - Combinations of atoms
   - Simple, reusable component groups
   - Examples: SummaryCard, TransactionTile, DatePicker

3. **Organisms** (`/components/organisms/`)
   - Complex, feature-rich components
   - May contain business logic
   - Examples: BottomNav, NumericKeypad

4. **Screens** (`/components/screens/`)
   - Full page components
   - Route-level components
   - Connect to services and state
   - Examples: Dashboard, Login, Settings

5. **Shared** (`/components/shared/`)
   - Cross-cutting reusable components
   - Not strictly atomic but used everywhere
   - Examples: Modal, EmptyState, ColorPicker, ConfirmDialog

---

## 🗄️ Data Layer

### Service Layer Architecture

```
┌─────────────────┐
│  React Components │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  dataService.ts  │  ← Abstraction layer (mode-aware)
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌──────────────┐
│ Demo   │ │ localStorage  │
│ Data   │ │ Services      │
└────────┘ └──────────────┘
               │
               ▼
         ┌──────────────┐
         │ localStorage  │
         │ (Browser API) │
         └──────────────┘
```

### Data Services

1. **dataService.ts** - Main data abstraction layer
   - Mode-aware (demo/local/api)
   - Legacy interface for backward compatibility
   - Converts between Entity types and UI types

2. **localStorage.ts** - Entity-based CRUD operations
   - UserService
   - CategoryService
   - CashFlowService
   - BudgetService
   - SystemConfigService
   - StorageService (orchestration)

3. **storage.ts** - Generic localStorage utilities
   - Type-safe get/set operations
   - Used for simple key-value storage

---

## 🎨 Styling Strategy

### Global Styles (`/styles/globals.css`)
- CSS reset and base styles
- Typography scale
- CSS custom properties (variables)
- Theme color (`--theme-color`)
- Tailwind v4 directives

### Shared Styles (`/constants/sharedStyles.ts`)
- Layout constants (page, header, container)
- Typography presets
- Avatar presets
- Card styles
- Reusable className strings

### Component Styles
- Inline Tailwind classes (preferred)
- Dynamic styles with `style` prop when needed
- CSS variables for theme colors

---

## 📊 State Management

### Local State (useState)
- Component-specific UI state
- Form inputs
- Modal visibility
- Temporary selections

### App-Level State (App.tsx)
- Authentication state
- User profile data
- Active navigation tab
- Theme color
- Persisted to localStorage via storage utility

### Data State
- Managed by dataService
- Loaded on-demand from localStorage
- No global state - components fetch as needed
- RefreshKey pattern for manual updates

---

## 🔄 Data Flow Patterns

### Reading Data
```
Component → dataService.getX() → localStorage → return data
```

### Writing Data
```
Component → dataService.addX() → localStorage → update → return updated data
Component → trigger refresh (refreshKey++)
```

### Refresh Pattern
```typescript
// App.tsx
const [refreshKey, setRefreshKey] = useState(0);

// Trigger refresh
setRefreshKey(prev => prev + 1);

// Component receives refreshKey
useEffect(() => {
  // Refetch data
}, [refreshKey]);
```

---

## 🛠️ Utilities & Helpers

### Storage Utilities (`/utils/storage.ts`)
- `storage.get<T>(key, defaultValue)` - Type-safe localStorage read
- `storage.set(key, value)` - localStorage write

### Entity Utilities (`/services/localStorage.ts`)
- `generateId()` - UUID generation
- `getCurrentTimestamp()` - ISO timestamp
- `createBaseEntity(userId)` - BaseEntity fields
- `hashPassword()` / `verifyPassword()` - Simple auth (demo only)

---

## 🎭 Naming Conventions

### Files
- PascalCase for components: `Dashboard.tsx`, `SummaryCard.tsx`
- camelCase for utilities: `dataService.ts`, `storage.ts`
- kebab-case for config: `globals.css`
- UPPERCASE for constants: `TODO.md`, `README.md`

### Components
- PascalCase: `export function Dashboard() {}`
- Props interface: `DashboardProps`

### Variables & Functions
- camelCase: `const userName = ...`
- Handler prefix: `handleLogin`, `handleAddTransaction`
- Boolean prefix: `isLoggedIn`, `hasSeenOnboarding`

### Constants
- SCREAMING_SNAKE_CASE: `DEMO_USER_ID`, `STORAGE_KEYS`
- PascalCase for arrays: `APP_COLOR_PALETTE`, `USER_AVATARS`

---

## 🚫 What NOT to Do

### Don't
- ❌ Create duplicate components (use atomic hierarchy)
- ❌ Hardcode colors (use CSS variables or constants)
- ❌ Bypass dataService (always use the abstraction layer)
- ❌ Mutate localStorage directly (use services)
- ❌ Create inline styles when Tailwind class exists
- ❌ Add business logic to atoms/molecules
- ❌ Create new storage keys without documenting in entities.ts

### Do
- ✅ Use shared components from `/components/shared`
- ✅ Follow atomic design principles
- ✅ Use TypeScript interfaces for all props
- ✅ Add JSDoc comments for complex functions
- ✅ Keep components focused and single-purpose
- ✅ Use constants from `/constants` folder
- ✅ Export components from index files

---

## 📦 Import Order Convention

```typescript
// 1. React imports
import React, { useState, useEffect } from 'react';

// 2. External libraries
import { ChevronRight, Plus } from 'lucide-react';

// 3. Internal components
import { Button } from '../atoms/Button';
import { Modal } from '../shared/Modal';

// 4. Services and utilities
import { dataService } from '../../services/dataService';
import { storage } from '../../utils/storage';

// 5. Types
import type { Transaction, Category } from '../../types/entities';

// 6. Constants and styles
import { layout, card } from '../../constants/sharedStyles';
import { APP_COLOR_PALETTE } from '../../constants/colors';
```

---

## 🔐 Protected Files

Do NOT modify these files:
- `/components/figma/ImageWithFallback.tsx`

---

## 📚 Documentation Requirements

When adding new features:
1. Update `/docs/TODO.md` (move from TODO to completed)
2. Add JSDoc comments to public functions/services
3. Update this file if adding new folders/patterns
4. Document new entity types in `/types/entities.ts`
5. Add examples to relevant docs in `/docs/`

---

## 🎯 Code Quality Checklist

Before committing:
- [ ] Remove console.logs (except intentional logging)
- [ ] Remove commented-out code
- [ ] Update TODO comments to reflect current state
- [ ] Follow naming conventions
- [ ] Add TypeScript types for all props/params
- [ ] Use shared components where applicable
- [ ] Test in both demo and logged-in modes
- [ ] Verify responsive design (mobile-first)
- [ ] Check accessibility (keyboard navigation, ARIA labels)
