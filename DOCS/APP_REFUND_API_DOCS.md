# App Refund API Documentation

## Overview
User-facing API endpoints for viewing refund status and details. All endpoints require user authentication.

**Base URL:** `/refunds`

**Authentication:** Required - Bearer token in Authorization header

---

## Endpoints

### 1. Get All User Refunds

Get all refunds for the authenticated user.

**Endpoint:** `GET /refunds/my-refunds`

**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:** None

**Response:**

**Success (200 OK):**
```json
{
  "success": true,
  "message": "Refunds retrieved successfully",
  "data": [
    {
      "_id": "673abc123def456789012345",
      "order_id": {
        "_id": "673abc123def456789012344",
        "razorpay_order_id": "order_MhzXYZ123456",
        "total_amount": 1500,
        "created_at": "2025-11-15T10:30:00.000Z",
        "status": "cancelled"
      },
      "user_id": "673abc123def456789012343",
      "amount": 1500,
      "status": "pending",
      "refund_method": "original_payment_method",
      "original_payment_method": "UPI",
      "razorpay_payment_id": "pay_MhzXYZ123456",
      "razorpay_refund_id": null,
      "cancellation_reason": "Changed my mind",
      "admin_notes": null,
      "processed_by": null,
      "processed_at": null,
      "completed_at": null,
      "failure_reason": null,
      "transaction_reference": null,
      "loyalty_points_reversed": 15,
      "loyalty_points_redeemed_refunded": 100,
      "created_at": "2025-11-16T08:20:00.000Z",
      "updated_at": "2025-11-16T08:20:00.000Z"
    },
    {
      "_id": "673abc123def456789012346",
      "order_id": {
        "_id": "673abc123def456789012347",
        "razorpay_order_id": "order_NjxYZ123457",
        "total_amount": 2500,
        "created_at": "2025-11-10T14:15:00.000Z",
        "status": "rejected"
      },
      "user_id": "673abc123def456789012343",
      "amount": 2500,
      "status": "completed",
      "refund_method": "original_payment_method",
      "original_payment_method": "Card",
      "razorpay_payment_id": "pay_NjxYZ123457",
      "razorpay_refund_id": "rfnd_KjxYZ123458",
      "cancellation_reason": "Order rejected by admin. Reason: Out of stock",
      "admin_notes": "Processed via Razorpay",
      "processed_by": "673abc123def456789012350",
      "processed_at": "2025-11-11T09:00:00.000Z",
      "completed_at": "2025-11-11T09:30:00.000Z",
      "transaction_reference": "TXN123456789",
      "loyalty_points_reversed": 25,
      "loyalty_points_redeemed_refunded": 0,
      "created_at": "2025-11-10T14:20:00.000Z",
      "updated_at": "2025-11-11T09:30:00.000Z"
    }
  ]
}
```

**Error Responses:**

**Unauthorized (401):**
```json
{
  "success": false,
  "message": "Not authorized, token required"
}
```

---

### 2. Get Specific Refund by ID

Get details of a specific refund by its ID.

**Endpoint:** `GET /refunds/:id`

**Authentication:** Required (must be the refund owner)

**Request Headers:**
```
Authorization: Bearer <token>
```

**URL Parameters:**
- `id` (required) - Refund ID

**Response:**

**Success (200 OK):**
```json
{
  "success": true,
  "message": "Refund retrieved successfully",
  "data": {
    "_id": "673abc123def456789012345",
    "order_id": {
      "_id": "673abc123def456789012344",
      "razorpay_order_id": "order_MhzXYZ123456",
      "total_amount": 1500,
      "created_at": "2025-11-15T10:30:00.000Z",
      "status": "cancelled",
      "items": [
        {
          "item_type": "product",
          "item": "673abc123def456789012340",
          "quantity": 3,
          "weight_in_kg": 3,
          "price_per_kg": 500,
          "total_price": 1500
        }
      ]
    },
    "user_id": "673abc123def456789012343",
    "amount": 1500,
    "status": "processing",
    "refund_method": "original_payment_method",
    "original_payment_method": "UPI",
    "razorpay_payment_id": "pay_MhzXYZ123456",
    "razorpay_refund_id": null,
    "bank_details": null,
    "cancellation_reason": "Changed my mind",
    "admin_notes": "Processing via bank transfer",
    "processed_by": null,
    "processed_at": "2025-11-16T10:00:00.000Z",
    "completed_at": null,
    "failure_reason": null,
    "transaction_reference": null,
    "loyalty_points_reversed": 15,
    "loyalty_points_redeemed_refunded": 100,
    "created_at": "2025-11-16T08:20:00.000Z",
    "updated_at": "2025-11-16T10:00:00.000Z"
  }
}
```

**Error Responses:**

**Not Found (404):**
```json
{
  "success": false,
  "message": "Refund not found"
}
```

**Unauthorized (401):**
```json
{
  "success": false,
  "message": "Not authorized, token required"
}
```

---

### 3. Get Refund by Order ID

Get refund details for a specific order.

**Endpoint:** `GET /refunds/order/:orderId`

**Authentication:** Required (must be the order owner)

**Request Headers:**
```
Authorization: Bearer <token>
```

**URL Parameters:**
- `orderId` (required) - Order ID

**Response:**

**Success (200 OK):**
```json
{
  "success": true,
  "message": "Refund retrieved successfully",
  "data": {
    "_id": "673abc123def456789012345",
    "order_id": {
      "_id": "673abc123def456789012344",
      "razorpay_order_id": "order_MhzXYZ123456",
      "total_amount": 1500,
      "created_at": "2025-11-15T10:30:00.000Z",
      "status": "cancelled"
    },
    "user_id": "673abc123def456789012343",
    "amount": 1500,
    "status": "pending",
    "refund_method": "original_payment_method",
    "original_payment_method": "UPI",
    "razorpay_payment_id": "pay_MhzXYZ123456",
    "cancellation_reason": "Changed my mind",
    "loyalty_points_reversed": 15,
    "loyalty_points_redeemed_refunded": 100,
    "created_at": "2025-11-16T08:20:00.000Z",
    "updated_at": "2025-11-16T08:20:00.000Z"
  }
}
```

**Error Responses:**

**Not Found (404):**
```json
{
  "success": false,
  "message": "No refund found for this order"
}
```

**Unauthorized (401):**
```json
{
  "success": false,
  "message": "Not authorized, token required"
}
```

---

## Field Descriptions

### Refund Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `_id` | String | Unique refund identifier |
| `order_id` | Object/String | Associated order details or ID |
| `user_id` | String | User identifier |
| `amount` | Number | Refund amount in rupees |
| `status` | String | Refund status: `pending`, `processing`, `completed`, `failed`, `cancelled` |
| `refund_method` | String | Method of refund: `original_payment_method`, `wallet`, `bank_transfer`, `upi` |
| `original_payment_method` | String | Original payment method: `UPI`, `Card`, `Wallet`, `NetBanking`, `Razorpay` |
| `razorpay_payment_id` | String | Razorpay payment ID |
| `razorpay_refund_id` | String | Razorpay refund ID (when processed) |
| `bank_details` | Object | Bank account details (if applicable) |
| `cancellation_reason` | String | Reason for cancellation/rejection |
| `admin_notes` | String | Admin notes about refund processing |
| `processed_by` | String | Admin ID who processed the refund |
| `processed_at` | Date | When refund processing started |
| `completed_at` | Date | When refund was completed |
| `failure_reason` | String | Reason if refund failed |
| `transaction_reference` | String | Transaction reference number |
| `loyalty_points_reversed` | Number | Loyalty points that were reversed (earned points deducted) |
| `loyalty_points_redeemed_refunded` | Number | Loyalty points that were refunded (redeemed points returned) |
| `created_at` | Date | When refund was created |
| `updated_at` | Date | When refund was last updated |

---

## Refund Status Flow

```
pending → processing → completed
   ↓          ↓
   ↓       failed
   ↓
cancelled
```

### Status Descriptions

| Status | Description |
|--------|-------------|
| `pending` | Refund request created, awaiting admin processing |
| `processing` | Admin has started processing the refund |
| `completed` | Refund has been successfully completed |
| `failed` | Refund processing failed |
| `cancelled` | Refund request was cancelled |

---

## Usage Examples

### Example 1: Get All My Refunds

```bash
curl -X GET "https://api.oneatta.com/refunds/my-refunds" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Example 2: Get Specific Refund

```bash
curl -X GET "https://api.oneatta.com/refunds/673abc123def456789012345" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Example 3: Get Refund by Order

```bash
curl -X GET "https://api.oneatta.com/refunds/order/673abc123def456789012344" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Push Notifications

Users receive push notifications when:

1. **Refund Created** (Order cancelled/rejected)
   ```json
   {
     "title": "Order Cancelled",
     "body": "Your order #012345 has been cancelled. Refund of ₹1500 is being processed. 100 loyalty points have been refunded."
   }
   ```

2. **Refund Processing**
   ```json
   {
     "title": "Refund Processing",
     "body": "Your refund of ₹1500 is being processed."
   }
   ```

3. **Refund Completed**
   ```json
   {
     "title": "✅ Refund Completed",
     "body": "Your refund of ₹1500 has been completed successfully. Reference: TXN123456789"
   }
   ```

4. **Refund Failed**
   ```json
   {
     "title": "Refund Failed",
     "body": "Your refund of ₹1500 has failed. Please contact support."
   }
   ```

---

## Notes

- All refunds are read-only for users
- Users can only view their own refunds
- Refund records are automatically created when:
  - User cancels a prepaid order
  - Admin rejects a prepaid order
- COD orders do not generate refund records
- Loyalty points are automatically handled during order cancellation/rejection
- Users cannot directly request refunds - they must cancel the order
