# Payment System API Documentation - Razorpay Integration

## Overview
This document describes the complete payment flow for the One Atta application using Razorpay payment gateway. The system supports both online payments (UPI, Card, Wallet) and Cash on Delivery (COD).

## Payment Flow Architecture

### Online Payment Flow (Razorpay)
```
Frontend → Create Order API → Razorpay Order Created → DB Order (payment_pending)
    ↓
User completes payment on Razorpay
    ↓
Frontend → Verify Payment API → Signature Verified → Order Updated (payment_completed)
    ↓
Coupon/Loyalty Processing → User Notification
```

### COD Payment Flow
```
Frontend → Create Order API → DB Order (payment_pending, COD)
    ↓
Frontend → Confirm COD API → Loyalty/Coupon Processing → Order Confirmed
```

## Base URL
```
/api/app/payments
```

## Authentication
All endpoints require JWT authentication:
```
Authorization: Bearer <jwt_token>
```

---

## API Endpoints

### 1. Create Payment Order
**POST** `/api/app/payments/create-order`

Creates a new order and initializes Razorpay payment for online orders.

#### Request Body
```json
{
  "items": [
    {
      "item_type": "Product",
      "item": "507f1f77bcf86cd799439011",
      "quantity": 2,
      "weight_in_kg": 2.5,
      "price_per_kg": 200,
      "total_price": 500
    },
    {
      "item_type": "Blend",
      "item": "507f1f77bcf86cd799439012",
      "quantity": 1,
      "weight_in_kg": 1.0,
      "price_per_kg": 250,
      "total_price": 250
    }
  ],
  "delivery_address": "507f1f77bcf86cd799439013",
  "contact_numbers": ["+91-9876543210"],
  "payment_method": "Razorpay",
  "subtotal": 750,
  "discount_amount": 75,
  "delivery_charges": 50,
  "cod_charges": 0,
  "total_amount": 725,
  "is_discount_availed": true,
  "discount_type": "coupon",
  "coupon_code": "WELCOME10",
  "loyalty_points_used": 0
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| items | Array | Yes | Array of order items (pre-calculated from frontend) |
| items[].item_type | String | Yes | "Product" or "Blend" |
| items[].item | ObjectId | Yes | Product/Blend ID |
| items[].quantity | Number | Yes | Quantity count (> 0) |
| items[].weight_in_kg | Number | Yes | **NEW** Weight in kilograms (> 0) |
| items[].price_per_kg | Number | Yes | Price per kg (> 0) |
| items[].total_price | Number | Yes | Total price for this item (> 0) |
| delivery_address | ObjectId | Yes | User's address ID |
| contact_numbers | Array | Yes | 1-2 phone numbers |
| payment_method | String | Yes | "Razorpay", "COD", "UPI", "Card", "Wallet" |
| subtotal | Number | Yes | **NEW** Pre-calculated subtotal from frontend |
| discount_amount | Number | No | **NEW** Pre-calculated discount (default: 0) |
| delivery_charges | Number | No | **NEW** Pre-calculated delivery charges (default: 0) |
| cod_charges | Number | No | **NEW** Pre-calculated COD charges (default: 0) |
| total_amount | Number | Yes | **NEW** Pre-calculated final amount to pay |
| is_discount_availed | Boolean | No | **NEW** Whether discount was applied (default: false) |
| discount_type | String | No | **NEW** "loyalty" or "coupon" or null |
| coupon_code | String | No | Coupon code (only if discount_type is "coupon") |
| loyalty_points_used | Number | No | Points to redeem (only if discount_type is "loyalty") |

#### Validation Rules
- **All calculations done on frontend** - backend only validates
- `weight_in_kg` is **required** for each item
- `subtotal` and `total_amount` are **required**
- If `is_discount_availed` is true, `discount_type` must be specified
- If `discount_type` is "coupon", `coupon_code` must be provided
- If `discount_type` is "loyalty", `loyalty_points_used` must be > 0
- User must have sufficient loyalty points if `discount_type` is "loyalty"
- Coupon must be valid and active if `discount_type` is "coupon"
- All items must exist in database

#### Success Response (Razorpay Payment)
```json
{
  "success": true,
  "message": "Order created. Please complete payment",
  "data": {
    "order": {
      "_id": "507f1f77bcf86cd799439014",
      "status": "pending",
      "payment_status": "pending",
      "subtotal": 750,
      "discount_amount": 75,
      "is_discount_availed": true,
      "discount_type": "coupon",
      "delivery_charges": 50,
      "cod_charges": 0,
      "total_amount": 725,
      "items": [
        {
          "item_type": "Product",
          "item": "507f1f77bcf86cd799439011",
          "quantity": 2,
          "weight_in_kg": 2.5,
          "price_per_kg": 200,
          "total_price": 500
        }
      ],
      "created_at": "2025-10-08T10:30:00.000Z"
    },
    "razorpay": {
      "order_id": "order_MtxVHqz9v8V1Gg",
      "amount": 72500,
      "currency": "INR",
      "key_id": "rzp_test_xxxxxxxxxxxxx"
    }
  }
}
```

#### Success Response (COD)
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order": {
      "_id": "507f1f77bcf86cd799439014",
      "status": "pending",
      "payment_status": "pending",
      "subtotal": 750,
      "discount_amount": 0,
      "is_discount_availed": false,
      "discount_type": null,
      "delivery_charges": 50,
      "cod_charges": 20,
      "total_amount": 820,
      "items": [...],
      "created_at": "2025-10-08T10:30:00.000Z"
    },
    "razorpay": null
  }
}
```

#### Error Responses
```json
{
  "success": false,
  "message": "weight_in_kg is required for each item"
}
```

```json
{
  "success": false,
  "message": "Subtotal and total amount are required"
}
```

```json
{
  "success": false,
  "message": "Insufficient loyalty points"
}
```

```json
{
  "success": false,
  "message": "Invalid coupon code"
}
```

---

### 2. Verify Payment
**POST** `/api/app/payments/verify`

Verifies Razorpay payment signature and completes the order.

#### Request Body
```json
{
  "order_id": "507f1f77bcf86cd799439014",
  "razorpay_order_id": "order_MtxVHqz9v8V1Gg",
  "razorpay_payment_id": "pay_MtxWKzJP2KLy9E",
  "razorpay_signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d"
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| order_id | String | Yes | Database order ID |
| razorpay_order_id | String | Yes | Razorpay order ID |
| razorpay_payment_id | String | Yes | Razorpay payment ID |
| razorpay_signature | String | Yes | Payment signature from Razorpay |

#### Success Response
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "user_id": {
      "_id": "507f1f77bcf86cd799439010",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+91-9876543210"
    },
    "items": [...],
    "status": "pending",
    "payment_status": "completed",
    "payment_verified": true,
    "payment_completed_at": "2025-10-08T10:35:00.000Z",
    "payment_method": "Razorpay",
    "actual_payment_method": "UPI",
    "razorpay_order_id": "order_MtxVHqz9v8V1Gg",
    "razorpay_payment_id": "pay_MtxWKzJP2KLy9E",
    "delivery_address": {...},
    "subtotal": 750,
    "discount_amount": 75,
    "is_discount_availed": true,
    "discount_type": "coupon",
    "loyalty_discount_amount": 0,
    "loyalty_points_used": 0,
    "delivery_charges": 50,
    "cod_charges": 0,
    "total_amount": 725,
    "created_at": "2025-10-08T10:30:00.000Z"
  }
}
```

#### Error Responses
```json
{
  "success": false,
  "message": "Invalid payment signature"
}
```

```json
{
  "success": false,
  "message": "Payment already verified for this order"
}
```

---

### 3. Confirm COD Order
**POST** `/api/app/payments/confirm-cod/:orderId`

Confirms a Cash on Delivery order and processes loyalty/coupon.

#### URL Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| orderId | String | Database order ID |

#### Success Response
```json
{
  "success": true,
  "message": "COD order confirmed successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "user_id": {...},
    "items": [...],
    "status": "pending",
    "payment_method": "COD",
    "payment_status": "pending",
    "delivery_address": {...},
    "subtotal": 750,
    "discount_amount": 0,
    "is_discount_availed": false,
    "discount_type": null,
    "delivery_charges": 50,
    "cod_charges": 20,
    "total_amount": 820,
    "created_at": "2025-10-08T10:30:00.000Z"
  }
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Order not found"
}
```

---

### 4. Handle Payment Failure
**POST** `/api/app/payments/failure`

Records payment failure details.

#### Request Body
```json
{
  "order_id": "507f1f77bcf86cd799439014",
  "razorpay_payment_id": "pay_MtxWKzJP2KLy9E",
  "error": {
    "code": "BAD_REQUEST_ERROR",
    "description": "Payment failed due to insufficient funds",
    "source": "customer",
    "step": "payment_authentication",
    "reason": "payment_failed"
  }
}
```

#### Success Response
```json
{
  "success": true,
  "message": "Payment failure recorded",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "payment_status": "failed",
    "payment_failure_reason": "Payment failed due to insufficient funds",
    ...
  }
}
```

---

## Frontend Integration Guide

### Step 1: Calculate Order Summary (Frontend)
```javascript
// Calculate order summary on frontend
const calculateOrderSummary = (items, appliedDiscount, deliveryInfo, paymentMethod) => {
  // Calculate subtotal
  const subtotal = items.reduce((sum, item) => {
    return sum + (item.weight_in_kg * item.price_per_kg);
  }, 0);
  
  // Calculate discount
  let discountAmount = 0;
  let isDiscountAvailed = false;
  let discountType = null;
  let loyaltyPointsUsed = 0;
  let couponCode = null;
  
  if (appliedDiscount.type === 'loyalty') {
    discountAmount = appliedDiscount.pointsUsed * appliedDiscount.pointValue;
    isDiscountAvailed = true;
    discountType = 'loyalty';
    loyaltyPointsUsed = appliedDiscount.pointsUsed;
  } else if (appliedDiscount.type === 'coupon') {
    discountAmount = appliedDiscount.discount; // From coupon calculation
    isDiscountAvailed = true;
    discountType = 'coupon';
    couponCode = appliedDiscount.code;
  }
  
  // Calculate charges
  const deliveryCharges = deliveryInfo.charges || 0;
  const codCharges = (paymentMethod === 'COD') ? 20 : 0; // Example: ₹20 for COD
  
  // Calculate total
  const totalAmount = subtotal - discountAmount + deliveryCharges + codCharges;
  
  return {
    subtotal,
    discountAmount,
    deliveryCharges,
    codCharges,
    totalAmount,
    isDiscountAvailed,
    discountType,
    loyaltyPointsUsed,
    couponCode
  };
};
```

### Step 2: Create Order
```javascript
// Create order on backend with pre-calculated values
const createOrder = async (items, orderSummary, addressId, contactNumbers, paymentMethod) => {
  const orderData = {
    items: items.map(item => ({
      item_type: item.type,
      item: item.id,
      quantity: item.quantity,
      weight_in_kg: item.weight_in_kg,
      price_per_kg: item.price_per_kg,
      total_price: item.weight_in_kg * item.price_per_kg
    })),
    delivery_address: addressId,
    contact_numbers: contactNumbers,
    payment_method: paymentMethod,
    subtotal: orderSummary.subtotal,
    discount_amount: orderSummary.discountAmount,
    delivery_charges: orderSummary.deliveryCharges,
    cod_charges: orderSummary.codCharges,
    total_amount: orderSummary.totalAmount,
    is_discount_availed: orderSummary.isDiscountAvailed,
    discount_type: orderSummary.discountType,
    coupon_code: orderSummary.couponCode,
    loyalty_points_used: orderSummary.loyaltyPointsUsed
  };
  
  const response = await fetch('/api/app/payments/create-order', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(orderData)
  });
  
  const result = await response.json();
  return result.data;
};
```

### Step 3: Initialize Razorpay (for online payments)
```javascript
// Initialize Razorpay checkout
const initiatePayment = async (items, orderSummary, addressId, contactNumbers, paymentMethod) => {
  // First create order with pre-calculated values
  const { order, razorpay } = await createOrder(items, orderSummary, addressId, contactNumbers, paymentMethod);
  
  if (paymentMethod === 'COD') {
    // For COD, confirm order directly
    await confirmCODOrder(order._id);
    return { success: true, order };
  }
  
  // For Razorpay payments
  const options = {
    key: razorpay.key_id,
    amount: razorpay.amount,
    currency: razorpay.currency,
    name: 'One Atta',
    description: 'Order Payment',
    order_id: razorpay.order_id,
    handler: async function (response) {
      // Verify payment on backend
      await verifyPayment({
        order_id: order._id,
        razorpay_order_id: response.razorpay_order_id,
        razorpay_payment_id: response.razorpay_payment_id,
        razorpay_signature: response.razorpay_signature
      });
    },
    prefill: {
      name: user.name,
      email: user.email,
      contact: user.mobile
    },
    theme: {
      color: '#F37254'
    }
  };
  
  const razorpayInstance = new Razorpay(options);
  razorpayInstance.open();
};
```

### Step 4: Verify Payment
```javascript
const verifyPayment = async (paymentData) => {
  const response = await fetch('/api/app/payments/verify', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(paymentData)
  });
  
  const result = await response.json();
  
  if (result.success) {
    // Show success message and redirect to order details
    console.log('Payment successful!', result.data);
  } else {
    // Show error message
    console.error('Payment verification failed:', result.message);
  }
};
```

### Step 5: Handle COD Orders
```javascript
const confirmCODOrder = async (orderId) => {
  const response = await fetch(`/api/app/payments/confirm-cod/${orderId}`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  const result = await response.json();
  return result.data;
};
```

---

## Payment Method Tracking

### Payment Method vs Actual Payment Method

The system tracks two payment method fields:

1. **`payment_method`** - The gateway/method chosen during order creation:
   - `"Razorpay"` - For online payments through Razorpay
   - `"COD"` - For Cash on Delivery
   - `"UPI"`, `"Card"`, `"Wallet"` - Direct methods (if not using Razorpay)

2. **`actual_payment_method`** - The actual payment method used (captured after payment):
   - `"UPI"` - User paid via UPI (Google Pay, PhonePe, etc.)
   - `"Card"` - User paid via Credit/Debit Card
   - `"Wallet"` - User paid via Wallet (Paytm, etc.)
   - `"NetBanking"` - User paid via Net Banking
   - `"COD"` - Cash on Delivery
   - `null` - Not yet determined (payment pending)

### How It Works

When a user selects **Razorpay** as `payment_method`:
1. Order is created with `payment_method: "Razorpay"` and `actual_payment_method: null`
2. User completes payment on Razorpay checkout (chooses UPI, Card, etc.)
3. After verification, `actual_payment_method` is updated with the method user actually used

For **COD** orders:
- Both `payment_method` and `actual_payment_method` are set to `"COD"`

### Pricing Breakdown

**All calculations done on frontend:**

```
Subtotal (Sum of all items)           : ₹750
- Discount (Coupon or Loyalty)        : -₹75
= Amount After Discount               : ₹675
+ Delivery Charges                    : ₹50
+ COD Charges (if COD)                : ₹20
= Total Amount (to pay)               : ₹745
```

**Important Notes**: 
- Frontend calculates all values and sends to backend
- Backend only validates and stores the values
- COD charges should be added by frontend only when `payment_method` is `"COD"`
- Backend validates coupon/loyalty but doesn't recalculate discount

---

## Environment Variables

Add these to your `.env` file:

```bash
# Razorpay Configuration
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your_secret_key_here
```

---

## Payment Status Flow

### Order Status
- `pending` - Order created, waiting for admin approval
- `accepted` - Admin accepted the order
- `processing` - Order is being prepared
- `shipped` - Order shipped
- `delivered` - Order delivered
- `cancelled` - Order cancelled
- `rejected` - Admin rejected the order

### Payment Status
- `pending` - Payment not completed yet
- `completed` - Payment successfully completed and verified
- `failed` - Payment failed
- `refunded` - Payment refunded

---

## Order Processing Timeline

1. **Order Created** - Order status: `pending`, Payment status: `pending`
2. **Payment Completed** (for online) - Payment status: `completed`, Order status: `pending`
3. **COD Confirmed** (for COD) - Order status: `pending`
4. **Admin Reviews** - Order status changes to `accepted` or `rejected`
5. **Order Processing** - Order status: `processing`
6. **Shipment Created** - Order status: `shipped`
7. **Delivery** - Order status: `delivered`

---

## Loyalty Points Logic (IMPORTANT)

### Understanding Discount Types and Bonus Points

The system now implements a **smart loyalty points system** that prevents double-dipping:

#### Scenario 1: User Uses Loyalty Points for Discount ❌ No Bonus
```javascript
// Order Request
{
  "discount_amount": 50,
  "is_discount_availed": true,
  "discount_type": "loyalty",
  "loyalty_points_used": 50,
  "total_amount": 700
}

// What Happens After Payment:
✅ Deduct 50 loyalty points from user
❌ NO bonus points awarded (user already got benefit)
```

**Reason**: User already used loyalty points to get discount. If we give bonus points back, they're essentially getting a discount for free!

#### Scenario 2: User Uses Coupon for Discount ✅ Gets Bonus
```javascript
// Order Request
{
  "discount_amount": 50,
  "is_discount_availed": true,
  "discount_type": "coupon",
  "coupon_code": "SAVE50",
  "total_amount": 700
}

// What Happens After Payment:
✅ Record coupon usage
✅ Award bonus loyalty points based on total_amount
   Example: ₹700 × 2% = 14 points
```

**Reason**: User used external coupon (marketing promo). They should still earn loyalty points for the purchase!

#### Scenario 3: User Orders Without Discount ✅ Gets Bonus
```javascript
// Order Request
{
  "discount_amount": 0,
  "is_discount_availed": false,
  "discount_type": null,
  "total_amount": 750
}

// What Happens After Payment:
✅ Award bonus loyalty points based on total_amount
   Example: ₹750 × 2% = 15 points
```

**Reason**: Normal purchase, user deserves loyalty points!

### Summary Table

| Discount Type | Points Deducted | Bonus Points Awarded | Logic |
|---------------|----------------|---------------------|--------|
| **Loyalty** | Yes (used points) | ❌ NO | Already got benefit |
| **Coupon** | No | ✅ YES | Coupon is separate from loyalty |
| **None** | No | ✅ YES | Normal reward for purchase |

### Implementation in Code

The backend automatically handles this logic:

```javascript
// In verifyAndCompletePaymentService and confirmCODOrderService

// 1. Deduct points if loyalty was used
if (order.discount_type === 'loyalty' && order.loyalty_points_used > 0) {
  await User.findByIdAndUpdate(userId, { 
    $inc: { loyalty_points: -order.loyalty_points_used } 
  });
}

// 2. Award bonus points ONLY if discount wasn't from loyalty
if (!order.is_discount_availed || order.discount_type === 'coupon') {
  await earnPointsForOrder({
    amount: order.total_amount,
    orderId: order._id
  });
}
```

---

## Important Notes

1. **Coupon vs Loyalty Points**: Users can only apply ONE discount type per order (either coupon OR loyalty points, not both)

2. **Frontend Calculations**: All order summary calculations (subtotal, discount, charges, total) are done on frontend. Backend only validates and stores.

3. **Payment Verification**: Always verify payment on backend before marking order as complete

4. **Signature Verification**: Critical for security - never skip signature verification

5. **Transaction Safety**: All payment operations use MongoDB transactions to ensure data consistency

6. **Loyalty Points Logic** (NEW): 
   - Points are deducted ONLY after payment verification
   - Bonus points awarded ONLY if discount wasn't from loyalty points
   - If user used loyalty discount → NO bonus points
   - If user used coupon OR no discount → GIVE bonus points
   - Points redemption is recorded in LoyaltyTransaction model

7. **Coupon Usage**: 
   - Coupon usage is recorded ONLY after payment verification
   - Usage count is incremented to prevent reuse

8. **Error Handling**: 
   - If coupon/loyalty processing fails, the order still completes
   - Errors are logged but don't fail the transaction
   - User notification should still be sent

9. **Weight in KG** (NEW):
   - Each order item must include `weight_in_kg` field
   - Used for accurate tracking and inventory management
   - Frontend calculates based on quantity and product weight

---

## Testing

### Test Mode
Use Razorpay test mode credentials for development:
- Test Key ID: `rzp_test_xxxxxxxxxxxxx`
- Test Key Secret: `your_test_secret`

### Test Cards
```
Card Number: 4111 1111 1111 1111
CVV: Any 3 digits
Expiry: Any future date
```

### Testing COD
Simply set `payment_method` to "COD" and confirm the order after creation.

---

## Security Considerations

1. **Never expose** Razorpay Key Secret to frontend
2. **Always verify** payment signature on backend
3. **Use HTTPS** in production
4. **Validate** all user inputs
5. **Log** all payment transactions for audit
6. **Implement** rate limiting on payment endpoints
7. **Monitor** for suspicious payment patterns

---

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Invalid payment signature | Signature verification failed |
| 400 | Cannot use both coupon and loyalty points | User tried to use both discounts |
| 400 | Insufficient loyalty points | User doesn't have enough points |
| 404 | Order not found | Order ID doesn't exist |
| 409 | Payment already verified | Duplicate verification attempt |
| 500 | Failed to create Razorpay order | Razorpay API error |

---

## Complete Example Flows

### Example 1: Order with Loyalty Points Discount

**Step 1: Frontend Calculates**
```javascript
const cart = [
  { item_type: "Product", item: "prod123", weight_in_kg: 2, price_per_kg: 200 }
];
const subtotal = 400; // 2kg × ₹200
const loyaltyPointsUsed = 50; // User wants to use 50 points
const pointValue = 1; // 1 point = ₹1
const discountAmount = 50; // 50 points × ₹1
const deliveryCharges = 40;
const totalAmount = 400 - 50 + 40; // ₹390
```

**Step 2: Create Order**
```json
POST /api/app/payments/create-order
{
  "items": [{
    "item_type": "Product",
    "item": "prod123",
    "quantity": 2,
    "weight_in_kg": 2,
    "price_per_kg": 200,
    "total_price": 400
  }],
  "subtotal": 400,
  "discount_amount": 50,
  "is_discount_availed": true,
  "discount_type": "loyalty",
  "loyalty_points_used": 50,
  "delivery_charges": 40,
  "cod_charges": 0,
  "total_amount": 390,
  "payment_method": "Razorpay",
  "delivery_address": "addr123",
  "contact_numbers": ["+919876543210"]
}
```

**Step 3: After Payment Verification**
```
✅ Order created: ₹390 paid
✅ 50 loyalty points deducted from user
❌ NO bonus points awarded (user used loyalty discount)
📝 User loyalty balance: Previous balance - 50
```

---

### Example 2: Order with Coupon Discount

**Step 1: Frontend Calculates**
```javascript
const cart = [
  { item_type: "Blend", item: "blend456", weight_in_kg: 1.5, price_per_kg: 300 }
];
const subtotal = 450; // 1.5kg × ₹300
const couponDiscount = 45; // 10% off from coupon
const deliveryCharges = 40;
const totalAmount = 450 - 45 + 40; // ₹445
```

**Step 2: Create Order**
```json
POST /api/app/payments/create-order
{
  "items": [{
    "item_type": "Blend",
    "item": "blend456",
    "quantity": 1,
    "weight_in_kg": 1.5,
    "price_per_kg": 300,
    "total_price": 450
  }],
  "subtotal": 450,
  "discount_amount": 45,
  "is_discount_availed": true,
  "discount_type": "coupon",
  "coupon_code": "SAVE10",
  "delivery_charges": 40,
  "cod_charges": 0,
  "total_amount": 445,
  "payment_method": "Razorpay",
  "delivery_address": "addr123",
  "contact_numbers": ["+919876543210"]
}
```

**Step 3: After Payment Verification**
```
✅ Order created: ₹445 paid
✅ Coupon "SAVE10" usage recorded
✅ Bonus loyalty points awarded: ₹445 × 2% = 8 points
📝 User loyalty balance: Previous balance + 8
```

---

### Example 3: Order without Any Discount (COD)

**Step 1: Frontend Calculates**
```javascript
const cart = [
  { item_type: "Product", item: "prod789", weight_in_kg: 3, price_per_kg: 150 }
];
const subtotal = 450; // 3kg × ₹150
const deliveryCharges = 40;
const codCharges = 20; // COD fee
const totalAmount = 450 + 40 + 20; // ₹510
```

**Step 2: Create Order**
```json
POST /api/app/payments/create-order
{
  "items": [{
    "item_type": "Product",
    "item": "prod789",
    "quantity": 3,
    "weight_in_kg": 3,
    "price_per_kg": 150,
    "total_price": 450
  }],
  "subtotal": 450,
  "discount_amount": 0,
  "is_discount_availed": false,
  "discount_type": null,
  "delivery_charges": 40,
  "cod_charges": 20,
  "total_amount": 510,
  "payment_method": "COD",
  "delivery_address": "addr123",
  "contact_numbers": ["+919876543210"]
}
```

**Step 3: Confirm COD Order**
```json
POST /api/app/payments/confirm-cod/order_id_here
```

**Step 4: After COD Confirmation**
```
✅ COD Order confirmed: ₹510 to be collected
✅ Bonus loyalty points awarded: ₹510 × 2% = 10 points
📝 User loyalty balance: Previous balance + 10
```

---

## Support

For payment-related issues:
1. Check order status in database
2. Verify Razorpay dashboard for payment status
3. Check application logs for detailed error messages
4. Contact Razorpay support for gateway issues

---

## Changelog

### Version 2.0 (October 2025)
- ✅ **NEW**: Added `weight_in_kg` field to order items
- ✅ **NEW**: Added `is_discount_availed` and `discount_type` fields
- ✅ **CHANGED**: All calculations now done on frontend
- ✅ **CHANGED**: Backend accepts pre-calculated values (subtotal, discount, charges, total)
- ✅ **IMPROVED**: Loyalty points logic - no bonus if discount from loyalty
- ✅ **IMPROVED**: Clear separation between loyalty and coupon discounts
- 🔄 **BREAKING**: Request body structure changed - requires frontend updates

### Version 1.0 (Previous)
- Backend calculated all order values
- Simple loyalty points deduction and earning
