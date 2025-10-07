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
      "quantity": 2.5
    },
    {
      "item_type": "Blend",
      "item": "507f1f77bcf86cd799439012",
      "quantity": 1.0
    }
  ],
  "delivery_address": "507f1f77bcf86cd799439013",
  "contact_numbers": ["+91-9876543210"],
  "payment_method": "Razorpay",
  "coupon_code": "WELCOME10",
  "loyalty_points_used": 0,
  "delivery_charges": 50,
  "cod_charges": 0
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| items | Array | Yes | Array of order items (1-10 items) |
| items[].item_type | String | Yes | "Product" or "Blend" |
| items[].item | ObjectId | Yes | Product/Blend ID |
| items[].quantity | Number | Yes | Quantity in kg (> 0) |
| delivery_address | ObjectId | Yes | User's address ID |
| contact_numbers | Array | Yes | 1-2 phone numbers |
| payment_method | String | Yes | "Razorpay", "COD", "UPI", "Card", "Wallet" |
| coupon_code | String | No | Coupon code (mutually exclusive with loyalty_points_used) |
| loyalty_points_used | Number | No | Points to redeem (mutually exclusive with coupon_code) |
| delivery_charges | Number | No | Delivery charges amount (default: 0) |
| cod_charges | Number | No | COD charges (only for COD orders, default: 0) |

#### Validation Rules
- Cannot use both `coupon_code` and `loyalty_points_used` together
- User must have sufficient loyalty points if redeeming
- Coupon must be valid and applicable to order
- All items must exist in database
- `cod_charges` are automatically applied only when `payment_method` is "COD"

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
      "subtotal": 500,
      "discount_amount": 50,
      "loyalty_discount_amount": 0,
      "delivery_charges": 50,
      "cod_charges": 0,
      "total_amount": 500,
      "items": [...],
      "created_at": "2025-10-08T10:30:00.000Z"
    },
    "razorpay": {
      "order_id": "order_MtxVHqz9v8V1Gg",
      "amount": 45000,
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
      "subtotal": 500,
      "discount_amount": 50,
      "delivery_charges": 50,
      "cod_charges": 20,
      "total_amount": 520,
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
  "message": "Cannot use both coupon and loyalty points on the same order"
}
```

```json
{
  "success": false,
  "message": "Insufficient loyalty points"
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
    "subtotal": 500,
    "discount_amount": 50,
    "loyalty_discount_amount": 0,
    "loyalty_points_used": 0,
    "delivery_charges": 50,
    "cod_charges": 0,
    "total_amount": 500,
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
    "subtotal": 500,
    "discount_amount": 50,
    "delivery_charges": 50,
    "cod_charges": 20,
    "total_amount": 520,
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

### Step 1: Create Order
```javascript
// Create order on backend
const createOrder = async (orderData) => {
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

### Step 2: Initialize Razorpay (for online payments)
```javascript
// Initialize Razorpay checkout
const initiatePayment = async (orderData) => {
  // First create order
  const { order, razorpay } = await createOrder(orderData);
  
  if (orderData.payment_method === 'COD') {
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

### Step 3: Verify Payment
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

### Step 4: Handle COD Orders
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

```
Subtotal                    : ₹500
- Coupon Discount          : -₹50
- Loyalty Points Discount  : -₹0
= Amount After Discount    : ₹450
+ Delivery Charges         : ₹50
+ COD Charges (if COD)     : ₹20
= Total Amount             : ₹520
```

**Note**: COD charges are automatically added only when `payment_method` is `"COD"`. For online payments, `cod_charges` will be 0.

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

## Important Notes

1. **Coupon vs Loyalty Points**: Users can only apply ONE discount type per order (either coupon OR loyalty points, not both)

2. **Payment Verification**: Always verify payment on backend before marking order as complete

3. **Signature Verification**: Critical for security - never skip signature verification

4. **Transaction Safety**: All payment operations use MongoDB transactions to ensure data consistency

5. **Loyalty Points**: 
   - Points are deducted ONLY after payment verification
   - Order completion points are awarded AFTER payment verification
   - Points redemption is recorded in LoyaltyTransaction model

6. **Coupon Usage**: 
   - Coupon usage is recorded ONLY after payment verification
   - Usage count is incremented to prevent reuse

7. **Error Handling**: 
   - If coupon/loyalty processing fails, the order still completes
   - Errors are logged but don't fail the transaction
   - User notification should still be sent

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

## Support

For payment-related issues:
1. Check order status in database
2. Verify Razorpay dashboard for payment status
3. Check application logs for detailed error messages
4. Contact Razorpay support for gateway issues
