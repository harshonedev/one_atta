# Feedback System API Documentation

## Overview
The Feedback System allows users to submit feedback, bug reports, feature requests, and complaints. Admins can view, respond to, and manage all feedback submissions.

---

## App-Side Endpoints (User)

### 1. Submit Feedback
**POST** `/api/app/feedback`

Submit new feedback to the system.

**Authentication Required:** Yes

**Request Body:**
```json
{
  "subject": "App crashes on login",
  "message": "When I try to login with my email, the app crashes immediately. This started happening after the last update.",
  "category": "bug",
  "priority": "high",
  "attachments": [
    {
      "url": "https://example.com/screenshot.jpg",
      "type": "image/jpeg"
    }
  ]
}
```

**Field Validations:**
- `subject`: String, 3-200 characters, required
- `message`: String, 10-2000 characters, required
- `category`: Enum ["bug", "feature", "improvement", "complaint", "other"], optional
- `priority`: Enum ["low", "medium", "high"], optional (default: "medium")
- `attachments`: Array of objects with url and type, optional

**Response (201):**
```json
{
  "success": true,
  "message": "Feedback submitted successfully",
  "data": {
    "_id": "feedback123",
    "user": {
      "_id": "user123",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+1234567890"
    },
    "subject": "App crashes on login",
    "message": "When I try to login with my email...",
    "category": "bug",
    "status": "pending",
    "priority": "high",
    "attachments": [],
    "createdAt": "2025-10-14T10:00:00.000Z",
    "updatedAt": "2025-10-14T10:00:00.000Z"
  }
}
```

---

### 2. Get User's Feedback History
**GET** `/api/app/feedback`

Retrieve all feedback submitted by the authenticated user.

**Authentication Required:** Yes

**Query Parameters:**
- `page`: Number (default: 1)
- `limit`: Number (default: 10)
- `status`: String ["pending", "in-review", "resolved", "closed"]

**Example:**
```
GET /api/app/feedback?page=1&limit=10&status=pending
```

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback fetched successfully",
  "data": {
    "feedback": [
      {
        "_id": "feedback123",
        "subject": "App crashes on login",
        "message": "When I try to login...",
        "category": "bug",
        "status": "pending",
        "priority": "high",
        "adminResponse": null,
        "respondedBy": null,
        "respondedAt": null,
        "createdAt": "2025-10-14T10:00:00.000Z",
        "updatedAt": "2025-10-14T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "pages": 3
    }
  }
}
```

---

### 3. Get Specific Feedback by ID
**GET** `/api/app/feedback/:id`

Get details of a specific feedback (user's own only).

**Authentication Required:** Yes

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback fetched successfully",
  "data": {
    "_id": "feedback123",
    "subject": "App crashes on login",
    "message": "When I try to login...",
    "category": "bug",
    "status": "resolved",
    "priority": "high",
    "adminResponse": "Thank you for reporting this. We've fixed the issue in version 2.1.5.",
    "respondedBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "respondedAt": "2025-10-14T15:30:00.000Z",
    "createdAt": "2025-10-14T10:00:00.000Z",
    "updatedAt": "2025-10-14T15:30:00.000Z"
  }
}
```

---

## Admin-Side Endpoints

### 1. Get All Feedback
**GET** `/api/admin/feedback`

Retrieve all feedback submissions with filters.

**Authentication Required:** Yes (Admin/Manager)

**Query Parameters:**
- `page`: Number (default: 1)
- `limit`: Number (default: 10)
- `status`: String ["pending", "in-review", "resolved", "closed"]
- `category`: String ["bug", "feature", "improvement", "complaint", "other"]
- `priority`: String ["low", "medium", "high"]
- `sortBy`: String (default: "-createdAt")

**Example:**
```
GET /api/admin/feedback?status=pending&category=bug&page=1&limit=20
```

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback fetched successfully",
  "data": {
    "feedback": [
      {
        "_id": "feedback123",
        "user": {
          "_id": "user123",
          "name": "John Doe",
          "email": "john@example.com",
          "mobile": "+1234567890"
        },
        "subject": "App crashes on login",
        "message": "When I try to login...",
        "category": "bug",
        "status": "pending",
        "priority": "high",
        "adminResponse": null,
        "respondedBy": null,
        "respondedAt": null,
        "createdAt": "2025-10-14T10:00:00.000Z",
        "updatedAt": "2025-10-14T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "pages": 8
    }
  }
}
```

---

### 2. Get Feedback by ID
**GET** `/api/admin/feedback/:id`

Get details of a specific feedback.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback fetched successfully",
  "data": {
    "_id": "feedback123",
    "user": {
      "_id": "user123",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+1234567890"
    },
    "subject": "App crashes on login",
    "message": "When I try to login...",
    "category": "bug",
    "status": "pending",
    "priority": "high",
    "attachments": [
      {
        "url": "https://example.com/screenshot.jpg",
        "type": "image/jpeg"
      }
    ],
    "createdAt": "2025-10-14T10:00:00.000Z",
    "updatedAt": "2025-10-14T10:00:00.000Z"
  }
}
```

---

### 3. Update Feedback Status
**PATCH** `/api/admin/feedback/:id/status`

Update the status of feedback.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "status": "in-review"
}
```

**Status Options:**
- `pending`: Initial status
- `in-review`: Admin is reviewing
- `resolved`: Issue has been resolved
- `closed`: Feedback is closed

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback status updated successfully",
  "data": {
    "_id": "feedback123",
    "status": "in-review",
    "user": {
      "_id": "user123",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "subject": "App crashes on login",
    "updatedAt": "2025-10-14T11:00:00.000Z"
  }
}
```

---

### 4. Respond to Feedback
**POST** `/api/admin/feedback/:id/respond`

Add an admin response to feedback and mark as resolved.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "response": "Thank you for reporting this bug. We've identified the issue and it will be fixed in the next update scheduled for next week."
}
```

**Field Validations:**
- `response`: String, 10-2000 characters, required

**Response (200):**
```json
{
  "success": true,
  "message": "Response added successfully",
  "data": {
    "_id": "feedback123",
    "user": {
      "_id": "user123",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "subject": "App crashes on login",
    "message": "When I try to login...",
    "status": "resolved",
    "adminResponse": "Thank you for reporting this bug...",
    "respondedBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "respondedAt": "2025-10-14T11:30:00.000Z",
    "updatedAt": "2025-10-14T11:30:00.000Z"
  }
}
```

---

### 5. Delete Feedback
**DELETE** `/api/admin/feedback/:id`

Delete a feedback permanently.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback deleted successfully",
  "data": {
    "_id": "feedback123",
    "subject": "App crashes on login"
  }
}
```

---

### 6. Get Feedback Statistics
**GET** `/api/admin/feedback/stats`

Get overview statistics of all feedback.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback statistics fetched successfully",
  "data": {
    "total": 150,
    "byStatus": [
      { "_id": "pending", "count": 45 },
      { "_id": "in-review", "count": 30 },
      { "_id": "resolved", "count": 60 },
      { "_id": "closed", "count": 15 }
    ],
    "byCategory": [
      { "_id": "bug", "count": 50 },
      { "_id": "feature", "count": 40 },
      { "_id": "improvement", "count": 30 },
      { "_id": "complaint", "count": 20 },
      { "_id": "other", "count": 10 }
    ]
  }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "error": "Subject must be at least 3 characters long"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Not authorized, no token"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Not authorized as admin or manager"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Feedback not found"
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Server error",
  "error": "Error message details"
}
```

---

## Feedback Categories

- **bug**: Report bugs or technical issues
- **feature**: Request new features
- **improvement**: Suggest improvements to existing features
- **complaint**: File a complaint
- **other**: Any other type of feedback

---

## Feedback Status Flow

1. **pending** → Initial submission
2. **in-review** → Admin is reviewing the feedback
3. **resolved** → Issue has been resolved or addressed
4. **closed** → Feedback is closed (no further action)

---

## Priority Levels

- **low**: Non-urgent, minor issues
- **medium**: Standard priority (default)
- **high**: Urgent issues requiring immediate attention
