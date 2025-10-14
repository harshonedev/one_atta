# One Atta App Blueprint

## Project Overview
One Atta is a Flutter application for flour/atta blending and recipe management. It features a customizer for creating custom flour blends, recipe browsing, order management, and user authentication.

## Current Architecture & Features

### Architecture Pattern
- **Clean Architecture**: Domain, Data, and Presentation layers
- **State Management**: BLoC pattern with flutter_bloc
- **Dependency Injection**: GetIt service locator
- **Navigation**: GoRouter with bottom navigation
- **UI Theme**: Material Design 3 with custom color scheme (orange primary)
- **Local Storage**: SharedPreferences for simple data

### Existing Features

#### 1. Authentication (`features/auth/`)
- Login, Register, OTP verification
- JWT token management
- User profile management

#### 2. Home (`features/home/`)
- Dashboard with blend recommendations
- Quick access to features

#### 3. Recipes (`features/recipes/`)
- Browse and search recipes
- Recipe details with ingredients and steps
- Recipe creation and management
- Video integration for recipe instructions

#### 4. Blends (`features/blends/`)
- Pre-made flour blend catalog
- Blend details and specifications

#### 5. Customizer (`features/customizer/`)
- Custom blend creation
- Nutritional analysis
- Ingredient ratio customization

#### 6. Orders (`features/orders/`)
- Order history and management

#### 7. Reels (`features/reels/`)
- Video content for recipes and tips

#### 8. More (`features/more/`)
- Additional features and settings

### Current Theme & Design
- **Primary Color**: Orange (#e67e22)
- **Typography**: Poppins font family
- **Components**: Material Design 3 components
- **Navigation**: Bottom navigation with 5 tabs
- **Layout**: Consistent spacing and card-based design

## Recent Updates

### Payment Method Selection Simplified (October 8, 2025)
**Feature**: Simplified payment method selection to show only two options:
1. **COD (Cash on Delivery)** - Direct COD payment with additional COD charges
2. **Prepaid (UPI, Card, Wallet)** - Online payment through Razorpay gateway

**Implementation Details**:
- Removed dependency on API-loaded payment methods
- Created local state management for payment type selection (`_selectedPaymentType`)
- When user selects "Prepaid", the `payment_method` sent to backend is "Razorpay"
- Razorpay then handles the actual payment method selection (UPI, Card, Wallet, NetBanking)
- COD charges are automatically calculated and displayed when COD is selected
- Order summary dynamically updates based on selected payment type
- Removed unused `PaymentMethodEntity` import and related methods

**UI Changes**:
- Two prominent payment tiles instead of multiple options
- COD tile: Green icon with money symbol
- Prepaid tile: Purple icon with wallet symbol
- Clear descriptions for each payment type
- Continue button text changes based on selection ("Place Order" for COD, "Continue to Payment" for Prepaid)

### Profile Page Redesign (October 14, 2025)
**Feature**: Redesigned the profile page to match the app's UI theme and styling, removing loyalty points transaction history for a cleaner experience.

**Implementation Details**:
- **Removed Loyalty History**: Eliminated the `LoyaltyHistoryList` widget and related BLoC calls
- **Enhanced Profile Header**: Streamlined design with better spacing and centered layout
- **New Profile Content Sections**:
  - Prominent loyalty points card with gradient background and star icon
  - Profile information cards for email, phone, and member since date
  - Quick actions grid with four action cards (My Orders, Favorites, Settings, Help & Support)

**UI Improvements**:
- **Material Design 3 Consistency**: All components follow the app's orange primary color scheme
- **Card-based Layout**: Consistent 16px border radius across all cards
- **Modern Visual Hierarchy**: 
  - Gradient header with primary color scheme
  - Information cards with subtle borders and icon containers
  - Action cards with secondary color scheme accents
- **Better Spacing**: 24px sections, 16px between cards, proper padding throughout
- **Interactive Elements**: Action cards with tap feedback and proper accessibility
- **Typography**: Consistent with Poppins font family and Material 3 text scales

**Removed Components**:
- `LoyaltyHistoryList` widget
- Loyalty transaction history functionality
- Related BLoC events and states for transaction history

## Current Task: Cart Feature Implementation

### Requirements
- Local database for cart data storage
- Domain layer with repository abstraction and entities
- Presentation layer with consistent UI styling
- Integration with existing navigation and theme

### Implementation Plan

#### 1. Data Layer Setup
- Add sqflite dependency for local database
- Create cart local data source
- Implement cart repository with local storage
- Create cart models for data persistence

#### 2. Domain Layer
- Create cart entities (CartItem, Cart)
- Define cart repository interface
- Create use cases for cart operations:
  - Add item to cart
  - Remove item from cart
  - Update item quantity
  - Clear cart
  - Get cart items

#### 3. Presentation Layer
- Create cart BLoC for state management
- Design cart page with consistent UI
- Add cart icon to navigation/app bar
- Implement cart item widgets
- Add quantity controls and price calculations

#### 4. Integration
- Update dependency injection container
- Add cart routes to router
- Integrate cart with existing features (recipes, blends)
- Add "Add to Cart" buttons where appropriate

#### 5. Features to Implement
- Cart badge with item count
- Cart total calculation
- Quantity increment/decrement
- Remove item functionality
- Empty cart state
- Checkout preparation (for future implementation)

### Database Schema
```sql
CREATE TABLE cart_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_type TEXT NOT NULL, -- 'recipe' or 'blend'
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  image_url TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### UI Components to Create
1. Cart Page with list of items
2. Cart Item Widget with quantity controls
3. Cart Summary Widget with totals
4. Empty Cart Widget
5. Cart Badge for navigation
6. Add to Cart Button component
