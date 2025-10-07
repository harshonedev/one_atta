# Reactive Delivery & Discount System

## Overview
This document explains the fully reactive delivery fee validation and dynamic discount messaging system that updates automatically when cart contents change.

## Architecture

### **Complete Reactive Flow**

```
User Action (Add/Remove/Update Cart Item)
    ↓
CartBloc updates cart state (items, totals)
    ↓
┌─────────────────────┬──────────────────────┐
│                     │                      │
▼                     ▼                      ▼
DeliveryBloc      CouponBloc           UI Updates
Recalculates      Revalidates         Real-time
Delivery Fee      Discount            Display
    ↓                 ↓                      ↓
Checks Free       Updates Coupon      Shows Messages:
Delivery          Discount            - Delivery Info
Threshold         Amount              - Coupon Savings
    ↓                 ↓                - Threshold Alerts
Updates           CartBloc
CartBloc          Updates
                  Discount
```

## Key Features

### **1. Reactive Delivery Fee Calculation**

#### **Automatic Recalculation**
- Triggers when cart `itemTotal` changes
- Maintains selected address context
- Preserves express delivery preference

#### **Free Delivery Threshold**
The system tracks a `freeDeliveryThreshold` value and dynamically displays:

**Case 1: Already Free Delivery**
```dart
if (isFreeDelivery) {
  // Shows: "Yay! You got FREE delivery"
  // Green success banner
}
```

**Case 2: Close to Free Delivery**
```dart
if (itemTotal < threshold) {
  final amountNeeded = threshold - itemTotal;
  // Shows: "Add items worth ₹X more for FREE delivery"
  // Orange info banner with exact amount needed
}
```

**Case 3: Standard Delivery Fee**
```dart
if (deliveryFee > 0) {
  // Shows: "Delivery fee: ₹X"
  // Neutral info banner
}
```

### **2. Dynamic Discount Messages**

#### **Enhanced Coupon Display**
The applied coupon card now shows:
- **Coupon Code**: Bold, prominent display
- **Coupon Name**: Description of the offer
- **Savings Badge**: Highlighted discount amount

**Visual Layout:**
```
┌─────────────────────────────────────────┐
│ ✓  FESTIVE15                        ✕   │
│    Festive Season                       │
│    [You saved ₹150]                     │
└─────────────────────────────────────────┘
```

#### **Real-time Discount Updates**
- Discount amount recalculates as cart changes
- Updates automatically without page refresh
- Shows current applicable discount

### **3. Reactive UI Components**

#### **Delivery Fee Info Widget**
```dart
_buildDeliveryFeeInfo()
```

**Displays:**
- 🟢 Free delivery achieved
- 🟠 Amount needed for free delivery
- ⚪ Current delivery fee

**Color Coding:**
- Green: Success (free delivery)
- Orange: Alert (close to threshold)
- Gray: Info (standard fee)

#### **Coupon Input Widget**
```dart
CouponInputWidget(
  orderAmount: itemTotal,
  items: cartItems,
  onCouponApplied: callback,
)
```

**Features:**
- Auto-revalidates on cart changes
- Shows enhanced savings display
- Silent background updates

## Implementation Details

### **1. Cart State Listener**

```dart
BlocListener<CartBloc, CartState>(
  listener: (context, cartState) {
    if (cartState is CartLoaded && _selectedAddress != null) {
      // Recalculate delivery for new total
      context.read<DeliveryBloc>().add(
        CheckDeliveryAvailability(
          pincode: _selectedAddress!.postalCode,
          orderValue: cartState.itemTotal,
        ),
      );
    }
  },
)
```

**Triggers When:**
- Items added to cart
- Items removed from cart
- Quantity updated
- Price changes

### **2. Delivery State Structure**

```dart
class DeliveryLoaded extends DeliveryState {
  final double deliveryCharges;
  final bool isFreeDelivery;
  final double freeDeliveryThreshold;
  final String etaDisplay;
  // ... other fields
}
```

**Key Fields:**
- `deliveryCharges`: Current delivery fee
- `isFreeDelivery`: Boolean flag for free delivery
- `freeDeliveryThreshold`: Minimum order for free delivery
- `etaDisplay`: Estimated delivery time

### **3. Threshold Calculation Logic**

```dart
// In DeliveryBloc
if (orderValue >= zoneInfo.freeDeliveryThreshold) {
  deliveryCharges = 0.0;
  isFreeDelivery = true;
} else {
  deliveryCharges = zoneInfo.deliveryCharges;
  isFreeDelivery = false;
}
```

## User Experience Scenarios

### **Scenario 1: Approaching Free Delivery**

**Initial State:**
- Cart Total: ₹450
- Free Delivery Threshold: ₹500
- Current Delivery: ₹40

**Display:**
```
🟠 Add items worth ₹50 more for FREE delivery
```

**User Action:** Adds ₹60 item

**New State:**
- Cart Total: ₹510
- Delivery: ₹0 (FREE)

**Display:**
```
🟢 Yay! You got FREE delivery
```

### **Scenario 2: Coupon with Changing Cart**

**Initial State:**
- Cart: 2 Products (₹600)
- Coupon: 15% on products (max ₹150)
- Discount: ₹90

**Display:**
```
✓ FESTIVE15
  Festive Season
  [You saved ₹90]
```

**User Action:** Adds ₹400 product

**New State:**
- Cart: 3 Products (₹1000)
- Discount: ₹150 (capped at max)

**Display:**
```
✓ FESTIVE15
  Festive Season
  [You saved ₹150]
```

### **Scenario 3: Below Minimum Order**

**Initial State:**
- Cart Total: ₹600
- Coupon: Min order ₹500, 10% off
- Discount: ₹60

**User Action:** Removes ₹250 item

**New State:**
- Cart Total: ₹350
- Coupon: Auto-removed (below minimum)
- Discount: ₹0

**User Sees:**
- Coupon card disappears
- Order total updates
- No snackbar (silent removal)

### **Scenario 4: Products-Only Coupon**

**Initial State:**
- Cart: 2 Products (₹400) + 1 Blend (₹200)
- Total: ₹600
- Coupon: 20% on products only
- Discount: ₹80 (20% of ₹400)

**Display:**
```
✓ PRODUCT20
  Products Special
  [You saved ₹80]
```

**User Action:** Adds ₹200 product

**New State:**
- Cart: 3 Products (₹600) + 1 Blend (₹200)
- Total: ₹800
- Discount: ₹120 (20% of ₹600)

**Display:**
```
✓ PRODUCT20
  Products Special
  [You saved ₹120]
```

## Visual Design

### **Delivery Fee Banner Styles**

**Free Delivery (Green):**
```
┌─────────────────────────────────────────┐
│ 🚚  Yay! You got FREE delivery          │
└─────────────────────────────────────────┘
Background: Green (10% opacity)
Border: Green (30% opacity)
```

**Threshold Alert (Orange):**
```
┌─────────────────────────────────────────┐
│ ℹ️  Add items worth ₹50 more for FREE   │
│    delivery                             │
└─────────────────────────────────────────┘
Background: Orange (10% opacity)
Border: Orange (30% opacity)
```

**Standard Fee (Gray):**
```
┌─────────────────────────────────────────┐
│ 🚚  Delivery fee: ₹40                   │
└─────────────────────────────────────────┘
Background: Surface Container
```

### **Coupon Card Enhancement**

**Before:**
```
✓ FESTIVE15
  Saved ₹150
```

**After:**
```
✓ FESTIVE15
  Festive Season
  [You saved ₹150]  ← Badge style
```

## Performance Optimizations

### **1. Intelligent Recalculation**
- Only triggers when `itemTotal` actually changes
- Uses existing delivery state to preserve settings
- Minimal network calls (reuses cached zone data)

### **2. Silent Updates**
- No loading spinners for revalidation
- Smooth transitions
- No user interruption

### **3. Debouncing Strategy**
- `didUpdateWidget` prevents duplicate triggers
- BLoC handles state deduplication
- Efficient state propagation

## Code Examples

### **Checking Delivery After Cart Update**

```dart
BlocListener<CartBloc, CartState>(
  listener: (context, cartState) {
    if (cartState is CartLoaded && _selectedAddress != null) {
      final deliveryState = context.read<DeliveryBloc>().state;
      
      if (deliveryState is DeliveryLoaded) {
        context.read<DeliveryBloc>().add(
          CheckDeliveryAvailability(
            pincode: _selectedAddress!.postalCode,
            orderValue: cartState.itemTotal,
            isExpress: deliveryState.isExpressDelivery,
          ),
        );
      }
    }
  },
)
```

### **Building Delivery Info Banner**

```dart
Widget _buildDeliveryFeeInfo() {
  return BlocBuilder<DeliveryBloc, DeliveryState>(
    builder: (context, deliveryState) {
      if (deliveryState is! DeliveryLoaded) {
        return const SizedBox.shrink();
      }

      return BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState is! CartLoaded) {
            return const SizedBox.shrink();
          }

          final itemTotal = cartState.itemTotal;
          final threshold = deliveryState.freeDeliveryThreshold;
          final isFree = deliveryState.isFreeDelivery;

          if (isFree) {
            return _buildSuccessBanner('Yay! You got FREE delivery');
          }

          if (itemTotal < threshold) {
            final amountNeeded = threshold - itemTotal;
            return _buildAlertBanner(
              'Add items worth ₹${amountNeeded.toInt()} more for FREE delivery'
            );
          }

          return _buildInfoBanner(
            'Delivery fee: ₹${deliveryState.deliveryCharges.toInt()}'
          );
        },
      );
    },
  );
}
```

### **Enhanced Coupon Card**

```dart
Widget _buildAppliedCouponCard() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coupon code
              Text(_appliedCoupon!.code, style: boldGreenStyle),
              // Coupon name
              Text(_appliedCoupon!.name, style: subtleGreenStyle),
              // Savings badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'You saved ₹${_discountAmount.toInt()}',
                  style: whiteTextStyle,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _removeCoupon,
          icon: Icon(Icons.close, color: Colors.green.shade600),
        ),
      ],
    ),
  );
}
```

## Testing Checklist

### **Delivery Fee Tests**

- [ ] Add items to reach free delivery threshold
- [ ] Remove items to go below threshold
- [ ] Verify threshold message appears when close
- [ ] Verify success message when threshold reached
- [ ] Test with different zone configurations
- [ ] Verify express delivery affects threshold

### **Coupon Discount Tests**

- [ ] Apply coupon and add items
- [ ] Verify discount updates automatically
- [ ] Apply coupon and remove items
- [ ] Verify coupon removes when below minimum
- [ ] Test percentage coupons with max cap
- [ ] Test fixed amount coupons
- [ ] Test product-only coupons with mixed cart
- [ ] Test blend-only coupons with mixed cart

### **UI/UX Tests**

- [ ] Verify no loading spinners during revalidation
- [ ] Verify smooth transitions
- [ ] Verify color coding is correct
- [ ] Verify badge styling is consistent
- [ ] Verify text is readable
- [ ] Test on different screen sizes
- [ ] Verify accessibility (color contrast)

## Future Enhancements

### **Phase 1: Advanced Messaging**
1. **Smart Suggestions**: "Add 1 more item to unlock free delivery"
2. **Product Recommendations**: Show items that would reach threshold
3. **Delivery Time Updates**: "Order in 2 hours for same-day delivery"

### **Phase 2: Gamification**
1. **Progress Bar**: Visual indicator for free delivery threshold
2. **Achievement Badges**: "You unlocked free delivery!"
3. **Streak Bonuses**: "Free delivery on your next 3 orders"

### **Phase 3: Personalization**
1. **User History**: "You usually reach free delivery - ₹50 more!"
2. **Smart Thresholds**: Adjust based on user behavior
3. **Location-based**: Different thresholds for different zones

## Troubleshooting

### **Delivery Fee Not Updating**
**Check:**
1. Is `_selectedAddress` set?
2. Is `CartLoaded` state being emitted?
3. Is `DeliveryBloc` receiving the event?
4. Check network connectivity for zone data

### **Coupon Not Revalidating**
**Check:**
1. Is `didUpdateWidget` being called?
2. Is `orderAmount` or `items` actually changing?
3. Is `CouponBloc` receiving the `RevalidateCoupon` event?
4. Check coupon validation logic

### **Incorrect Threshold Messages**
**Check:**
1. Is `freeDeliveryThreshold` correctly fetched from API?
2. Is `itemTotal` excluding discounts?
3. Is zone configuration correct for the pincode?

## Summary

The reactive delivery and discount system provides:
- ✅ Automatic delivery fee recalculation
- ✅ Dynamic free delivery threshold alerts
- ✅ Real-time coupon discount updates
- ✅ Enhanced visual feedback
- ✅ Seamless user experience
- ✅ No manual refresh needed
- ✅ Smart threshold messaging

Users get instant, accurate information about their savings and delivery options as they shop! 🎉
