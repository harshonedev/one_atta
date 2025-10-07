# Atta Points and Coupon Mutual Exclusivity Implementation

## Overview
Implemented mutual exclusivity between Atta Points (loyalty points) and coupons in the cart page. Users can now only use one discount method at a time, and the delivery fee threshold is validated based on the amount after applying Atta Points.

## Key Changes

### 1. Cart Page (`cart_page.dart`)
- **State Management Updates:**
  - Changed `_loyaltyPointsToRedeem` from final to mutable
  - Added `_loyaltyDiscountAmount` to track loyalty discount amount
  
- **Mutual Exclusivity Logic:**
  - Updated `_onCouponApplied()` to check if loyalty points are already applied
  - Added new `_onLoyaltyPointsRedeemed()` method to check if coupon is already applied
  - Both methods show appropriate snackbar messages when mutual exclusivity is violated
  
- **Delivery Fee Calculation:**
  - Modified delivery fee calculation to use `itemTotal - _loyaltyDiscountAmount`
  - Ensures free delivery threshold is validated on amount AFTER loyalty discount
  - Recalculates delivery fee whenever loyalty points or coupons change
  
- **UI Updates:**
  - Atta Points widget now appears BEFORE coupon widget
  - Added informational messages below each widget:
    - When Atta Points are applied: "Atta Points applied. You cannot use a coupon."
    - When coupon is applied: "Coupon applied. You cannot use Atta Points."
  - Both widgets pass `isDisabled` flag to disable the other when one is active

### 2. Loyalty Points Redemption Widget (`loyalty_points_redemption_widget.dart`)
- **Always Visible:**
  - Widget now shows even when user has 0 Atta Points
  - Displays message: "You don't have any Atta Points yet. Start shopping to earn points!"
  
- **Branding Update:**
  - Changed label from "Loyalty Points" to "Atta Points"
  
- **Disable Functionality:**
  - Added `isDisabled` parameter (default: false)
  - Widget becomes disabled and grayed out when `isDisabled` is true
  - Input field and redeem button are disabled when:
    - `isDisabled` flag is true (coupon is applied), OR
    - User has 0 points available
  
- **Visual Feedback:**
  - Background color changes to gray when disabled
  - Icon color changes to gray when disabled
  - Text color changes to gray when disabled

### 3. Coupon Input Widget (`coupon_input_widget.dart`)
- **Disable Functionality:**
  - Added `isDisabled` parameter (default: false)
  - Widget becomes disabled and grayed out when `isDisabled` is true
  - Input field placeholder text changes to "Remove Atta Points to use coupon" when disabled
  - Apply button is disabled when loyalty points are applied
  
- **Visual Feedback:**
  - Background color changes to gray when disabled
  - Icon color changes to gray when disabled
  - Text color changes to gray when disabled

## User Flow

### Scenario 1: User applies Atta Points first
1. User redeems Atta Points
2. Delivery fee is recalculated based on amount after Atta Points discount
3. Coupon input widget becomes disabled with message
4. If user tries to apply coupon, they see error: "Remove Atta Points to apply coupon"

### Scenario 2: User applies coupon first
1. User applies coupon code
2. Delivery fee uses original item total (coupons don't affect delivery threshold)
3. Atta Points widget becomes disabled with message
4. If user tries to redeem Atta Points, they see error: "Remove coupon to use Atta Points"

### Scenario 3: User removes applied discount
1. User can remove either Atta Points or coupon
2. Other discount option becomes enabled again
3. Delivery fee is recalculated accordingly

## Technical Details

### Delivery Fee Logic
- **Without Atta Points:** Delivery fee calculated on `itemTotal`
- **With Atta Points:** Delivery fee calculated on `itemTotal - loyaltyDiscountAmount`
- **With Coupon:** Delivery fee calculated on `itemTotal` (coupons don't affect delivery threshold)

### Event Flow
```
User Action → Cart Page State Update → 
  ↓
Apply to Cart Bloc (ApplyLoyaltyPoints/ApplyCoupon) →
  ↓
Recalculate Delivery Fee (CheckDeliveryAvailability) →
  ↓
Update UI with new totals
```

## Benefits
1. **Clear User Experience:** Users understand they can only use one discount at a time
2. **Proper Delivery Fee Calculation:** Atta Points correctly reduce the order value for delivery threshold
3. **Always Visible Atta Points:** Even users with 0 points see the feature and understand how to earn points
4. **Consistent Branding:** "Atta Points" branding is consistent throughout the app
5. **Visual Feedback:** Disabled states clearly indicate when a feature is unavailable

## Testing Recommendations
1. Test with 0 Atta Points available
2. Test applying Atta Points first, then trying coupon
3. Test applying coupon first, then trying Atta Points
4. Test removing Atta Points and then applying coupon
5. Test delivery fee calculation with different point amounts
6. Test free delivery threshold with Atta Points applied
7. Verify all informational messages display correctly
