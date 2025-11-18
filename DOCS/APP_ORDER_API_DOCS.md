# App Order Management API Documentation

## Overview
The App Order Management API provides comprehensive order functionality for mobile and web applications. This API implements a secure two-stage order workflow where users can create orders that require admin approval before shipment creation. The system supports product and blend ordering, coupon application, multiple payment methods, and real-time order tracking.

### Key Features
- **Secure Order Workflow**: Orders require admin approval before processing
- **Multi-Item Support**: Support for both products and custom blends
- **Coupon Integration**: Apply discount coupons with validation
- **Multiple Payment Methods**: COD, UPI, Card, and Wallet payments
- **Real-Time Tracking**: Track order status from placement to delivery
- **Address Management**: Integration with user address system
- **Order History**: Complete order history with filtering options

### Order Lifecycle
```
Order Created (pending) → Admin Review → Accepted/Rejected → Processing → Shipped → Delivered
                                    ↘ Rejected (with reason)
```

## Base URL
```
/api/app/orders
```

## Authentication
All endpoints require user authentication:
```
Authorization: Bearer <jwt_token>
```

For mobile applications:
```
x-api-key: <mobile_api_key>
```

## Table of Contents
1. [Order Creation](#1-create-order)
2. [Order Retrieval](#2-get-order-details)
3. [Order History](#3-get-user-orders)
4. [Order Tracking](#4-track-order)
5. [Cancel Order](#5-cancel-order)
6. [Status Reference](#order-status-values)
7. [Error Handling](#error-handling)
8. [Integration Guide](#integration-guide)

---

## Endpoints

### 1. Create Order
**POST** `/api/app/orders`

Create a new order with products/blends, delivery address, and payment information.

**Request Body:**
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
  "contact_numbers": ["+91-9876543210", "+91-9876543211"],
  "payment_method": "COD",
  "coupon_code": "WELCOME10",
  "special_instructions": "Please handle with care"
}
```

**Validation Rules:**
- `items`: Array of 1-10 items, each with valid item_type, item ID, and positive quantity
- `delivery_address`: Must be a valid address ID belonging to the user
- `contact_numbers`: 1-2 valid phone numbers
- `payment_method`: One of `COD`, `UPI`, `Card`, `Wallet`
- `coupon_code`: Optional, must be valid and applicable
- `special_instructions`: Optional, max 500 characters

**Success Response:**
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "user_id": {
      "_id": "507f1f77bcf86cd799439010",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "items": [
      {
        "item_type": "Product",
        "item": {
          "_id": "507f1f77bcf86cd799439011",
          "name": "Organic Wheat Flour",
          "sku": "OWF001",
          "price_per_kg": 45
        },
        "quantity": 2.5,
        "price_per_kg": 45,
        "total_price": 112.5
      }
    ],
    "status": "pending",
    "delivery_address": {
      "_id": "507f1f77bcf86cd799439013",
      "recipient_name": "John Doe",
      "address_line1": "123 Main Street",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postal_code": "400001",
      "country": "India",
      "primary_phone": "+91-9876543210"
    },
    "contact_numbers": ["+91-9876543210"],
    "payment_method": "COD",
    "subtotal": 112.5,
    "coupon_applied": {
      "_id": "507f1f77bcf86cd799439015",
      "code": "WELCOME10",
      "name": "Welcome Discount",
      "discount_type": "percentage",
      "discount_value": 10
    },
    "coupon_code": "WELCOME10",
    "discount_amount": 11.25,
    "total_amount": 101.25,
    "special_instructions": "Please handle with care",
    "created_at": "2025-01-20T10:00:00.000Z",
    "updated_at": "2025-01-20T10:00:00.000Z"
  }
}
```

**Error Response (Invalid Item):**
```json
{
  "success": false,
  "message": "Product not found with id 507f1f77bcf86cd799439011",
  "code": "ITEM_NOT_FOUND"
}
```

**Error Response (Invalid Coupon):**
```json
{
  "success": false,
  "message": "Coupon code INVALID10 is not valid or has expired",
  "code": "INVALID_COUPON"
}
```

### 2. Get Order Details
**GET** `/api/app/orders/:id`

Get detailed information about a specific order.

**Path Parameters:**
- `id` (string, required): Order ID

**Success Response:**
```json
{
  "success": true,
  "message": "Order retrieved successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "user_id": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "items": [
      {
        "item_type": "Product",
        "item": {
          "name": "Organic Wheat Flour",
          "sku": "OWF001",
          "price_per_kg": 45
        },
        "quantity": 2.5,
        "price_per_kg": 45,
        "total_price": 112.5
      }
    ],
    "status": "accepted",
    "delivery_address": {
      "recipient_name": "John Doe",
      "address_line1": "123 Main Street",
      "city": "Mumbai",
      "postal_code": "400001"
    },
    "payment_method": "COD",
    "subtotal": 112.5,
    "discount_amount": 11.25,
    "total_amount": 101.25,
    "accepted_by": "60f7b350c45a8b001c8e4560",
    "accepted_at": "2025-01-20T14:30:00.000Z",
    "special_instructions": "Please handle with care",
    "created_at": "2025-01-20T10:00:00.000Z",
    "updated_at": "2025-01-20T14:30:00.000Z"
  }
}
```

**Error Response (Not Found):**
```json
{
  "success": false,
  "message": "Order not found or access denied",
  "code": "ORDER_NOT_FOUND"
}
```

### 3. Get User Orders
**GET** `/api/app/orders/user/:userId`

Get all orders for the authenticated user with filtering and pagination options.

**Path Parameters:**
- `userId` (string, required): User ID (must match authenticated user)

**Query Parameters (all optional):**
- `status` (string): Filter by order status
- `startDate` (string): Filter from date (YYYY-MM-DD)
- `endDate` (string): Filter to date (YYYY-MM-DD)
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 20, max: 100)
- `sortBy` (string): Sort field (`created_at`, `updated_at`, `total_amount`)
- `sortOrder` (string): Sort direction (`asc`, `desc`, default: `desc`)

**Example Request:**
```bash
GET /api/app/orders/user/507f1f77bcf86cd799439010?status=delivered&page=1&limit=10&sortBy=created_at&sortOrder=desc
```

**Success Response:**
```json
{
  "success": true,
  "message": "User orders retrieved successfully",
  "data": {
    "orders": [
      {
        "_id": "507f1f77bcf86cd799439014",
        "items": [
          {
            "item_type": "Product",
            "item": {
              "name": "Organic Wheat Flour",
              "sku": "OWF001"
            },
            "quantity": 2.5,
            "total_price": 112.5
          }
        ],
        "status": "delivered",
        "delivery_address": {
          "recipient_name": "John Doe",
          "city": "Mumbai"
        },
        "payment_method": "COD",
        "total_amount": 101.25,
        "created_at": "2025-01-15T10:00:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_count": 25,
      "has_next": true,
      "has_prev": false,
      "per_page": 10
    },
    "summary": {
      "total_orders": 25,
      "pending_orders": 2,
      "delivered_orders": 18,
      "total_spent": 3250.75
    }
  }
}
```

### 4. Cancel Order
**DELETE** `/api/app/orders/:id`

Cancel a pending order. **Only orders in `pending` status (before admin acceptance) can be cancelled by users.** The cancel button should only be displayed for orders with `pending` status.

**Path Parameters:**
- `id` (string, required): Order ID

**Request Body (optional):**
```json
{
  "reason": "Changed my mind about the order"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Order cancelled successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "status": "cancelled",
    "cancelled_at": "2025-01-20T15:30:00.000Z",
    "cancellation_reason": "Changed my mind about the order"
  }
}
```

**Error Response (Invalid Status):**
```json
{
  "success": false,
  "message": "Order cannot be cancelled. Current status: processing",
  "code": "INVALID_CANCELLATION"
}
```

### 5. Update Order Status
**PATCH** `/api/app/orders/:id/status`

Update order status (limited user actions only).

**Path Parameters:**
- `id` (string, required): Order ID

**Request Body:**
```json
{
  "status": "cancelled"
}
```

**Valid User Status Updates:**
- `pending` → `cancelled` (user cancellation)

**Success Response:**
```json
{
  "success": true,
  "message": "Order status updated successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439014",
    "status": "cancelled",
    "updated_at": "2025-01-20T15:30:00.000Z"
  }
}
```

### 6. Reorder
**POST** `/api/app/orders/:id/reorder`

Create a new order based on a previous order.

**Path Parameters:**
- `id` (string, required): Original order ID to reorder

**Request Body (optional):**
```json
{
  "delivery_address": "507f1f77bcf86cd799439016",
  "payment_method": "UPI",
  "modify_items": [
    {
      "item_type": "Product",
      "item": "507f1f77bcf86cd799439011",
      "quantity": 3.0
    }
  ]
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Reorder created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439017",
    "original_order_id": "507f1f77bcf86cd799439014",
    "items": [...],
    "status": "pending",
    "total_amount": 125.50,
    "created_at": "2025-01-20T16:00:00.000Z"
  }
}
```

### 7. Get Order Summary
**GET** `/api/app/orders/summary`

Get order summary statistics for the authenticated user.

**Query Parameters:**
- `period` (string, optional): Time period (`7d`, `30d`, `90d`, `1y`, default: `30d`)

**Success Response:**
```json
{
  "success": true,
  "message": "Order summary retrieved successfully",
  "data": {
    "period": "30d",
    "total_orders": 8,
    "total_spent": 1250.75,
    "average_order_value": 156.34,
    "status_breakdown": {
      "pending": 1,
      "processing": 2,
      "shipped": 1,
      "delivered": 4
    },
    "favorite_items": [
      {
        "item_type": "Product",
        "item": {
          "name": "Organic Wheat Flour",
          "sku": "OWF001"
        },
        "total_quantity": 12.5,
        "order_count": 5
      }
    ],
    "recent_orders": 3
  }
}
```

---

## Validation Rules and Business Logic

### Order Creation Validation
1. **Item Validation**:
   - All items must exist and be active
   - Quantities must be positive numbers
   - Maximum 10 items per order
   - Minimum order value may apply

2. **Address Validation**:
   - Address must belong to the authenticated user
   - Address must be complete with all required fields
   - Delivery location must be serviceable

3. **Payment Method Validation**:
   - COD has maximum order value limits
   - Online payment methods require additional verification

4. **Coupon Validation**:
   - Coupon must be active and not expired
   - User must be eligible for the coupon
   - Minimum order value requirements must be met
   - Usage limits per user/total must not be exceeded

### Business Rules
1. **Order Cancellation**:
   - **UI Rule**: Only show cancel button for orders with `pending` status
   - Users can only cancel orders in `pending` status (before admin acceptance)
   - Once order is `accepted`, `processing`, or later stages, cancel button must be hidden
   - Orders after acceptance require admin intervention for cancellation

2. **Pricing Rules**:
   - Prices are locked at order creation time
   - Discounts are applied based on coupon rules
   - Total amount includes any applicable taxes/fees

3. **Inventory Management**:
   - Items are not reserved until order is accepted by admin
   - Out-of-stock items may cause order rejection
   - Price changes after order creation do not affect existing orders

## Order Status Values

| Status | Description | User Actions Available |
|--------|-------------|------------------------|
| `pending` | Order placed, awaiting admin review | **Show Cancel Button** |
| `accepted` | Admin approved order | View details (No Cancel) |
| `processing` | Order being prepared for shipment | View details, track (No Cancel) |
| `shipped` | Order shipped, in transit | Track shipment (No Cancel) |
| `delivered` | Order delivered successfully | View details, reorder (No Cancel) |
| `cancelled` | Order cancelled by user/admin | View details |
| `rejected` | Order rejected by admin with reason | View details, reorder |

---

## Error Handling

### Common Error Codes

| HTTP Code | Error Code | Description |
|-----------|------------|-------------|
| `400` | `VALIDATION_ERROR` | Invalid request data |
| `400` | `ITEM_NOT_FOUND` | Product/Blend not found |
| `400` | `INVALID_COUPON` | Coupon invalid or expired |
| `400` | `INVALID_ADDRESS` | Address not found or invalid |
| `400` | `INVALID_CANCELLATION` | Cannot cancel order in current status |
| `401` | `UNAUTHORIZED` | Authentication required |
| `403` | `ACCESS_DENIED` | Order doesn't belong to user |
| `404` | `ORDER_NOT_FOUND` | Order not found |
| `409` | `INSUFFICIENT_STOCK` | Not enough inventory |
| `500` | `SERVER_ERROR` | Internal server error |

### Error Response Format
```json
{
  "success": false,
  "message": "Descriptive error message",
  "code": "ERROR_CODE",
  "details": {
    "field": "specific field that caused error",
    "value": "invalid value"
  }
}
```

---

## Integration Guide

### Order Creation Flow
1. **Validate Cart**: Ensure all items are available and prices are current
2. **Apply Coupon**: Validate and apply coupon if provided
3. **Select Address**: Choose or create delivery address
4. **Choose Payment**: Select payment method
5. **Create Order**: Submit order for admin review
6. **Track Status**: Monitor order status updates

### Frontend Integration
```javascript
// Example order creation
const createOrder = async (orderData) => {
  try {
    const response = await fetch('/api/app/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken}`,
        'x-api-key': 'your-api-key'
      },
      body: JSON.stringify(orderData)
    });
    
    const result = await response.json();
    if (result.success) {
      // Handle successful order creation
      return result.data;
    } else {
      // Handle error
      throw new Error(result.message);
    }
  } catch (error) {
    console.error('Order creation failed:', error);
    throw error;
  }
};
```

### Real-time Updates
Implement WebSocket or polling for real-time order status updates:

```javascript
// Polling example
const pollOrderStatus = async (orderId) => {
  const response = await fetch(`/api/app/orders/${orderId}`);
  const result = await response.json();
  return result.data.status;
};

// Poll every 30 seconds for status updates
setInterval(() => {
  pollOrderStatus(currentOrderId).then(status => {
    updateOrderStatus(status);
  });
}, 30000);
```

---

## Best Practices

### Performance Optimization
1. **Pagination**: Always use pagination for order lists
2. **Caching**: Cache frequently accessed data like product details
3. **Lazy Loading**: Load order details on demand
4. **Efficient Queries**: Use appropriate filters to reduce data transfer

### User Experience
1. **Status Communication**: Clearly communicate order status to users
2. **Error Handling**: Provide helpful error messages and recovery actions
3. **Progress Tracking**: Show order progress throughout the lifecycle
4. **Notifications**: Implement push notifications for status updates

### Security Considerations
1. **Authentication**: Always verify user authentication
2. **Authorization**: Ensure users can only access their own orders
3. **Data Validation**: Validate all input data on both client and server
4. **Rate Limiting**: Implement rate limiting to prevent abuse

### Error Recovery
1. **Retry Logic**: Implement retry for transient failures
2. **Offline Support**: Handle offline scenarios gracefully
3. **Validation**: Pre-validate data before submission
4. **User Feedback**: Provide clear feedback for all operations

---

## Mobile App Considerations

### Offline Capabilities
- Cache recent orders for offline viewing
- Queue order updates when connectivity is restored
- Provide offline indicators for order status

### Push Notifications
- Order confirmation notifications
- Status update notifications
- Delivery notifications
- Promotional order-related notifications

### Performance
- Implement image caching for product items
- Use pagination for order history
- Optimize network requests with proper caching headers

---

## Testing Examples

### Postman Collection Examples

**Create Order:**
```bash
curl -X POST "https://api.yourapp.com/api/app/orders" \
  -H "Authorization: Bearer your_jwt_token" \
  -H "Content-Type: application/json" \
  -H "x-api-key: your_api_key" \
  -d '{
    "items": [
      {
        "item_type": "Product",
        "item": "507f1f77bcf86cd799439011",
        "quantity": 2.5
      }
    ],
    "delivery_address": "507f1f77bcf86cd799439013",
    "contact_numbers": ["+91-9876543210"],
    "payment_method": "COD"
  }'
```

**Get Order History:**
```bash
curl -X GET "https://api.yourapp.com/api/app/orders/user/507f1f77bcf86cd799439010?page=1&limit=10&status=delivered" \
  -H "Authorization: Bearer your_jwt_token" \
  -H "x-api-key: your_api_key"
```

**Cancel Order:**
```bash
curl -X POST "https://api.yourapp.com/api/app/orders/507f1f77bcf86cd799439014/cancel" \
  -H "Authorization: Bearer your_jwt_token" \
  -H "x-api-key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "cancellation_reason": "Changed my mind"
  }'
```

### SDK Integration Examples

**React Native Integration:**
```javascript
import OrderAPI from './api/OrderAPI';

// Create order
const createOrder = async (orderData) => {
  try {
    const order = await OrderAPI.createOrder(orderData);
    // Navigate to order confirmation screen
    navigation.navigate('OrderConfirmation', { orderId: order._id });
  } catch (error) {
    // Show error message
    Alert.alert('Error', error.message);
  }
};

// Track order status
const trackOrder = async (orderId) => {
  try {
    const order = await OrderAPI.getOrder(orderId);
    setOrderStatus(order.status);
  } catch (error) {
    console.error('Failed to track order:', error);
  }
};
```

**Flutter Integration:**
```dart
class OrderService {
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/app/orders'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: json.encode(orderData),
    );
    
    if (response.statusCode == 201) {
      return Order.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to create order');
    }
  }
}
```

---

## Frequently Asked Questions

### 5. Cancel Order
**POST** `/orders/:id/cancel`

**UI Implementation**: Display the cancel button **only** when `order.status === 'pending'`. Once the order status changes to `accepted` or any other status, the cancel button must be hidden.

Cancel a pending order. Only orders in `pending` status (before admin acceptance) can be cancelled by users. Automatically handles:
- Loyalty points reversal (earned points deducted, redeemed points refunded)
- Refund record creation for prepaid orders
- Share points reversal for blend creators
- Push notification to user

**URL Parameters:**
- `id`: Order ID (required)

**Request Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "cancellation_reason": "Changed my mind" // Optional
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Order cancelled successfully",
  "data": {
    "order": {
      "_id": "507f1f77bcf86cd799439014",
      "status": "cancelled",
      "payment_status": "refunded"
    },
    "refund": {
      "_id": "507f1f77bcf86cd799439020",
      "amount": 1500,
      "status": "pending",
      "created_at": "2025-11-18T10:30:00.000Z"
    },
    "loyalty": {
      "points_reversed": 15,
      "points_redeemed_refunded": 100
    }
  }
}
```

**Error Responses:**

**400 Bad Request - Cannot Cancel:**
```json
{
  "success": false,
  "message": "Order cannot be cancelled. Current status: shipped"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Order not found"
}
```

**Cancellation Rules:**

✅ **Show Cancel Button & Can Cancel:**
- Orders with status: `pending` (before admin accepts)

❌ **Hide Cancel Button & Cannot Cancel:**
- Orders with status: `accepted`, `processing`, `shipped`, `delivered`, `cancelled`, `rejected`
- **Important**: Once admin accepts the order (status changes from `pending` to `accepted`), the cancel button must be immediately hidden from the UI

**What Happens When You Cancel:**

1. **Loyalty Points Reversal**
   - ORDER points (earned): Deducted from your account
   - REDEEM points (used for discount): Refunded to your account
   - SHARE points (blend creators): Reversed from creators

2. **Refund Processing** (Prepaid Orders Only)
   - Refund record created automatically
   - Status: `pending`
   - Admin will process the refund
   - You'll receive notifications on refund status

3. **Order Status Update**
   - Status changed to `cancelled`
   - Payment status changed to `refunded` (if prepaid)

4. **Notifications**
   - Push notification sent with cancellation confirmation
   - Refund amount and loyalty points information included

**Example Usage:**

```javascript
// UI Implementation - Show cancel button only for pending orders
const shouldShowCancelButton = (order) => {
  return order.status === 'pending';
};

// Cancel order
const cancelOrder = async (orderId, reason) => {
  try {
    const response = await fetch(`/api/app/orders/${orderId}/cancel`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${userToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        cancellation_reason: reason
      })
    });
    
    const result = await response.json();
    
    if (result.success) {
      // Show success message
      if (result.data.refund) {
        console.log(`Refund of ₹${result.data.refund.amount} is being processed`);
      }
      if (result.data.loyalty.points_redeemed_refunded > 0) {
        console.log(`${result.data.loyalty.points_redeemed_refunded} loyalty points refunded`);
      }
    }
  } catch (error) {
    console.error('Failed to cancel order:', error);
  }
};
```

**Important Notes:**
- COD orders: No refund record created (payment not received)
- Prepaid orders: Refund record created, admin processes refund
- All operations are transaction-safe (automatic rollback on failure)
- Cannot cancel after admin has accepted the order

---

### Q: Can users modify orders after creation?
A: No, orders cannot be modified after creation. Users can only cancel pending orders (before admin acceptance) or create a new order with modifications.

### Q: What happens if a product price changes after order creation?
A: The order locks in prices at creation time. Price changes do not affect existing orders.

### Q: How long can an order stay in pending status?
A: Orders typically stay in pending status for 24-48 hours. After this period, they may be automatically cancelled or flagged for admin review.

### Q: Can users apply multiple coupons to one order?
A: No, only one coupon can be applied per order. The system will apply the best available discount.

### Q: What payment methods are supported?
A: The system supports COD (Cash on Delivery), UPI, Card payments, and digital wallets.

### Q: How are shipping costs calculated?
A: Shipping costs are calculated based on delivery location, package weight, and selected courier service during checkout.

This app order management system provides a secure, user-friendly interface for order management with comprehensive tracking and integration capabilities.