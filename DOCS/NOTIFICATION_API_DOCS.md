# FCM Notification System API Documentation

## Overview

This document describes the FCM (Firebase Cloud Messaging) notification system API endpoints for the One Atta backend. The system allows users to register their device tokens and administrators to send push notifications to users.

## Table of Contents

- [App Endpoints](#app-endpoints)
  - [Update FCM Token](#update-fcm-token)
  - [Remove FCM Token](#remove-fcm-token)
- [Admin Endpoints](#admin-endpoints)
  - [Send Notification to All Users](#send-notification-to-all-users)
  - [Send Notification to Specific Users](#send-notification-to-specific-users)
  - [Send Notification to Topic](#send-notification-to-topic)
  - [Send Notification to Single User](#send-notification-to-single-user)
  - [Get All Notifications](#get-all-notifications)
  - [Get Notification by ID](#get-notification-by-id)
  - [Delete Notification](#delete-notification)
  - [Get Notification Statistics](#get-notification-statistics)
- [Setup Instructions](#setup-instructions)
- [Notification Types](#notification-types)
- [Data Models](#data-models)

---

## App Endpoints

These endpoints are available to authenticated users for managing their FCM tokens.

### Update FCM Token

Register or update the user's FCM token for receiving push notifications.

**Endpoint:** `PUT /api/app/notifications/fcm-token`

**Authentication:** Required (JWT Token)

**Request Body:**
```json
{
  "fcmToken": "string (required) - FCM token from the device"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "FCM token updated successfully",
  "data": {
    "message": "FCM token updated successfully",
    "fcmToken": "ExampleFCMToken..."
  }
}
```

**Error Responses:**
- `400` - Invalid or missing FCM token
- `401` - Unauthorized (invalid or missing token)
- `404` - User not found

**Example Request:**
```bash
curl -X PUT "http://localhost:5001/api/app/notifications/fcm-token" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fcmToken": "your-device-fcm-token-here"
  }'
```

---

### Remove FCM Token

Remove the user's FCM token (typically called during logout).

**Endpoint:** `DELETE /api/app/notifications/fcm-token`

**Authentication:** Required (JWT Token)

**Success Response (200):**
```json
{
  "success": true,
  "message": "FCM token removed successfully",
  "data": {
    "message": "FCM token removed successfully"
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `404` - User not found

**Example Request:**
```bash
curl -X DELETE "http://localhost:5001/api/app/notifications/fcm-token" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Admin Endpoints

These endpoints are available only to administrators for sending and managing notifications.

### Send Notification to All Users

Send a push notification to all registered users with FCM tokens.

**Endpoint:** `POST /api/admin/notifications/send-all`

**Authentication:** Required (JWT Token + Admin Role)

**Request Body:**
```json
{
  "title": "string (required) - Notification title",
  "body": "string (required) - Notification body/message",
  "imageUrl": "string (optional) - URL of notification image",
  "type": "string (optional) - Type: order, promotion, delivery, general",
  "data": {
    "key": "value - Any additional data as key-value pairs"
  }
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification sent to all users successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "title": "New Promotion!",
      "body": "Get 20% off on all products",
      "type": "promotion",
      "targetType": "all",
      "status": "sent",
      "totalRecipients": 150,
      "successCount": 145,
      "failureCount": 5,
      "sentAt": "2025-11-01T12:00:00.000Z",
      "createdBy": "admin_user_id",
      "createdAt": "2025-11-01T12:00:00.000Z"
    }
  }
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:5001/api/admin/notifications/send-all" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Promotion!",
    "body": "Get 20% off on all products this week",
    "type": "promotion",
    "data": {
      "promoCode": "SAVE20",
      "validUntil": "2025-11-07"
    }
  }'
```

---

### Send Notification to Specific Users

Send a push notification to specific users.

**Endpoint:** `POST /api/admin/notifications/send-users`

**Authentication:** Required (JWT Token + Admin Role)

**Request Body:**
```json
{
  "title": "string (required)",
  "body": "string (required)",
  "imageUrl": "string (optional)",
  "type": "string (optional)",
  "data": {},
  "userIds": ["array of user IDs (required)"]
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification sent to users successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "title": "Order Update",
      "body": "Your order has been shipped",
      "type": "order",
      "targetType": "specific",
      "targetUsers": ["user_id_1", "user_id_2"],
      "status": "sent",
      "totalRecipients": 2,
      "successCount": 2,
      "failureCount": 0,
      "sentAt": "2025-11-01T12:00:00.000Z"
    }
  }
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:5001/api/admin/notifications/send-users" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Order Delivered",
    "body": "Your order #12345 has been delivered",
    "type": "order",
    "userIds": ["user_id_1", "user_id_2"],
    "data": {
      "orderId": "12345",
      "status": "delivered"
    }
  }'
```

---

### Send Notification to Topic

Send a push notification to all users subscribed to a specific topic.

**Endpoint:** `POST /api/admin/notifications/send-topic`

**Authentication:** Required (JWT Token + Admin Role)

**Request Body:**
```json
{
  "title": "string (required)",
  "body": "string (required)",
  "imageUrl": "string (optional)",
  "type": "string (optional)",
  "data": {},
  "topic": "string (required) - Topic name"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification sent to topic successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "title": "Premium Offer",
      "body": "Exclusive offer for premium users",
      "type": "promotion",
      "targetType": "topic",
      "targetTopic": "premium_users",
      "status": "sent",
      "sentAt": "2025-11-01T12:00:00.000Z"
    }
  }
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:5001/api/admin/notifications/send-topic" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Premium Feature Unlocked",
    "body": "New features available for premium members",
    "type": "promotion",
    "topic": "premium_users"
  }'
```

---

### Send Notification to Single User

Send a push notification to a single user.

**Endpoint:** `POST /api/admin/notifications/send-user/:userId`

**Authentication:** Required (JWT Token + Admin Role)

**URL Parameters:**
- `userId` - The ID of the target user

**Request Body:**
```json
{
  "title": "string (required)",
  "body": "string (required)",
  "imageUrl": "string (optional)",
  "type": "string (optional)",
  "data": {}
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification sent to user successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "title": "Account Verified",
      "body": "Your account has been successfully verified",
      "type": "general",
      "targetType": "specific",
      "targetUsers": ["user_id"],
      "status": "sent",
      "totalRecipients": 1,
      "successCount": 1,
      "failureCount": 0
    }
  }
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:5001/api/admin/notifications/send-user/507f1f77bcf86cd799439011" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Welcome!",
    "body": "Welcome to One Atta. Start your journey now!",
    "type": "general"
  }'
```

---

### Get All Notifications

Retrieve all notifications with pagination and filtering.

**Endpoint:** `GET /api/admin/notifications`

**Authentication:** Required (JWT Token + Admin Role)

**Query Parameters:**
- `page` (optional, default: 1) - Page number
- `limit` (optional, default: 20) - Items per page
- `status` (optional) - Filter by status: pending, sent, failed
- `type` (optional) - Filter by type: order, promotion, delivery, general
- `targetType` (optional) - Filter by target: all, specific, topic
- `startDate` (optional) - Filter from date (ISO format)
- `endDate` (optional) - Filter to date (ISO format)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notifications fetched successfully",
  "data": {
    "notifications": [
      {
        "_id": "notification_id",
        "title": "New Promotion",
        "body": "Get 20% off",
        "type": "promotion",
        "targetType": "all",
        "status": "sent",
        "totalRecipients": 150,
        "successCount": 145,
        "failureCount": 5,
        "createdBy": {
          "_id": "admin_id",
          "name": "Admin Name",
          "email": "admin@example.com"
        },
        "createdAt": "2025-11-01T12:00:00.000Z",
        "sentAt": "2025-11-01T12:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

**Example Request:**
```bash
curl -X GET "http://localhost:5001/api/admin/notifications?page=1&limit=20&status=sent&type=promotion" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

---

### Get Notification by ID

Retrieve detailed information about a specific notification.

**Endpoint:** `GET /api/admin/notifications/:id`

**Authentication:** Required (JWT Token + Admin Role)

**URL Parameters:**
- `id` - Notification ID

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification fetched successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "title": "Order Update",
      "body": "Your order has been shipped",
      "imageUrl": "https://example.com/image.jpg",
      "type": "order",
      "data": {
        "orderId": "12345",
        "trackingNumber": "ABC123"
      },
      "targetType": "specific",
      "targetUsers": [
        {
          "_id": "user_id",
          "name": "User Name",
          "email": "user@example.com",
          "mobile": "1234567890"
        }
      ],
      "status": "sent",
      "sentAt": "2025-11-01T12:00:00.000Z",
      "totalRecipients": 1,
      "successCount": 1,
      "failureCount": 0,
      "createdBy": {
        "_id": "admin_id",
        "name": "Admin Name",
        "email": "admin@example.com"
      },
      "createdAt": "2025-11-01T12:00:00.000Z"
    }
  }
}
```

**Example Request:**
```bash
curl -X GET "http://localhost:5001/api/admin/notifications/507f1f77bcf86cd799439011" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

---

### Delete Notification

Soft delete a notification (marks as deleted, doesn't remove from database).

**Endpoint:** `DELETE /api/admin/notifications/:id`

**Authentication:** Required (JWT Token + Admin Role)

**URL Parameters:**
- `id` - Notification ID

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification deleted successfully",
  "data": {
    "message": "Notification deleted successfully"
  }
}
```

**Error Responses:**
- `404` - Notification not found

**Example Request:**
```bash
curl -X DELETE "http://localhost:5001/api/admin/notifications/507f1f77bcf86cd799439011" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

---

### Get Notification Statistics

Retrieve overall notification statistics and analytics.

**Endpoint:** `GET /api/admin/notifications/stats/overview`

**Authentication:** Required (JWT Token + Admin Role)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Notification statistics fetched successfully",
  "data": {
    "stats": {
      "overall": {
        "totalNotifications": 250,
        "totalSent": 240,
        "totalFailed": 5,
        "totalPending": 5,
        "totalRecipients": 5000,
        "totalSuccessful": 4800,
        "totalFailures": 200
      },
      "byType": [
        {
          "_id": "order",
          "count": 100
        },
        {
          "_id": "promotion",
          "count": 80
        },
        {
          "_id": "delivery",
          "count": 50
        },
        {
          "_id": "general",
          "count": 20
        }
      ]
    }
  }
}
```

**Example Request:**
```bash
curl -X GET "http://localhost:5001/api/admin/notifications/stats/overview" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

---

## Setup Instructions

### 1. Install firebase-admin Package

```bash
npm install firebase-admin
```

### 2. Configure Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Download the JSON file

### 3. Set Environment Variable

Add the Firebase service account JSON as an environment variable:

**Option 1: Direct JSON String**
```env
FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"your-project",...}'
```

**Option 2: Base64 Encoded**
```bash
# Encode the JSON file
base64 -i path/to/serviceAccountKey.json

# Add to .env
FIREBASE_SERVICE_ACCOUNT_BASE64='base64_encoded_string_here'
```

### 4. Initialize FCM in Server

The FCM service is automatically initialized when the server starts (already implemented in `server.js`).

---

## Notification Types

The system supports four notification types:

### 1. Order (`order`)
- **Icon:** Green shopping bag
- **Use Cases:** Order confirmation, shipping updates, delivery status
- **Example Data:**
  ```json
  {
    "orderId": "12345",
    "status": "shipped",
    "trackingNumber": "ABC123"
  }
  ```

### 2. Promotion (`promotion`)
- **Icon:** Orange offer tag
- **Use Cases:** Discounts, offers, promotional campaigns
- **Example Data:**
  ```json
  {
    "promoCode": "SAVE20",
    "discount": "20%",
    "validUntil": "2025-11-07"
  }
  ```

### 3. Delivery (`delivery`)
- **Icon:** Blue shipping truck
- **Use Cases:** Delivery notifications, arrival updates
- **Example Data:**
  ```json
  {
    "orderId": "12345",
    "estimatedTime": "30 minutes",
    "driverName": "John Doe"
  }
  ```

### 4. General (`general`)
- **Icon:** Primary color bell
- **Use Cases:** System messages, account updates, announcements
- **Example Data:**
  ```json
  {
    "message": "Your profile has been verified"
  }
  ```

---

## Data Models

### User Model (Updated)
```javascript
{
  name: String,
  email: String,
  mobile: String,
  password: String,
  fcmToken: String, // FCM token for push notifications
  loyalty_points: Number,
  // ... other fields
}
```

### Notification Model
```javascript
{
  title: String (required),
  body: String (required),
  imageUrl: String,
  type: String (enum: order, promotion, delivery, general),
  data: Object, // Custom data payload
  targetType: String (enum: all, specific, topic),
  targetUsers: [ObjectId], // Array of user IDs (for specific targeting)
  targetTopic: String, // Topic name (for topic targeting)
  status: String (enum: pending, sent, failed),
  sentAt: Date,
  failureReason: String,
  totalRecipients: Number,
  successCount: Number,
  failureCount: Number,
  createdBy: ObjectId (required), // Admin who created the notification
  deleted: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

---

## Best Practices

### 1. FCM Token Management
- Update FCM token on every app launch
- Remove FCM token on logout
- Handle token refresh on the client side

### 2. Notification Content
- Keep titles concise (max 50 characters)
- Keep body messages clear (max 150 characters)
- Use appropriate notification types
- Include relevant data for deep linking

### 3. Targeting
- Use "all" for important announcements
- Use "specific" for personalized messages
- Use "topic" for segmented campaigns

### 4. Error Handling
- Monitor failure rates
- Retry failed notifications if needed
- Clean up invalid FCM tokens

### 5. Testing
- Test with different device states (foreground, background, terminated)
- Verify deep linking functionality
- Test with multiple devices

---

## Error Codes

- `400` - Bad Request (missing or invalid parameters)
- `401` - Unauthorized (invalid or missing authentication token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `500` - Internal Server Error

---

## Rate Limiting

All admin notification endpoints are subject to rate limiting:
- **App endpoints:** 100 requests per 15 minutes per user
- **Admin endpoints:** 500 requests per 15 minutes per admin

---

## Support

For issues or questions:
1. Check the [FCM_NOTIFICATIONS.md](./FCM_NOTIFICATIONS.md) for Flutter implementation
2. Review Firebase Console for delivery logs
3. Check server logs for detailed error messages

---

## Changelog

### Version 1.0.0 (2025-11-01)
- Initial FCM notification system implementation
- App endpoints for FCM token management
- Admin endpoints for sending notifications
- Support for multiple targeting types (all, specific, topic)
- Notification history and statistics
- Four notification types with custom icons
