# CashLenX - TODO List

## ✅ Completed Features

### Core Infrastructure
- ✅ Atomic design system implementation
- ✅ localStorage-based data persistence
- ✅ Entity-based data architecture (BaseEntity pattern)
- ✅ Demo mode vs. logged-in user separation
- ✅ Data service layer for API-ready abstraction
- ✅ Theme color system with CSS variables
- ✅ Shared design constants and styles

### Authentication & User Management
- ✅ Login/SignUp screens with real authentication
- ✅ Profile management
- ✅ Avatar system with preset avatars
- ✅ Demo mode with fresh data initialization
- ✅ Session persistence

### Financial Features
- ✅ Dashboard with summary cards
- ✅ Transaction management (add, view, filter, sort)
- ✅ Category management (tree structure with parent/child)
- ✅ Custom numeric keypad for amount input
- ✅ Budget tracking with spending calculation
- ✅ Income and Expense tracking (Transfer type removed)
- ✅ Real-time category updates across all screens

### UI/UX
- ✅ Onboarding flow
- ✅ Splash screen
- ✅ Bottom navigation
- ✅ Mobile-first responsive design
- ✅ Glassmorphism effects
- ✅ Toast notifications
- ✅ Logo system (white and teal variants)

---

## 🚧 In Progress

### Bug Fixes
- ⏳ Category color/icon changes not reflecting on Dashboard/Transactions page immediately
  - State management implemented but needs testing
  - RefreshKey prop added to Dashboard and Transactions

---

## 📋 TODO - High Priority

### Data & State Management
- [ ] Implement monthly change calculation for summary
- [ ] Add budget allocation CRUD operations in localStorage
- [ ] Add budget deletion functionality
- [ ] Implement transaction editing UI
- [ ] Implement transaction deletion UI with confirmation
- [ ] Add category move functionality to change parent/child relationships

### Features
- [ ] Add date range filtering for dashboard (this week, this month, custom)
- [ ] Add export data functionality (CSV/JSON)
- [ ] Add import data functionality
- [ ] Implement search in transactions
- [ ] Add recurring transactions
- [ ] Add transaction notes/attachments
- [ ] Add spending insights and trends

### Statistics & Analytics
- [ ] Expand MoreStatistics screen with real data
- [ ] Add monthly spending trends chart
- [ ] Add category breakdown pie chart with real data
- [ ] Add income vs expense comparison over time
- [ ] Add budget progress visualization

### UI/UX Improvements
- [ ] Add loading states for data operations
- [ ] Add error handling and error boundaries
- [ ] Add offline mode indicator
- [ ] Improve transaction tile with swipe actions (edit/delete)
- [ ] Add pull-to-refresh on Dashboard
- [ ] Add skeleton loaders for better perceived performance

---

## 📋 TODO - Medium Priority

### Category Management
- [ ] Add category icons library (beyond emoji picker)
- [ ] Add category usage statistics
- [ ] Add category sorting/reordering
- [ ] Prevent deletion of categories with transactions (or show warning)

### Budget Features
- [ ] Add budget period selection (weekly, monthly, yearly)
- [ ] Add budget alerts when approaching limit
- [ ] Add budget rollover option
- [ ] Add visual budget progress bars on Dashboard

### Settings & Preferences
- [ ] Add currency selection with persistence
- [ ] Add language selection
- [ ] Add notification preferences
- [ ] Add data backup reminder settings
- [ ] Add app tutorial/help section

---

## 📋 TODO - Low Priority / Future

### API Integration (Future)
- [ ] Implement API mode in dataService
- [ ] Add API authentication with JWT
- [ ] Add real-time sync with backend
- [ ] Add conflict resolution for offline changes
- [ ] Add data migration from localStorage to API

### Advanced Features
- [ ] Add bill reminders
- [ ] Add receipt scanning
- [ ] Add multi-currency support
- [ ] Add collaborative budgets (family/shared accounts)
- [ ] Add financial goals tracking
- [ ] Add savings goals
- [ ] Add investment tracking

### Performance & Optimization
- [ ] Add React.memo for expensive components
- [ ] Implement virtual scrolling for long transaction lists
- [ ] Add service worker for PWA capabilities
- [ ] Add image optimization for avatars
- [ ] Bundle size optimization

### Testing & Quality
- [ ] Add unit tests for services
- [ ] Add integration tests for critical flows
- [ ] Add E2E tests for user journeys
- [ ] Add accessibility testing
- [ ] Add performance monitoring

---

## 🐛 Known Issues

1. **Category Changes Not Reflecting Immediately**
   - Status: Fix implemented, needs verification
   - Impact: Medium
   - Category icon/color changes don't show on Dashboard/Transactions until manual refresh

2. **Budget Deletion Not Implemented**
   - Status: TODO
   - Impact: Low
   - Users cannot delete budget items

3. **Monthly Change Calculation**
   - Status: TODO
   - Impact: Low
   - Shows '+0%' placeholder instead of actual calculation

---

## 🎯 Next Sprint Goals

1. Fix category refresh issue (verify fix works)
2. Implement transaction edit/delete functionality
3. Add monthly change calculation
4. Improve budget management (add/edit/delete)
5. Add loading states and error handling

---

## 📝 Notes

- Keep TODO comments in code for inline implementation notes
- API mode TODOs are intentionally kept as placeholders for future work
- All localStorage operations should use the storage utility for consistency
- Follow atomic design principles when creating new components
- Use shared components from `/components/shared` when possible
