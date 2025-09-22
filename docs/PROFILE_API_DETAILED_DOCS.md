# 👤 User Profile Management API Documentation

## 📖 Overview
This API provides comprehensive user profile management functionality with integrated loyalty points system. Users can view and update their personal information, manage profile pictures, and track loyalty rewards.

## 🌐 Base Information
- **Base URL**: `/api/auth`
- **Authentication**: JWT Bearer Token required
- **Content-Type**: `application/json`
- **Version**: 1.0

---

## 🔐 Authentication
All profile endpoints require JWT authentication. Include the token in the request header:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

# 📋 API Endpoints

## 1. Get User Profile

### **GET** `/profile`

Retrieves the authenticated user's complete profile information including personal details, addresses, liked recipes, and current loyalty points balance.

#### **Request**
```http
GET /api/auth/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### **Headers**
| Header | Type | Required | Description |
|--------|------|----------|-------------|
| Authorization | string | Yes | JWT Bearer token |
| Content-Type | string | Yes | application/json |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "User profile fetched successfully",
  "data": {
    "user": {
      "_id": "64f8b123456789abcdef0123",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "mobile": "9123456789",
      "isVerified": true,
      "isProfileComplete": true,
      "role": "user",
      "loyalty_points": 275,
      "profile_picture": "https://s3.amazonaws.com/one-atta-bucket/user-profiles/uuid-image.jpg",
      "liked_recipes": [
        "64f8b123456789abcdef0456",
        "64f8b123456789abcdef0789"
      ],
      "addresses": [
        {
          "_id": "64f8b123456789abcdef0321",
          "user": "64f8b123456789abcdef0123",
          "type": "home",
          "address_line_1": "123 Main Street",
          "address_line_2": "Apartment 4B",
          "city": "Mumbai",
          "state": "Maharashtra",
          "pincode": "400001",
          "country": "India",
          "is_default": true,
          "deleted": false,
          "createdAt": "2024-09-15T10:30:00.000Z",
          "updatedAt": "2024-09-15T10:30:00.000Z"
        }
      ],
      "createdAt": "2024-09-10T08:15:00.000Z",
      "updatedAt": "2024-09-22T14:22:00.000Z",
      "id": "64f8b123456789abcdef0123"
    }
  }
}
```

#### **Response Fields**
| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique user identifier |
| name | string | User's display name |
| email | string | User's email address |
| mobile | string | User's mobile number |
| isVerified | boolean | Whether user has verified their account |
| isProfileComplete | boolean | Whether user has completed their profile setup |
| role | string | User role (user/admin/manager) |
| loyalty_points | number | Current loyalty points balance |
| profile_picture | string | URL to user's profile image |
| liked_recipes | array | Array of liked recipe IDs |
| addresses | array | User's addresses (non-deleted only) |

#### **Error Responses**

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Not authorized, token failed",
  "stack": "Error details..."
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "User not found"
}
```

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Server error occurred"
}
```

#### **cURL Example**
```bash
curl -X GET "https://api.oneatta.com/api/auth/profile" \
  -H "Authorization: Bearer your_jwt_token_here" \
  -H "Content-Type: application/json"
```



---

## 2. Update User Profile

### **PUT** `/profile`

Updates the authenticated user's profile information. Only specified fields will be updated, and sensitive fields are protected from modification.

#### **Request**
```http
PUT /api/auth/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "John Smith",
  "email": "john.smith@example.com",
  "mobile": "9876543210",
  "profile_picture": "https://s3.amazonaws.com/one-atta-bucket/user-profiles/new-image.jpg"
}
```

#### **Request Body**
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| name | string | No | 1-100 chars | User's display name |
| email | string | No | Valid email format, unique | User's email address |
| mobile | string | No | 10 digits, unique | User's mobile number |
| profile_picture | string | No | Valid URL | URL to profile image |

#### **Allowed Fields**
✅ **Can Update:**
- `name` - User's display name
- `email` - Email address (must be unique)
- `mobile` - Mobile number (must be unique)
- `profile_picture` - Profile image URL

🚫 **Protected Fields (Auto-filtered):**
- `role` - User role
- `loyalty_points` - Loyalty points balance
- `isVerified` - Verification status
- `password` - User password
- `createdAt` - Creation timestamp

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {
      "_id": "64f8b123456789abcdef0123",
      "name": "John Smith",
      "email": "john.smith@example.com",
      "mobile": "9876543210",
      "isVerified": true,
      "isProfileComplete": true,
      "role": "user",
      "loyalty_points": 275,
      "profile_picture": "https://s3.amazonaws.com/one-atta-bucket/user-profiles/new-image.jpg",
      "liked_recipes": [
        "64f8b123456789abcdef0456"
      ],
      "addresses": [
        {
          "_id": "64f8b123456789abcdef0321",
          "type": "home",
          "address_line_1": "123 Main Street",
          "city": "Mumbai",
          "state": "Maharashtra",
          "pincode": "400001",
          "is_default": true
        }
      ],
      "createdAt": "2024-09-10T08:15:00.000Z",
      "updatedAt": "2024-09-22T16:45:00.000Z",
      "id": "64f8b123456789abcdef0123"
    }
  }
}
```

#### **Error Responses**

**400 Bad Request - Email Already Exists**
```json
{
  "success": false,
  "message": "Email already exists"
}
```

**400 Bad Request - Mobile Already Exists**
```json
{
  "success": false,
  "message": "Mobile number already exists"
}
```

**400 Bad Request - Validation Error**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    }
  ]
}
```

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "User not found"
}
```

#### **Update Examples**

**Update Name Only**
```json
{
  "name": "John Smith Jr."
}
```

**Update Email and Mobile**
```json
{
  "email": "newemail@example.com",
  "mobile": "9987654321"
}
```

**Update Profile Picture**
```json
{
  "profile_picture": "https://s3.amazonaws.com/bucket/user-profiles/new-avatar.jpg"
}
```

**Complete Profile Update**
```json
{
  "name": "John Smith",
  "email": "john.smith@newdomain.com",
  "mobile": "9876543210",
  "profile_picture": "https://s3.amazonaws.com/bucket/user-profiles/updated-photo.jpg"
}
```

#### **cURL Example**
```bash
curl -X PUT "https://api.oneatta.com/api/auth/profile" \
  -H "Authorization: Bearer your_jwt_token_here" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith",
    "email": "john.smith@example.com",
    "mobile": "9876543210"
  }'
```



---

# 🎁 Loyalty Points API Documentation

## Base URL
```
/api/loyalty
```

## Authentication
All loyalty endpoints require JWT authentication:
```http
Authorization: Bearer <your_jwt_token>
```

---

## 1. Earn Points from Order

### **POST** `/earn/order`

Awards points to users based on their order amount and current loyalty settings.

#### **Request**
```http
POST /api/loyalty/earn/order
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "amount": 1500,
  "orderId": "64f8b123456789abcdef0456"
}
```

#### **Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| amount | number | Yes | Order amount in currency units |
| orderId | string | Yes | Unique order identifier |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Points earned from order",
  "data": {
    "success": true,
    "points": 75,
    "monetaryValue": 7.5,
    "message": "Points successfully awarded"
  }
}
```

#### **Response (Order Rewards Disabled)**
```json
{
  "success": true,
  "message": "Points earned from order",
  "data": {
    "success": false,
    "points": 0,
    "message": "Order rewards are disabled."
  }
}
```

#### **Error Responses**
```json
{
  "success": false,
  "message": "Amount and orderId are required"
}
```

---

## 2. Earn Points from Sharing Blend

### **POST** `/earn/share`

Awards fixed points when users share their custom blends.

#### **Request**
```http
POST /api/loyalty/earn/share
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "blendId": "64f8b123456789abcdef0789"
}
```

#### **Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| blendId | string | Yes | ID of the shared blend |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Points earned from sharing blend",
  "data": {
    "points": 10,
    "transactionId": "64f8b123456789abcdef0321"
  }
}
```

#### **Error Responses**
```json
{
  "success": false,
  "message": "Blend sharing rewards are disabled"
}
```

---

## 3. Earn Points from Review

### **POST** `/earn/review`

Awards fixed points when users submit product/recipe reviews.

#### **Request**
```http
POST /api/loyalty/earn/review
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "reviewId": "64f8b123456789abcdef0654"
}
```

#### **Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| reviewId | string | Yes | ID of the submitted review |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Points earned from review",
  "data": {
    "points": 5,
    "transactionId": "64f8b123456789abcdef0987"
  }
}
```

#### **Error Responses**
```json
{
  "success": false,
  "message": "Review rewards are disabled"
}
```

---

## 4. Redeem Points on Order

### **POST** `/redeem`

Allows users to redeem their accumulated loyalty points for discounts on orders.

#### **Request**
```http
POST /api/loyalty/redeem
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "orderId": "64f8b123456789abcdef0456",
  "pointsToRedeem": 100
}
```

#### **Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| orderId | string | Yes | ID of the order for redemption |
| pointsToRedeem | number | Yes | Number of points to redeem (positive integer) |

#### **Response (200 OK)**
```json
{
  "success": true,
  "message": "Points redeemed successfully",
  "data": {
    "redeemed": 100,
    "remainingPoints": 175,
    "transactionId": "64f8b123456789abcdef0654"
  }
}
```

#### **Error Responses**
```json
// Insufficient Points
{
  "success": false,
  "message": "Insufficient loyalty points"
}

// Invalid Points Amount
{
  "success": false,
  "message": "Invalid points to redeem"
}
```

---

## 5. Get Loyalty Transaction History

### **GET** `/history/:userId`

Retrieves the complete loyalty transaction history for a specific user.

#### **Request**
```http
GET /api/loyalty/history/64f8b123456789abcdef0123
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### **URL Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | string | Yes | User ID to fetch history for |

#### **Response (200 OK)**
```json
{
  "success": true,
  "history": [
    {
      "_id": "64f8b123456789abcdef0987",
      "user": "64f8b123456789abcdef0123",
      "reason": "ORDER",
      "reference_id": "64f8b123456789abcdef0456",
      "points": 75,
      "description": "Order of ₹1500 → 75 points (5%)",
      "earnedAt": "2024-09-22T14:30:00.000Z"
    },
    {
      "_id": "64f8b123456789abcdef0654",
      "user": "64f8b123456789abcdef0123",
      "reason": "SHARE",
      "reference_id": "64f8b123456789abcdef0789",
      "points": 10,
      "description": "Blend shared → 10 points",
      "earnedAt": "2024-09-21T10:15:00.000Z"
    },
    {
      "_id": "64f8b123456789abcdef0321",
      "user": "64f8b123456789abcdef0123",
      "reason": "REVIEW",
      "reference_id": "64f8b123456789abcdef0654",
      "points": 5,
      "description": "Review submitted → 5 points",
      "earnedAt": "2024-09-20T16:45:00.000Z"
    },
    {
      "_id": "64f8b123456789abcdef0159",
      "user": "64f8b123456789abcdef0123",
      "reason": "REDEEM",
      "reference_id": "64f8b123456789abcdef0852",
      "points": -50,
      "description": "Redeemed 50 points on order #64f8b123456789abcdef0852",
      "redeemedAt": "2024-09-19T12:20:00.000Z"
    }
  ]
}
```

#### **Transaction Types**
| Reason | Points | Description |
|--------|--------|-------------|
| ORDER | Positive | Points earned from order amount percentage |
| SHARE | Positive | Fixed points for sharing blends |
| REVIEW | Positive | Fixed points for submitting reviews |
| REDEEM | Negative | Points deducted for redemptions |

#### **Error Responses**
```json
{
  "success": false,
  "message": "User not found"
}
```

---

## Loyalty Settings Integration

The loyalty system behavior is controlled by admin-configurable settings:

### **Current Settings Structure**
```json
{
  "order_percentage": 5,
  "review_points": 5,
  "share_points": 10,
  "point_value": 0.1,
  "enable_order_rewards": true,
  "enable_blend_sharing": true,
  "enable_reviews": true
}
```

### **Settings Impact on APIs**
- **order_percentage**: Determines points calculation for orders (amount × percentage / 100)
- **review_points**: Fixed points awarded for reviews
- **share_points**: Fixed points awarded for sharing
- **point_value**: Monetary value per point for redemption calculations
- **enable_***: Toggle flags that can disable specific reward types

---

# 📸 Profile Picture Management

## Complete Profile Picture Update Flow

### **Step 1: Upload Image**
```http
POST /api/upload/profile-image
Authorization: Bearer <jwt_token>
Content-Type: multipart/form-data

Form Data:
profile_image: <file> (JPEG/PNG/JPG, max 5MB)
```

**Response:**
```json
{
  "success": true,
  "message": "Profile image uploaded successfully",
  "data": {
    "imageUrl": "https://s3.amazonaws.com/bucket/user-profiles/uuid-filename.jpg"
  }
}
```

### **Step 2: Update Profile with New Image URL**
```http
PUT /api/auth/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "profile_picture": "https://s3.amazonaws.com/bucket/user-profiles/uuid-filename.jpg"
}
```

### **Complete Flow Example**
```bash
# Step 1: Upload image
curl -X POST "https://api.oneatta.com/api/upload/profile-image" \
  -H "Authorization: Bearer your_jwt_token" \
  -F "profile_image=@/path/to/image.jpg"

# Step 2: Update profile with returned URL
curl -X PUT "https://api.oneatta.com/api/auth/profile" \
  -H "Authorization: Bearer your_jwt_token" \
  -H "Content-Type: application/json" \
  -d '{"profile_picture": "https://returned-s3-url.jpg"}'
```

---

# 🛡️ Security & Validation

## Field-Level Security

### **Allowed Updates**
```javascript
const allowedFields = ['name', 'email', 'mobile', 'profile_picture'];
```

### **Protected Fields (Auto-filtered)**
```javascript
const protectedFields = [
  'role',           // User role
  'loyalty_points', // Points balance
  'isVerified',     // Verification status  
  'password',       // User password
  'createdAt',      // Creation date
  'updatedAt',      // Last update
  '_id'             // User ID
];
```

## Validation Rules

### **Email Validation**
- Must be valid email format
- Must be unique across all users
- Case-insensitive uniqueness check

### **Mobile Validation**
- Must be valid phone number format
- Must be unique across all users
- Supports international formats

### **Name Validation**
- 1-100 characters
- Trims whitespace
- Allows letters, numbers, spaces

### **Profile Picture Validation**
- Must be valid URL
- Supports HTTP/HTTPS protocols
- No file size validation (handled by upload endpoint)

## Authentication Security

### **JWT Token Validation**
- Token must be valid and not expired
- User must exist in database
- Token payload must contain valid user ID

### **Request Validation**
- Content-Type must be application/json
- Request body size limits apply
- Rate limiting on update requests

---

# 📱 Integration Guidelines

## Frontend Integration
- Use standard HTTP clients (fetch, axios, etc.)
- Store JWT token securely (localStorage, secure cookies)
- Handle authentication errors by redirecting to login
- Implement proper error handling for all API calls

## Mobile App Integration
- Use appropriate HTTP client libraries
- Store tokens in secure storage (Keychain, Keystore)
- Handle token expiration gracefully
- Implement offline support where needed

---

# 📊 Response Status Codes

| Code | Status | Description | When it occurs |
|------|--------|-------------|----------------|
| 200 | OK | Success | Profile retrieved/updated successfully |
| 400 | Bad Request | Validation Error | Invalid data, duplicate email/mobile |
| 401 | Unauthorized | Authentication Failed | Invalid/missing/expired token |
| 404 | Not Found | User Not Found | User ID doesn't exist |
| 413 | Payload Too Large | File Too Large | Profile image exceeds size limit |
| 415 | Unsupported Media Type | Invalid File Type | Invalid profile image format |
| 422 | Unprocessable Entity | Validation Failed | Data validation errors |
| 429 | Too Many Requests | Rate Limited | Too many update requests |
| 500 | Internal Server Error | Server Error | Database/server issues |

---

# 💡 Best Practices

## Error Handling
- Implement specific error handling for common scenarios
- Show user-friendly messages for validation errors
- Handle authentication failures gracefully

## Data Validation
- Validate data on both client and server side
- Implement proper email and mobile format validation
- Check field length constraints before submission

## Security Considerations
- Never store JWT tokens in localStorage for sensitive applications
- Use HTTPS for all API communications
- Implement proper CORS policies
- Validate and sanitize all user inputs

## Performance Optimization
- Implement caching for frequently accessed profile data
- Use optimistic updates for better user experience
- Minimize API calls by batching updates when possible

---

This comprehensive API documentation provides everything needed to integrate user profile management with loyalty points functionality in your application.