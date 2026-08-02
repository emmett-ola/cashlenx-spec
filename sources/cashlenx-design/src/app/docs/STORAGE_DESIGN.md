# CashLenX Storage Design

## Overview

CashLenX uses a well-structured localStorage system for data persistence. The design follows a four-part architecture that separates concerns and provides user isolation for multi-user support.

## Storage Architecture

### 1. System Config (`cashlenx_system_config`)

Global application settings and configuration.

```typescript
interface SystemConfig {
  isFirstBoot: boolean;           // First time app launch
  appVersion: string;              // App version for migrations
  lastUpdated: string;             // Last update timestamp
  defaultUserId: string | null;    // Currently logged in user
  themeColor: string;              // Global theme color
  hasSeenOnboarding: boolean;      // Onboarding completion
  hasCompletedTutorial: boolean;   // Tutorial completion
  preferredLanguage: string;       // User's language preference
}
```

**Usage:**
- App initialization and first boot detection
- Current user session management
- Global UI preferences
- Feature flags and settings

### 2. User Info (`cashlenx_user_info`)

User accounts with authentication and profile data. Stored as an array of users to support multi-user functionality.

**Important: Username is the full email address and cannot be modified. Nickname is auto-generated from email prefix.**

```typescript
interface UserEntity extends BaseEntity {
  id: string;                 // UUID
  username: string;           // Full email address (e.g., "john.doe@example.com") - READ ONLY, used for login
  passwordHash: string;       // Hashed password
  isActive: boolean;          // Account active status
  role: string;               // 'user' | 'admin' | 'demo'
  nickname: string;           // Display name auto-formatted from email prefix (e.g., "John Doe" from "john.doe") - EDITABLE
  avatarUrl: string;          // Avatar image URL
  emailAddress: string;       // Email address (same as username)
  isEmailVerified: boolean;   // Email verification status
  gender: string;             // Gender preference
  currency: string;           // Preferred currency (USD, EUR, etc.)
  phone: string;              // Phone number
  location: string;           // User location
  birthDate: string;          // Birth date (ISO 8601)
}
```

**Features:**
- Multi-user support
- Username is the full email address
- Nickname auto-formatted from email prefix: `john.doe` → `John Doe`, `jane_smith` → `Jane Smith`
- Username cannot be changed after signup
- Nickname is editable in profile
- Authentication with hashed passwords
- Soft delete support (isDelete field)
- Complete profile management

### 3. Cash Flow (`cashlenx_cash_flow`)

Transaction records (expenses and income) with user isolation. Each transaction belongs to a specific user.

```typescript
interface CashFlowEntity extends BaseEntity {
  id: string;                // UUID
  belongsUserId: string;     // Owner user ID
  categoryId: string;        // Reference to category
  belongsDate: string;       // Transaction date (ISO 8601)
  amount: number;            // Transaction amount (always positive)
  description: string;       // Transaction description
  remark: string;            // Additional notes
  // Computed fields (from category)
  categoryName: string;      // Category name (computed)
  categoryType: string;      // 'expense' | 'income' (computed)
}
```

**Features:**
- User-isolated transactions
- Category relationship
- Date-based filtering
- Rich descriptions and remarks
- Type computed from category

### 4. Category (`cashlenx_category`)

Transaction categories with tree structure support. Each user has their own categories, plus default system categories created on signup.

```typescript
interface CategoryEntity extends BaseEntity {
  id: string;                // UUID
  belongsUserId: string;     // Owner user ID
  parentId: string | null;   // Parent category (tree structure)
  name: string;              // Category name
  type: string;              // 'expense' | 'income'
  icon: string;              // Icon emoji or name
  remark: string;            // Description
  isDefault: boolean;        // System default category
}
```

**Features:**
- User-isolated categories
- Tree structure (parent-child relationships)
- Default categories on user creation
- Custom user categories
- Icon support

## Base Entity

All entities extend `BaseEntity` which provides timestamp tracking and soft delete support:

```typescript
interface BaseEntity {
  createdAt: string;      // ISO 8601 timestamp
  updatedAt: string;      // ISO 8601 timestamp
  deletedAt: string | null; // ISO 8601 timestamp (null if not deleted)
}
```

## Service Layer

### SystemConfigService
- `get()` - Get system config
- `set(config)` - Update system config
- `initialize()` - First boot initialization
- `reset()` - Reset to defaults

### UserService
- `getAll()` - Get all users
- `getById(id)` - Get user by ID
- `getByUsername(username)` - Get user by username
- `create(userData)` - Create new user
- `update(id, updates)` - Update user
- `delete(id)` - Soft delete user
- `authenticate(username, password)` - Login
- `getCurrentUser()` - Get logged in user
- `setCurrentUser(userId)` - Set logged in user

### CategoryService
- `getAll()` - Get all categories
- `getByUserId(userId)` - Get user's categories
- `getById(id)` - Get category by ID
- `create(categoryData)` - Create category
- `update(id, updates)` - Update category
- `delete(id)` - Soft delete category
- `createDefaultCategories(userId)` - Create defaults for new user
- `getCategoryTree(userId)` - Get root categories
- `getChildren(parentId)` - Get child categories

### CashFlowService
- `getAll()` - Get all transactions
- `getByUserId(userId)` - Get user's transactions
- `getById(id)` - Get transaction by ID
- `create(cashFlowData)` - Create transaction
- `update(id, updates)` - Update transaction
- `delete(id)` - Soft delete transaction
- `getByDateRange(userId, start, end)` - Filter by date
- `getTotalIncome(userId)` - Calculate total income
- `getTotalExpense(userId)` - Calculate total expense
- `getBalance(userId)` - Calculate balance

### StorageService
- `initialize()` - Initialize storage system
- `clearAll()` - Clear all data (reset)
- `exportData()` - Export as JSON for backup
- `importData(json)` - Import from backup
- `getStorageSize()` - Get storage usage

## Default Categories

When a new user is created, the following default categories are automatically generated:

### Expense Categories (with subcategories):
1. **Food & Dining** 🍔
   - Restaurants
   - Groceries
   - Coffee

2. **Transportation** 🚗
   - Gas
   - Public Transit
   - Parking

3. **Shopping** 🛍️
   - Clothing
   - Electronics
   - Home

4. **Entertainment** 🎬
   - Movies
   - Games
   - Hobbies

5. **Bills & Utilities** 💡
   - Electricity
   - Water
   - Internet

6. **Healthcare** 🏥
   - Doctor
   - Pharmacy
   - Insurance

### Income Categories:
1. **Salary** 💰
2. **Freelance** 💼
3. **Investment** 📈
4. **Gift** 🎁

## Data Isolation

- **System Config**: Global, shared across all users
- **User Info**: All users stored together, filtered by authentication
- **Cash Flow**: User-isolated via `belongsUserId` field
- **Category**: User-isolated via `belongsUserId` field

Each user only sees their own transactions and categories. The system supports multiple users with separate data.

## Migration Path to Backend

This localStorage design mirrors a MongoDB backend structure, making it easy to migrate:

1. UUID generation can be replaced with MongoDB ObjectID
2. Service layer can be updated to make API calls instead of localStorage operations
3. Entity structure is identical to backend models
4. User isolation logic remains the same
5. BaseEntity fields map directly to MongoDB timestamps

**Migration Steps:**
1. Update service layer to use API endpoints
2. Replace `localStorage.getItem/setItem` with `fetch()` calls
3. Add authentication tokens to requests
4. Handle async operations with promises
5. Keep entity types unchanged

## Storage Size Limits

- Most browsers provide 5-10MB for localStorage
- Current implementation tracks storage usage via `getStorageSize()`
- Consider implementing data pruning or migration to backend when approaching limits

## Security Notes

⚠️ **Important**: The current password hashing is for DEMO purposes only!

- Passwords are hashed using simple base64 encoding with salt
- **NEVER** use this in production
- In production:
  - Use bcrypt/argon2 on backend
  - Never store passwords in browser
  - Use JWT tokens for authentication
  - Implement proper session management

## Example Usage

```typescript
import {
  UserService,
  CategoryService,
  CashFlowService,
  SystemConfigService,
  StorageService,
} from './services/localStorage';

// Initialize on app start
StorageService.initialize();

// Create a new user (nickname auto-generated from email prefix)
const email = 'john.doe@example.com';

const user = UserService.create({
  username: email, // Full email as username
  password: 'password123',
  nickname: formatDisplayName(email.split('@')[0]), // "John Doe" from "john.doe"
  emailAddress: email,
  role: 'user',
});
// Default categories are automatically created!

// Login with email as username
const authenticated = UserService.authenticate(email, 'password123');
if (authenticated) {
  UserService.setCurrentUser(authenticated.id);
}

// Get current user
const currentUser = UserService.getCurrentUser();

// Create a transaction
const transaction = CashFlowService.create({
  belongsUserId: currentUser.id,
  categoryId: 'some-category-id',
  belongsDate: new Date().toISOString(),
  amount: 50.00,
  description: 'Lunch at cafe',
  remark: 'With colleagues',
});

// Get user's transactions
const transactions = CashFlowService.getByUserId(currentUser.id);

// Get balance
const balance = CashFlowService.getBalance(currentUser.id);

// Export backup
const backup = StorageService.exportData();
console.log(backup); // JSON string

// Import backup
StorageService.importData(backup);
```

## Future Enhancements

1. **Data Sync**: Implement sync with backend when online
2. **Offline Support**: Queue operations when offline
3. **Data Validation**: Add Zod or Yup schemas for validation
4. **Encryption**: Encrypt sensitive data in localStorage
5. **Compression**: Compress large datasets
6. **Indexing**: Add search/filter optimization
7. **Relationships**: Add foreign key validation
8. **Migrations**: Add version-based migration system
9. **Caching**: Implement in-memory cache layer
10. **Events**: Add pub/sub for data changes