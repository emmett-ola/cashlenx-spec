# CashLenX Data Architecture

## Overview

CashLenX uses a flexible data architecture that supports three modes:
1. **Demo Mode** - Hardcoded demo data (read-only)
2. **Local Mode** - localStorage for logged-in users
3. **API Mode** - Ready for production API integration (future)

## File Structure

```
/utils/storage.ts         → Type-safe localStorage utilities
/data/demoData.ts         → Demo/fixture data
/services/dataService.ts  → Data abstraction layer
```

## How It Works

### 1. Storage Utility (`/utils/storage.ts`)

Provides type-safe localStorage operations with error handling:

```typescript
import { storage } from './utils/storage';

// Get data
const userName = storage.get<string>('userName', 'Default Name');

// Set data
storage.set('userName', 'John Doe');

// Remove data
storage.remove('userName');

// Check if exists
const exists = storage.has('userName');
```

All keys are automatically prefixed with `cashlengx-` to avoid conflicts.

### 2. Demo Data (`/data/demoData.ts`)

Contains hardcoded demo data for non-logged-in users:
- Demo transactions
- Demo budget items
- Demo categories
- Demo summary statistics

### 3. Data Service (`/services/dataService.ts`)

Main abstraction layer that handles all data operations:

```typescript
import { dataService } from './services/dataService';

// Initialize (called automatically when login state changes)
dataService.init(isLoggedIn, userEmail);

// Get current mode
const mode = dataService.getMode(); // 'demo', 'local', or 'api'

// Transactions
const transactions = dataService.getTransactions();
const newTx = dataService.addTransaction({ type: 'expense', amount: 50, ... });
dataService.updateTransaction(id, { amount: 75 });
dataService.deleteTransaction(id);

// Budget
const budget = dataService.getBudget();
dataService.setBudgetItem({ category: 'Food', allocated: 500, ... });
dataService.deleteBudgetItem(id);

// Categories
const categories = dataService.getCategories();
dataService.addCategory({ name: 'Travel', icon: '✈️', ... });
dataService.updateCategory(id, { name: 'Travel & Vacation' });
dataService.deleteCategory(id);

// Summary
const summary = dataService.getSummary();

// Data management
const exportedData = dataService.exportData();
dataService.importData(importedData);
dataService.clearUserData();
```

## Modes Explained

### Demo Mode
- **When**: User is NOT logged in
- **Data Source**: Hardcoded demo data from `/data/demoData.ts`
- **Structure**: Uses proper entity types (UserEntity, CategoryEntity, CashFlowEntity)
- **Persistence**: None (read-only)
- **Use Case**: Testing, trying the app without signup
- **Demo User**: `demo@cashlenz.com` with pre-populated transactions and categories

### Local Mode
- **When**: User IS logged in
- **Data Source**: Browser localStorage via `/services/localStorage.ts`
- **Structure**: Full entity structure with BaseEntity fields (createUserId, createTime, etc.)
- **Persistence**: Persists in browser (survives page refresh)
- **Use Case**: Real user data, personal finance tracking
- **Features**: Multi-user support, soft delete, full CRUD operations

### API Mode (Future)
- **When**: Production deployment
- **Data Source**: Backend API
- **Persistence**: Server-side database
- **Use Case**: Production app with sync across devices

## User Data Isolation

Each logged-in user has isolated data based on their email:
```
cashlengx-user-john@example.com-transactions
cashlengx-user-john@example.com-budget
cashlengx-user-john@example.com-categories
cashlengx-user-john@example.com-initialized
```

## Migration to API (Future)

To migrate to API mode, simply update the `dataService.ts` methods:

```typescript
// BEFORE (Local Mode)
getTransactions(): Transaction[] {
  if (this.mode === 'local') {
    return storage.get<Transaction[]>(this.getUserKey('transactions'), []) || [];
  }
}

// AFTER (API Mode)
async getTransactions(): Promise<Transaction[]> {
  if (this.mode === 'api') {
    const response = await fetch('/api/transactions', {
      headers: { Authorization: `Bearer ${this.accessToken}` }
    });
    return await response.json();
  }
}
```

**No changes needed in components!** They still call `dataService.getTransactions()`.

## Key Benefits

✅ **Separation of Concerns** - Components don't know where data comes from  
✅ **Easy Testing** - Demo mode for quick testing  
✅ **User Isolation** - Each user has separate data  
✅ **Production Ready** - Easy to swap to API  
✅ **Type Safe** - Full TypeScript support  
✅ **Error Handling** - Built-in error handling at storage layer  

## Example: Adding a New Feature

Want to add a "Goals" feature? Just extend the data service:

```typescript
// 1. Add to demoData.ts
export const demoGoals: Goal[] = [...];

// 2. Add to dataService.ts
getGoals(): Goal[] {
  if (this.mode === 'demo') return [...demoGoals];
  if (this.mode === 'local') return storage.get(this.getUserKey('goals'), []);
  // TODO: API mode
}

addGoal(goal: Omit<Goal, 'id'>): Goal {
  // Similar pattern as other methods
}

// 3. Use in components
const goals = dataService.getGoals();
```

That's it! The architecture handles the rest.