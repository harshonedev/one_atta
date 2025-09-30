# 🎫 One Atta Backend - Coupon API Documentation

This document provides detailed information about the Coupon Management system in the One Atta Backend API, including both Admin and App-side endpoints.

## 📝 Important Notes

### Response Format
All API responses follow this consistent format:
- **Success responses**: `{ success: true, message: "...", data: {...} }`
- **Error responses**: `{ success: false, message: "error message" }`

### Field Naming Convention
- MongoDB documents use `_id` (not `id`) as the primary identifier
- Timestamps use `createdAt` and `updatedAt` (not `created_at` and `updated_at`)
- All date fields are returned in ISO 8601 format

### Virtual Fields
Some fields shown in the schema like `is_currently_valid` and `discount_display` are virtual fields computed by the client application and may not appear in actual API responses.

## 📋 Table of Contents
- [Overview](#overview)
- [Data Models](#data-models)
- [Admin Endpoints](#admin-endpoints)
- [App Endpoints](#app-endpoints)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)

## 🎯 Overview

The Coupon system supports two types of discounts:
1. **Fixed Amount Discount**: A fixed amount off the order total (e.g., ₹100 off)
2. **Percentage Discount**: A percentage off with a maximum discount cap (e.g., 20% off up to ₹120)

### Features:
- **Flexible Discount Types**: Fixed amount or percentage with maximum discount limits
- **Minimum Order Requirements**: Set minimum order amounts for coupon eligibility
- **Usage Limits**: Control total usage and per-user usage limits
- **Time-based Validity**: Set start and end dates for coupon validity
- **Item Targeting**: Apply coupons to all items, only products, or only blends
- **Usage Analytics**: Track coupon performance and user engagement
- **Real-time Validation**: Check coupon validity before order placement

---

## 📊 Data Models

### Coupon Schema
```javascript
{
  _id: "string (ObjectId)",
  code: "string (3-20 chars, uppercase alphanumeric, unique)",
  name: "string (3-100 chars)",
  description: "string (optional, max 500 chars)",
  discount_type: "string (enum: 'fixed', 'percentage')",
  discount_value: "number (min: 0, max: 100 for percentage)",
  min_order_amount: "number (default: 0)",
  max_discount_amount: "number (required for percentage type)",
  usage_limit: "number (null for unlimited)",
  usage_limit_per_user: "number (default: 1)",
  used_count: "number (default: 0)",
  valid_from: "datetime",
  valid_until: "datetime",
  is_active: "boolean (default: true)",
  applicable_to: "string (enum: 'all', 'products', 'blends')",
  applicable_items: "array of ObjectIds",
  applicable_to_model: "string (enum: 'Product', 'Blend')",
  created_by: "ObjectId (reference to admin user)",
  deleted: "boolean (default: false)",
  createdAt: "datetime",
  updatedAt: "datetime"
}
```

### CouponUsage Schema
```javascript
{
  _id: "string (ObjectId)",
  coupon_id: "ObjectId (reference to Coupon)",
  user_id: "ObjectId (reference to User)",
  order_id: "ObjectId (reference to Order)",
  discount_amount: "number",
  order_amount: "number",
  used_at: "datetime"
}
```

### Updated Order Schema (Coupon Integration)
```javascript
{
  // ... existing fields ...
  subtotal: "number (required)",
  coupon_applied: "ObjectId (reference to Coupon, optional)",
  coupon_code: "string (uppercase, optional)",
  discount_amount: "number (default: 0)",
  total_amount: "number (required, subtotal - discount_amount)"
}
```

---

# 🔧 Admin Endpoints

Base URL: `/api/admin/coupons`

## 1. Create Coupon

### **POST** `/`

Create a new coupon.

#### **Request Headers**
```http
Authorization: Bearer <admin_jwt_token>
Content-Type: application/json
```

#### **Request Body**
```json
{
  "code": "SAVE100",
  "name": "Save 100 Rupees",
  "description": "Get ₹100 off on orders above ₹500",
  "discount_type": "fixed",
  "discount_value": 100,
  "min_order_amount": 500,
  "usage_limit": 1000,
  "usage_limit_per_user": 1,
  "valid_from": "2024-01-01T00:00:00Z",
  "valid_until": "2024-12-31T23:59:59Z",
  "is_active": true,
  "applicable_to": "all"
}
```

#### **Response (201 Created)**
```json
{
  "success": true,
  "message": "Coupon created successfully",
  "data": {
    "_id": "60f8b123456789abcdef0123",
    "code": "SAVE100",
    "name": "Save 100 Rupees",
    "description": "Get ₹100 off on orders above ₹500",
    "discount_type": "fixed",
    "discount_value": 100,
    "min_order_amount": 500,
    "max_discount_amount": null,
    "usage_limit": 1000,
    "usage_limit_per_user": 1,
    "used_count": 0,
    "valid_from": "2024-01-01T00:00:00.000Z",
    "valid_until": "2024-12-31T23:59:59.000Z",
    "is_active": true,
    "applicable_to": "all",
    "applicable_items": [],
    "created_by": "60f8b123456789abcdef0456",
    "deleted": false,
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

## 2. Create Percentage Coupon Example

#### **Request Body**
```json
{
  "code": "PERCENT20",
  "name": "20% Off Up To 120",
  "description": "Get 20% discount up to ₹120 on orders above ₹500",
  "discount_type": "percentage",
  "discount_value": 20,
  "max_discount_amount": 120,
  "min_order_amount": 500,
  "usage_limit": null,
  "usage_limit_per_user": 3,
  "valid_from": "2024-01-01T00:00:00Z",
  "valid_until": "2024-12-31T23:59:59Z",
  "is_active": true,
  "applicable_to": "products",
  "applicable_items": ["60f8b123456789abcdef0789", "60f8b123456789abcdef0790"]
}
```

#### **Response (201 Created)**
```json
{
  "success": true,
  "message": "Coupon created successfully",
  "data": {
    "_id": "60f8b123456789abcdef0124",
    "code": "PERCENT20",
    "name": "20% Off Up To 120",
    "description": "Get 20% discount up to ₹120 on orders above ₹500",
    "discount_type": "percentage",
    "discount_value": 20,
    "max_discount_amount": 120,
    "min_order_amount": 500,
    "usage_limit": null,
    "usage_limit_per_user": 3,
    "used_count": 0,
    "valid_from": "2024-01-01T00:00:00.000Z",
    "valid_until": "2024-12-31T23:59:59.000Z",
    "is_active": true,
    "applicable_to": "products",
    "applicable_items": ["60f8b123456789abcdef0789", "60f8b123456789abcdef0790"],
    "applicable_to_model": "Product",
    "created_by": "60f8b123456789abcdef0456",
    "deleted": false,
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

## 3. Get All Coupons

### **GET** `/?page=1&limit=10&search=SAVE&is_active=true&discount_type=fixed`

#### **Query Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | number | Page number (default: 1) |
| limit | number | Items per page (default: 10, max: 100) |
| search | string | Search in coupon code and name |
| is_active | boolean | Filter by active status |
| discount_type | string | Filter by discount type ('fixed' or 'percentage') |
| applicable_to | string | Filter by applicable items ('all', 'products', 'blends') |
| sort | string | Sort field (default: '-created_at') |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupons fetched successfully",
  "data": {
    "coupons": [
      {
        "_id": "60f8b123456789abcdef0123",
        "code": "SAVE100",
        "name": "Save 100 Rupees",
        "discount_type": "fixed",
        "discount_value": 100,
        "min_order_amount": 500,
        "usage_limit": 1000,
        "used_count": 45,
        "is_active": true,
        "created_by": {
          "name": "Admin User",
          "email": "admin@oneatta.com"
        },
        "createdAt": "2024-01-01T10:00:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_count": 47,
      "limit": 10
    }
  }
}
```

## 4. Get Coupon by ID

### **GET** `/:id`

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon details fetched successfully",
  "data": {
    "coupon": {
      "_id": "60f8b123456789abcdef0123",
      "code": "SAVE100",
      "name": "Save 100 Rupees",
      "description": "Get ₹100 off on orders above ₹500",
      "discount_type": "fixed",
      "discount_value": 100,
      "min_order_amount": 500,
      "usage_limit": 1000,
      "used_count": 45,
      "is_active": true,
      "applicable_to": "all",
      "created_by": {
        "name": "Admin User",
        "email": "admin@oneatta.com"
      },
      "createdAt": "2024-01-01T10:00:00.000Z"
    },
    "usage_stats": {
      "total_uses": 45,
      "total_discount_given": 4500,
      "total_order_value": 25000,
      "unique_users_count": 32
    }
  }
}
```

## 5. Update Coupon

### **PATCH** `/:id`

#### **Request Body** (partial update)
```json
{
  "is_active": false,
  "usage_limit": 2000,
  "description": "Updated description"
}
```

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon updated successfully",
  "data": {
    "_id": "60f8b123456789abcdef0123",
    "code": "SAVE100",
    "name": "Save 100 Rupees",
    "description": "Updated description",
    "discount_type": "fixed",
    "discount_value": 100,
    "min_order_amount": 500,
    "usage_limit": 2000,
    "is_active": false,
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

## 6. Delete Coupon

### **DELETE** `/:id`

Soft deletes the coupon.

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon deleted successfully",
  "data": {}
}
```

## 7. Toggle Coupon Status

### **PATCH** `/:id/toggle-status`

Toggles the `is_active` status of the coupon.

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon activated successfully",
  "data": {
    "is_active": true
  }
}
```

## 8. Get Coupon Analytics

### **GET** `/analytics?start_date=2024-01-01&end_date=2024-01-31&coupon_id=60f8b123456789abcdef0123`

#### **Query Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| start_date | string (ISO date) | Start date for analytics |
| end_date | string (ISO date) | End date for analytics |
| coupon_id | string (ObjectId) | Specific coupon ID (optional) |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon analytics fetched successfully",
  "data": {
    "coupon_analytics": [
      {
        "_id": "60f8b123456789abcdef0123",
        "coupon_code": "SAVE100",
        "coupon_name": "Save 100 Rupees",
        "discount_type": "fixed",
        "total_uses": 45,
        "total_discount": 4500,
        "total_order_value": 25000,
        "unique_users_count": 32,
        "avg_discount": 100,
        "avg_order_value": 555.56,
        "conversion_rate": 18
      }
    ],
    "overall_stats": {
      "total_coupons_used": 145,
      "total_discount_given": 12500,
      "total_order_value": 87500,
      "unique_users_count": 98,
      "avg_discount_per_use": 86.21,
      "overall_conversion_rate": 14.29
    }
  }
}
```

## 9. Bulk Update Coupons

### **PATCH** `/bulk/update`

Perform bulk operations on multiple coupons.

#### **Request Body**
```json
{
  "coupon_ids": ["60f8b123456789abcdef0123", "60f8b123456789abcdef0124"],
  "action": "deactivate"
}
```

#### **Actions Available:**
- `activate`: Set `is_active` to `true`
- `deactivate`: Set `is_active` to `false`
- `delete`: Set `deleted` to `true` and `is_active` to `false`
- `update`: Apply custom updates (requires `update_data` field)

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupons deactivated successfully",
  "data": {
    "matched_count": 2,
    "modified_count": 2
  }
}
```

---

# 📱 App Endpoints

Base URL: `/api/coupons`

## 1. Get Available Coupons

### **GET** `/available?order_amount=1000`

Get all available coupons for the current user.

#### **Request Headers**
```http
Authorization: Bearer <user_jwt_token>
```

#### **Query Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| order_amount | number | Current order amount to calculate potential discounts |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Available coupons fetched successfully",
  "data": {
    "coupons": [
      {
        "_id": "60f8b123456789abcdef0123",
        "code": "SAVE100",
        "name": "Save 100 Rupees",
        "description": "Get ₹100 off on orders above ₹500",
        "discount_type": "fixed",
        "discount_value": 100,
        "max_discount_amount": null,
        "min_order_amount": 500,
        "usage_limit_per_user": 1,
        "potential_discount": 100,
        "remaining_uses": 1,
        "is_applicable": true
      },
      {
        "_id": "60f8b123456789abcdef0124",
        "code": "PERCENT20",
        "name": "20% Off Up To 120",
        "description": "Get 20% discount up to ₹120 on orders above ₹500",
        "discount_type": "percentage",
        "discount_value": 20,
        "max_discount_amount": 120,
        "min_order_amount": 500,
        "usage_limit_per_user": 3,
        "potential_discount": 120,
        "remaining_uses": 2,
        "is_applicable": true
      }
    ],
    "count": 2
  }
}
```

## 2. Validate and Apply Coupon

### **POST** `/validate`

Validate a coupon code and calculate the discount for an order.

#### **Request Body**
```json
{
  "coupon_code": "SAVE100",
  "order_data": {
    "items": [
      {
        "item_type": "Product",
        "item": "60f8b123456789abcdef0789",
        "quantity": 2,
        "price_per_kg": 300,
        "total_price": 600
      }
    ]
  }
}
```

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon applied successfully",
  "data": {
    "coupon_code": "SAVE100",
    "discount_amount": 100,
    "subtotal": 600,
    "total_amount": 500,
    "message": "Coupon applied successfully! You saved ₹100"
  }
}
```

#### **Response (400 Bad Request) - Invalid Coupon**
```json
{
  "success": false,
  "message": "Minimum order amount of ₹500 required"
}
```

## 3. Check Coupon Validity

### **POST** `/check-validity`

Real-time coupon validation for UI feedback.

#### **Request Body**
```json
{
  "coupon_code": "PERCENT20",
  "order_amount": 1000,
  "items": [
    {
      "item_type": "Product",
      "item": "60f8b123456789abcdef0789",
      "quantity": 2,
      "total_price": 600
    }
  ]
}
```

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon is valid",
  "data": {
    "discount_amount": 120,
    "message": "Coupon applied successfully! You saved ₹120",
    "coupon": {
      "_id": "60f8b123456789abcdef0124",
      "code": "PERCENT20",
      "name": "20% Off Up To 120",
      "discount_type": "percentage",
      "discount_value": 20,
      "max_discount_amount": 120,
      "min_order_amount": 500
    }
  }
}
```

## 4. Remove Coupon

### **POST** `/remove`

Remove coupon from order and recalculate totals.

#### **Request Body**
```json
{
  "order_data": {
    "items": [
      {
        "item_type": "Product",
        "item": "60f8b123456789abcdef0789",
        "quantity": 2,
        "price_per_kg": 300,
        "total_price": 600
      }
    ]
  }
}
```

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon removed successfully",
  "data": {
    "subtotal": 600,
    "total_amount": 600,
    "discount_amount": 0
  }
}
```

## 5. Get User Coupon History

### **GET** `/history?page=1&limit=10`

Get user's coupon usage history.

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon usage history fetched successfully",
  "data": {
    "history": [
      {
        "_id": "60f8b123456789abcdef0999",
        "coupon_id": {
          "code": "SAVE100",
          "name": "Save 100 Rupees",
          "discount_type": "fixed",
          "discount_value": 100
        },
        "order_id": {
          "_id": "60f8b123456789abcdef0888",
          "createdAt": "2024-01-15T10:30:00.000Z",
          "status": "delivered",
          "total_amount": 500
        },
        "discount_amount": 100,
        "order_amount": 600,
        "used_at": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_count": 8,
      "limit": 10
    }
  }
}
```

## 6. Get Coupon by Code

### **GET** `/code/:code`

Get public information about a coupon by its code.

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Coupon details fetched successfully",
  "data": {
    "coupon": {
      "_id": "60f8b123456789abcdef0123",
      "code": "SAVE100",
      "name": "Save 100 Rupees",
      "discount_type": "fixed",
      "discount_value": 100,
      "max_discount_amount": null,
      "min_order_amount": 500
    },
    "is_valid": true,
    "error": null
  }
}
```

---

# 💡 Usage Examples

## Example 1: Creating a Fixed Discount Coupon

**Admin creates a ₹100 off coupon for orders above ₹500:**

```bash
curl -X POST \
  http://localhost:5000/api/admin/coupons \
  -H 'Authorization: Bearer <admin_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "code": "SAVE100",
    "name": "Save 100 Rupees",
    "description": "Get ₹100 off on orders above ₹500",
    "discount_type": "fixed",
    "discount_value": 100,
    "min_order_amount": 500,
    "usage_limit": 1000,
    "usage_limit_per_user": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": "2024-12-31T23:59:59Z",
    "applicable_to": "all"
  }'
```

## Example 2: Creating a Percentage Discount Coupon

**Admin creates a 20% off coupon up to ₹120 discount:**

```bash
curl -X POST \
  http://localhost:5000/api/admin/coupons \
  -H 'Authorization: Bearer <admin_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "code": "PERCENT20",
    "name": "20% Off Up To 120",
    "description": "Get 20% discount up to ₹120 on orders above ₹500",
    "discount_type": "percentage",
    "discount_value": 20,
    "max_discount_amount": 120,
    "min_order_amount": 500,
    "usage_limit": null,
    "usage_limit_per_user": 3,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": "2024-12-31T23:59:59Z",
    "applicable_to": "all"
  }'
```

## Example 3: User Applying Coupon During Checkout

**Step 1: Check available coupons**
```bash
curl -X GET \
  'http://localhost:5000/api/coupons/available?order_amount=1000' \
  -H 'Authorization: Bearer <user_token>'
```

**Step 2: Validate coupon before applying**
```bash
curl -X POST \
  http://localhost:5000/api/coupons/check-validity \
  -H 'Authorization: Bearer <user_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "coupon_code": "PERCENT20",
    "order_amount": 1000,
    "items": [
      {
        "item_type": "Product",
        "item": "60f8b123456789abcdef0789",
        "quantity": 3,
        "total_price": 1000
      }
    ]
  }'
```

**Step 3: Apply coupon to order**
```bash
curl -X POST \
  http://localhost:5000/api/coupons/validate \
  -H 'Authorization: Bearer <user_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "coupon_code": "PERCENT20",
    "order_data": {
      "items": [
        {
          "item_type": "Product",
          "item": "60f8b123456789abcdef0789",
          "quantity": 3,
          "price_per_kg": 333.33,
          "total_price": 1000
        }
      ]
    }
  }'
```

## Example 4: Complete Order with Coupon

**Create order with applied coupon:**
```bash
curl -X POST \
  http://localhost:5000/api/orders \
  -H 'Authorization: Bearer <user_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "items": [
      {
        "item_type": "Product",
        "item": "60f8b123456789abcdef0789",
        "quantity": 3
      }
    ],
    "delivery_address": "60f8b123456789abcdef0456",
    "contact_numbers": ["+919876543210"],
    "payment_method": "COD",
    "subtotal": 1000,
    "coupon_applied": "60f8b123456789abcdef0124",
    "coupon_code": "PERCENT20",
    "discount_amount": 120,
    "total_amount": 880
  }'
```

---

# ⚠️ Error Handling

## Common Error Responses

### 400 Bad Request - Validation Error
```json
{
  "success": false,
  "message": "Validation failed"
}
```

### 400 Bad Request - Business Logic Error
```json
{
  "success": false,
  "message": "Minimum order amount of ₹500 required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Coupon not found"
}
```

### 409 Conflict - Duplicate Code
```json
{
  "success": false,
  "message": "Coupon code already exists"
}
```

## Error Scenarios

### Coupon Validation Errors:
1. **Invalid/Expired Coupon**: "Invalid or expired coupon code"
2. **Usage Limit Exceeded**: "You have already used this coupon 1 time(s)"
3. **Minimum Order Not Met**: "Minimum order amount of ₹500 required"
4. **Coupon Not Applicable**: "This coupon is not applicable to your cart items"
5. **Inactive Coupon**: "This coupon is currently inactive"

### Admin Operation Errors:
1. **Missing Required Fields**: Field-specific validation messages
2. **Invalid Date Range**: "Valid until date must be after valid from date"
3. **Invalid Percentage**: "Percentage discount cannot exceed 100%"
4. **Missing Max Discount**: "Max discount amount is required for percentage coupons"

---

# 🔒 Security & Authorization

## Admin Endpoints
- Require admin JWT token with `admin` or `manager` role
- All admin operations are logged with the performing admin's ID

## App Endpoints
- Require user JWT token
- Users can only see their own coupon usage history
- Coupon application is validated server-side to prevent manipulation

## Data Protection
- Coupon codes are stored in uppercase for consistency
- Soft deletion prevents data loss while maintaining referential integrity
- Usage tracking prevents fraud and abuse

---

This completes the comprehensive Coupon API documentation. The system supports flexible discount structures with robust validation and analytics capabilities.