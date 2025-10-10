# Payment API V2.0 Migration Summary

## Overview
This document summarizes the refactoring of the payment feature to align with the new Payment System API V2.0 as documented in `DOCS/PAYMENT_SYSTEM_API_DOCS.md`.

## Key Changes

### 1. **Calculation Responsibility Shift** 🔄
- **Before (V1.0)**: Backend calculated all order values (subtotal, discount, total)
- **After (V2.0)**: **Frontend calculates** all values, backend **validates only**

### 2. **New Required Fields in OrderItem Entity**

#### `/lib/features/payment/domain/entities/order_entity.dart`
```dart
class OrderItem {
  final String id;
  final String type;
  final int quantity;
  final double weightInKg;      // ✅ Changed from int to double
  final double pricePerKg;      // ✅ NEW
  final double totalPrice;      // ✅ NEW
}
```

**Changes:**
- `weightInKg`: Changed type from `int` to `double` for precision
- `pricePerKg`: NEW - Price per kilogram
- `totalPrice`: NEW - Pre-calculated total for this item

### 3. **New Required Fields in Order Entity**

#### `/lib/features/payment/domain/entities/order_entity.dart`
```dart
class OrderEntity {
  // ... existing fields ...
  final double subtotal;
  final double discountAmount;
  final bool isDiscountAvailed;    // ✅ NEW
  final String? discountType;      // ✅ NEW: "loyalty" or "coupon" or null
  final double totalAmount;
  // ... other fields ...
}
```

**New Fields:**
- `isDiscountAvailed`: Boolean flag indicating if discount was applied
- `discountType`: Type of discount - "loyalty", "coupon", or null

### 4. **Updated API Signatures**

#### Create Order Method

**Before:**
```dart
Future<CreateOrderResponse> createOrder({
  required List<OrderItem> items,
  required String deliveryAddress,
  required List<String> contactNumbers,
  required String paymentMethod,
  String? couponCode,
  int? loyaltyPointsUsed,
  required double deliveryCharges,
  required double codCharges,
});
```

**After:**
```dart
Future<CreateOrderResponse> createOrder({
  required List<OrderItem> items,
  required String deliveryAddress,
  required List<String> contactNumbers,
  required String paymentMethod,
  required double subtotal,           // ✅ NEW: Pre-calculated
  required double discountAmount,     // ✅ NEW: Pre-calculated
  required double deliveryCharges,
  required double codCharges,
  required double totalAmount,        // ✅ NEW: Pre-calculated
  bool isDiscountAvailed = false,     // ✅ NEW
  String? discountType,               // ✅ NEW
  String? couponCode,
  int loyaltyPointsUsed = 0,
});
```

### 5. **Updated Bloc Event**

#### `/lib/features/payment/presentation/bloc/payment_event.dart`

```dart
class CreateOrder extends PaymentEvent {
  final List<OrderItem> items;
  final String deliveryAddress;
  final List<String> contactNumbers;
  final String paymentMethod;
  final double subtotal;              // ✅ NEW
  final double discountAmount;        // ✅ NEW
  final double deliveryCharges;
  final double codCharges;
  final double totalAmount;           // ✅ NEW
  final bool isDiscountAvailed;       // ✅ NEW
  final String? discountType;         // ✅ NEW
  final String? couponCode;
  final int loyaltyPointsUsed;
}
```

## Files Modified

### Domain Layer
1. ✅ `lib/features/payment/domain/entities/order_entity.dart`
   - Updated `OrderEntity` with new fields
   - Updated `OrderItem` with new fields and type changes

2. ✅ `lib/features/payment/domain/repositories/payment_repository.dart`
   - Updated `createOrder` method signature

### Data Layer
3. ✅ `lib/features/payment/data/models/order_model.dart`
   - Updated to support new fields
   - Updated JSON serialization/deserialization

4. ✅ `lib/features/payment/data/datasources/payment_remote_data_source.dart`
   - Updated interface with new parameters

5. ✅ `lib/features/payment/data/datasources/payment_remote_data_source_impl.dart`
   - Updated implementation to send new required fields

6. ✅ `lib/features/payment/data/repositories/payment_repository_impl.dart`
   - Updated to pass new parameters

### Presentation Layer
7. ✅ `lib/features/payment/presentation/bloc/payment_event.dart`
   - Updated `CreateOrder` event with new fields

8. ✅ `lib/features/payment/presentation/bloc/payment_bloc.dart`
   - Updated `_onCreateOrder` to pass new parameters

## Migration Checklist for Frontend Developers

When implementing the payment flow in your UI, you MUST:

### ✅ Step 1: Calculate Order Summary (Frontend)
```dart
// Example calculation logic
double calculateSubtotal(List<CartItem> cartItems) {
  return cartItems.fold(0.0, (sum, item) => 
    sum + (item.weightInKg * item.pricePerKg)
  );
}

double calculateDiscount({
  required double subtotal,
  String? couponCode,
  int loyaltyPointsUsed = 0,
  double pointValue = 1.0,
}) {
  if (loyaltyPointsUsed > 0) {
    return loyaltyPointsUsed * pointValue;
  } else if (couponCode != null) {
    // Apply coupon logic (you might need to call coupon API first)
    return 0.0; // Replace with actual coupon discount
  }
  return 0.0;
}

double calculateTotal({
  required double subtotal,
  required double discount,
  required double deliveryCharges,
  required double codCharges,
}) {
  return subtotal - discount + deliveryCharges + codCharges;
}
```

### ✅ Step 2: Prepare OrderItem with Complete Data
```dart
// Each cart item must be converted to OrderItem with all fields
final orderItems = cartItems.map((cartItem) => OrderItem(
  id: cartItem.productId,
  type: cartItem.type, // "Product" or "Blend"
  quantity: cartItem.quantity,
  weightInKg: cartItem.weightInKg,      // Must be double
  pricePerKg: cartItem.pricePerKg,      // Required
  totalPrice: cartItem.weightInKg * cartItem.pricePerKg, // Required
)).toList();
```

### ✅ Step 3: Dispatch CreateOrder Event
```dart
context.read<PaymentBloc>().add(
  CreateOrder(
    items: orderItems,
    deliveryAddress: selectedAddressId,
    contactNumbers: [userPhone],
    paymentMethod: selectedPaymentMethod,
    subtotal: subtotal,                    // Pre-calculated
    discountAmount: discountAmount,        // Pre-calculated
    deliveryCharges: deliveryCharges,
    codCharges: codCharges,
    totalAmount: totalAmount,              // Pre-calculated
    isDiscountAvailed: discountAmount > 0,
    discountType: discountType,            // "loyalty", "coupon", or null
    couponCode: couponCode,
    loyaltyPointsUsed: loyaltyPointsUsed,
  ),
);
```

## Important Notes

### 🚨 Breaking Changes
1. **OrderItem structure changed** - Frontend must provide `weightInKg` (double), `pricePerKg`, and `totalPrice`
2. **Create order requires pre-calculated values** - Backend no longer calculates subtotal/total
3. **New required parameters** - Must pass `subtotal`, `discountAmount`, `totalAmount`, `isDiscountAvailed`, `discountType`

### 💡 Loyalty Points Logic
The backend implements smart logic to prevent double-dipping:

| Discount Type | Points Deducted | Bonus Points Awarded | Reason |
|---------------|----------------|---------------------|---------|
| **Loyalty** | ✅ Yes (used points) | ❌ NO | Already got benefit |
| **Coupon** | ❌ No | ✅ YES | Coupon is separate from loyalty |
| **None** | ❌ No | ✅ YES | Normal reward for purchase |

### 🔍 Validation
Backend will validate:
- All items exist in database
- User has sufficient loyalty points (if using loyalty discount)
- Coupon is valid and active (if using coupon)
- All required fields are present
- `discount_type` matches the discount source

## Testing Recommendations

1. **Test with loyalty points discount**
   - Verify points are deducted after payment
   - Verify NO bonus points are awarded

2. **Test with coupon discount**
   - Verify coupon usage is recorded
   - Verify bonus points ARE awarded

3. **Test without discount**
   - Verify bonus points ARE awarded

4. **Test COD orders**
   - Verify COD charges are included in total
   - Verify order can be confirmed

5. **Test Razorpay payments**
   - Verify payment signature is validated
   - Verify order is updated after verification

## API Documentation Reference

For complete API details, see: `DOCS/PAYMENT_SYSTEM_API_DOCS.md`

## Migration Status

✅ **COMPLETED** - All domain, data, and presentation layers have been refactored to support Payment API V2.0

## Next Steps for UI Implementation

1. Update cart page to calculate all order summary values
2. Update checkout page to pass pre-calculated values to payment bloc
3. Test order creation with different discount scenarios
4. Test payment verification flow
5. Test COD confirmation flow

---

**Date:** October 10, 2025  
**API Version:** 2.0  
**Migration Completed By:** AI Assistant
