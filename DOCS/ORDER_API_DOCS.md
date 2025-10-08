# Order API Documentation

## Overview
The Order API provides endpoints for users to view and track their orders. Order creation is handled through the Payment API.

**Base URL:** `/orders`

**Authentication:** All routes require authentication (JWT token)

---

## Endpoints

### 1. Get User Orders
Get all orders for the authenticated user (only orders with successful payments).

**Endpoint:** `GET /orders/my-orders`

**Authentication:** Required

**Query Parameters:** None

**Response:**
```json
{
  "success": true,
  "message": "User orders retrieved successfully",
  "data": [
    {
      "_id": "order_id",
      "user_id": "user_id",
      "items": [
        {
          "item_type": "Product",
          "item": {
            "_id": "product_id",
            "name": "Atta Premium",
            "sku": "ATT-PREM-001",
            "price_per_kg": 45
          },
          "quantity": 5,
          "price_per_kg": 45,
          "total_price": 225
        }
      ],
      "status": "processing",
      "delivery_address": {
        "_id": "address_id",
        "address_type": "Home",
        "house_no": "123",
        "street": "Main Street",
        "landmark": "Near Park",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001"
      },
      "contact_numbers": ["+919876543210"],
      "payment_method": "Razorpay",
      "payment_status": "completed",
      "payment_verified": true,
      "payment_completed_at": "2024-01-15T10:30:00.000Z",
      "razorpay_order_id": "order_xyz123",
      "razorpay_payment_id": "pay_abc456",
      "subtotal": 225,
      "coupon_applied": {
        "_id": "coupon_id",
        "code": "FIRSTORDER",
        "name": "First Order Discount",
        "discount_type": "percentage",
        "discount_value": 10
      },
      "coupon_code": "FIRSTORDER",
      "discount_amount": 22.5,
      "loyalty_points_used": 0,
      "loyalty_discount_amount": 0,
      "delivery_charges": 50,
      "cod_charges": 0,
      "total_amount": 252.5,
      "actual_payment_method": "UPI",
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

**Notes:**
- Only returns orders with `payment_status: 'completed'`
- Orders are sorted by creation date (newest first)
- Includes full item details, address, and coupon information

---

### 2. Get Order Details
Get details of a specific order.

**Endpoint:** `GET /orders/:id`

**Authentication:** Required

**URL Parameters:**
- `id` (string, required) - Order ID

**Response:**
```json
{
  "success": true,
  "message": "Order retrieved successfully",
  "data": {
    "_id": "order_id",
    "user_id": {
      "_id": "user_id",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "items": [
      {
        "item_type": "Blend",
        "item": {
          "_id": "blend_id",
          "name": "Multigrain Mix",
          "price_per_kg": 65
        },
        "quantity": 3,
        "price_per_kg": 65,
        "total_price": 195
      }
    ],
    "status": "delivered",
    "delivery_address": {
      "_id": "address_id",
      "address_type": "Home",
      "house_no": "123",
      "street": "Main Street",
      "city": "Mumbai",
      "state": "Maharashtra",
      "pincode": "400001"
    },
    "contact_numbers": ["+919876543210"],
    "payment_method": "Razorpay",
    "payment_status": "completed",
    "payment_verified": true,
    "subtotal": 195,
    "discount_amount": 0,
    "delivery_charges": 50,
    "total_amount": 245,
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-20T14:30:00.000Z"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Order not found",
  "error": "Order not found"
}
```

**Notes:**
- Only returns orders belonging to the authenticated user
- Returns 404 if order doesn't exist or doesn't belong to the user

---

### 3. Track Order
Get order tracking information with shipment details.

**Endpoint:** `GET /orders/:id/track`

**Authentication:** Required

**URL Parameters:**
- `id` (string, required) - Order ID

**Response:**
```json
{
  "success": true,
  "message": "Order tracking retrieved successfully",
  "data": {
    "order": {
      "order_id": "order_id",
      "status": "shipped",
      "payment_status": "completed",
      "payment_verified": true,
      "total_amount": 245,
      "items": [
        {
          "item_type": "Product",
          "item": {
            "_id": "product_id",
            "name": "Atta Premium",
            "sku": "ATT-PREM-001"
          },
          "quantity": 5,
          "price_per_kg": 45,
          "total_price": 225
        }
      ],
      "delivery_address": {
        "_id": "address_id",
        "address_type": "Home",
        "house_no": "123",
        "street": "Main Street",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001"
      },
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-16T09:00:00.000Z"
    },
    "shipment": {
      "awb_number": "AWB123456789",
      "courier_name": "BlueDart",
      "current_status": "IN_TRANSIT",
      "tracking_url": "https://tracking.shiprocket.com/AWB123456789",
      "expected_delivery_date": "2024-01-18T18:00:00.000Z",
      "actual_delivery_date": null,
      "pickup_scheduled_date": "2024-01-16T10:00:00.000Z",
      "status_history": [
        {
          "status": "PICKED_UP",
          "status_datetime": "2024-01-16T11:30:00.000Z",
          "location": "Mumbai Hub",
          "remarks": "Shipment picked up successfully"
        },
        {
          "status": "IN_TRANSIT",
          "status_datetime": "2024-01-16T18:00:00.000Z",
          "location": "Mumbai Sorting Center",
          "remarks": "In transit to destination"
        }
      ],
      "last_sync_date": "2024-01-16T20:00:00.000Z"
    },
    "tracking_available": true
  }
}
```

**Response (No Shipment Created Yet):**
```json
{
  "success": true,
  "message": "Order tracking retrieved successfully",
  "data": {
    "order": {
      "order_id": "order_id",
      "status": "processing",
      "payment_status": "completed",
      "payment_verified": true,
      "total_amount": 245,
      "items": [...],
      "delivery_address": {...},
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    },
    "shipment": null,
    "tracking_available": false
  }
}
```

**Notes:**
- Returns order details along with shipment tracking information
- If no shipment has been created yet, `tracking_available` will be `false`
- Shipment is created by admin after order acceptance
- Tracking history shows the journey of the shipment

---

## Order Status Flow

1. **pending** - Initial status after order creation (not used in app routes as orders are created through payment)
2. **accepted** - Admin has accepted the order
3. **processing** - Order is being prepared
4. **shipped** - Order has been shipped (shipment created)
5. **delivered** - Order has been delivered to customer
6. **cancelled** - Order has been cancelled
7. **rejected** - Admin has rejected the order

## Payment Status

- **pending** - Payment is pending
- **completed** - Payment successful (only these orders are returned in user APIs)
- **failed** - Payment failed
- **refunded** - Payment has been refunded

## Shipment Status

- **NEW** - Shipment created but not processed
- **AWB_ASSIGNED** - AWB number assigned
- **PICKUP_SCHEDULED** - Pickup scheduled by courier
- **PICKED_UP** - Package picked up by courier
- **IN_TRANSIT** - Package in transit
- **OUT_FOR_DELIVERY** - Out for delivery
- **DELIVERED** - Delivered successfully
- **RTO_INITIATED** - Return to origin initiated
- **RTO_DELIVERED** - Returned to origin
- **CANCELLED** - Shipment cancelled
- **LOST** - Package lost
- **DAMAGED** - Package damaged

---

## Important Notes

1. **Order Creation**: Orders are NOT created directly through the order API. They are created automatically through the Payment API when payment is successful.

2. **Payment Routes for Order Creation**:
   - `POST /payments/create-order` - Create order with Razorpay
   - `POST /payments/verify` - Verify payment and update order
   - `POST /payments/confirm-cod/:orderId` - Confirm COD order

3. **User Access**: Users can only view and track their own orders

4. **Successful Payments Only**: The `GET /orders/my-orders` endpoint only returns orders with `payment_status: 'completed'`

5. **Tracking Availability**: Tracking information is available only after admin creates a shipment for the order

6. **Admin Order Management**: For order acceptance, rejection, and shipment creation, refer to Admin Order API documentation

---

## Example Usage

### Get My Orders
```bash
curl -X GET http://localhost:5000/orders/my-orders \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Order Details
```bash
curl -X GET http://localhost:5000/orders/ORDER_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Track Order
```bash
curl -X GET http://localhost:5000/orders/ORDER_ID/track \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Related APIs

- **Payment API** - For order creation and payment processing
- **Admin Order API** - For order management (acceptance, rejection, shipment creation)
- **Shipping API** - For additional shipping information and rates
- **Address API** - For managing delivery addresses
