# Reactive Coupon System Implementation

## Overview
This document explains the reactive coupon validation system that automatically recalculates discounts when cart items change.

## Architecture

### **1. State Management Flow**

```
Cart Changes (Add/Remove/Update) 
    ↓
CartBloc emits new CartLoaded state
    ↓
CouponInputWidget.didUpdateWidget detects change
    ↓
RevalidateCoupon event dispatched
    ↓
CouponBloc fetches & validates coupon
    ↓
CouponApplied/CouponRemoved state emitted
    ↓
CouponInputWidget updates UI & notifies parent
    ↓
CartBloc updates coupon discount
    ↓
UI reflects new totals
```

### **2. Key Components**

#### **CouponBloc**
- **`ApplyCoupon`**: Initial coupon application with loading state
- **`RevalidateCoupon`**: Silent revalidation without loading state
- **`RemoveCoupon`**: Manual coupon removal

#### **CouponInputWidget**
- **`didUpdateWidget`**: Detects cart changes (orderAmount, items)
- Automatically triggers revalidation when coupon is applied and cart changes
- Handles coupon removal if validation fails

#### **CartBloc**
- Tracks coupon discount in state
- Automatically recalculates totals when discount changes
- Updates delivery charges from DeliveryBloc

#### **CartPage**
- Uses `MultiBlocListener` to coordinate between:
  - DeliveryBloc (for delivery charges)
  - CartBloc (for cart state)
  - CouponBloc (for coupon validation)

## Validation Logic

### **Coupon Validation Steps:**

1. **Active Status**: Coupon must be active
2. **Date Range**: Current date within validFrom-validUntil
3. **Minimum Order**: Order amount meets minimum requirement
4. **Usage Limits**: Coupon hasn't exceeded usage limit
5. **Item Applicability**: Cart contains applicable items
   - `all`: Any items
   - `products`: Only products
   - `blends`: Only blends
   - `specificItems`: Specific item IDs
6. **Discount Calculation**: Calculate based on discount type
   - `fixed`: Fixed amount (capped at applicable amount)
   - `percentage`: Percentage with optional max discount cap

### **Discount Calculation:**

```dart
// For 'all' items
applicableAmount = totalOrderAmount

// For 'products'
applicableAmount = sum(items where itemType == 'Product')

// For 'blends'
applicableAmount = sum(items where itemType == 'Blend')

// For 'specificItems'
applicableAmount = sum(items where itemId in coupon.applicableItems)

// Fixed discount
discount = min(couponValue, applicableAmount)

// Percentage discount
discount = min(applicableAmount * percentage / 100, maxDiscount)
```

## Reactive Behavior

### **When User Adds Item:**
1. CartBloc updates items and totals
2. CouponInputWidget detects orderAmount/items change
3. Automatically revalidates applied coupon
4. Updates discount if still valid
5. Removes coupon if no longer valid
6. UI shows updated totals

### **When User Removes Item:**
1. Same flow as adding item
2. If order no longer meets minimum amount, coupon auto-removes
3. If no applicable items remain, coupon auto-removes

### **When User Updates Quantity:**
1. Same reactive flow
2. Discount recalculated based on new amounts

## Error Handling

### **Validation Failures:**
- Inactive coupon: Auto-remove
- Expired coupon: Auto-remove
- Min order not met: Auto-remove
- No applicable items: Auto-remove
- Usage limit exceeded: Auto-remove

### **Network Failures:**
- If revalidation fetch fails: Auto-remove coupon
- User can reapply if desired

## User Experience

### **Silent Revalidation:**
- No loading spinner during revalidation
- Seamless discount updates
- Only shows snackbar on initial application or errors

### **Visual Feedback:**
- Applied coupon shows green success card
- Discount amount updates in real-time
- Cart summary reflects changes immediately

### **Manual Control:**
- User can manually remove coupon anytime
- User can apply new coupon (replaces old)

## Performance Optimizations

1. **Debounced Revalidation**: Uses `didUpdateWidget` (only triggers on actual changes)
2. **Local Validation First**: Checks coupon entity before network call
3. **Cached Coupon Data**: Reuses fetched coupon entity
4. **Minimal Network Calls**: Only fetches on initial apply and revalidation

## Testing Scenarios

### **Scenario 1: Add Item While Coupon Applied**
- Initial: Cart ₹500, Coupon 10% off (₹50)
- Add item: Cart ₹700
- Result: Coupon 10% off (₹70) ✓

### **Scenario 2: Remove Item Below Minimum**
- Initial: Cart ₹600, Coupon requires ₹500 min (₹60 off)
- Remove items: Cart ₹400
- Result: Coupon auto-removed ❌

### **Scenario 3: Product-Only Coupon with Blends**
- Initial: 2 Products (₹600), Coupon 15% on products (₹90 off)
- Add blend: 2 Products + 1 Blend (₹900 total)
- Result: Coupon still 15% on products only (₹90 off) ✓

### **Scenario 4: Percentage Coupon with Max Cap**
- Initial: Cart ₹1000, Coupon 20% max ₹150 (₹150 off)
- Remove item: Cart ₹600
- Result: Coupon 20% of ₹600 (₹120 off) ✓

## Code Examples

### **Applying Coupon:**
```dart
context.read<CouponBloc>().add(
  ApplyCoupon(
    couponCode: 'FESTIVE15',
    orderAmount: 500,
    items: cartItems,
  ),
);
```

### **Automatic Revalidation:**
```dart
// Triggered automatically in CouponInputWidget
@override
void didUpdateWidget(CouponInputWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  if (_appliedCoupon != null &&
      (oldWidget.orderAmount != widget.orderAmount ||
          oldWidget.items != widget.items)) {
    _revalidateCoupon();
  }
}
```

### **Handling State Changes:**
```dart
BlocListener<CouponBloc, CouponState>(
  listener: (context, state) {
    if (state is CouponApplied) {
      // Update UI with new discount
      widget.onCouponApplied(
        state.appliedCoupon,
        state.application.discountAmount,
      );
    } else if (state is CouponRemoved) {
      // Clear coupon from UI
      widget.onCouponApplied(null, 0.0);
    }
  },
)
```

## Future Enhancements

1. **Debounce Revalidation**: Add delay for rapid quantity changes
2. **Optimistic Updates**: Show estimated discount before revalidation
3. **Multiple Coupons**: Support stacking compatible coupons
4. **Coupon Suggestions**: Suggest better coupons when cart changes
5. **Persistence**: Save applied coupon across sessions
