# 🔐 One Atta Backend - Authentication API Documentation

## 📖 Overview

The One Atta Backend uses **OTP-based authentication** without passwords for both login and registration flows. This system provides secure, mobile-first authentication using SMS OTP verification.

## 🏗️ Base URL

```
http://localhost:5000/api/app/auth
```
z
## 🛡️ Security Features

- **Rate Limiting**: Auth endpoints are protected with rate limiting
- **JWT Tokens**: Secure token-based sessions (30-day expiry)
- **Mobile Verification**: OTP verification via SMS (MSG91)
- **Test Mode**: Development testing with fixed OTP
- **Account Protection**: Soft-delete and verification status checks

---

## 📱 Login Flow (Existing Users)

### 1. Send Login OTP

Sends OTP to an existing user's mobile number for login.

**Endpoint:** `POST /login/otp/send`

**Rate Limited:** ✅ (30 requests per 15 minutes)

**Authentication Required:** ❌

#### Request Body

```json
{
  "mobile": "9876543210"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mobile` | string | ✅ | Mobile number (with or without +91 prefix) |

#### Response (Success)

```json
{
  "success": true,
  "message": "Login OTP sent successfully",
  "data": {
    "requestId": "msg91-request-id",
    "message": "OTP sent successfully"
  }
}
```

#### Response (Test Mode)

```json
{
  "success": true,
  "message": "Login OTP sent successfully",
  "data": {
    "requestId": "mobile-test-request",
    "testOtp": "123456",
    "message": "OTP sent successfully"
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Mobile number is required"
}
```

```json
{
  "success": false,
  "message": "Failed to send OTP"
}
```

---

### 2. Verify Login OTP

Verifies OTP and logs in the existing user.

**Endpoint:** `POST /login/otp/verify`

**Rate Limited:** ✅ (30 requests per 15 minutes)

**Authentication Required:** ❌

#### Request Body

```json
{
  "mobile": "9876543210",
  "otp": "123456"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mobile` | string | ✅ | Mobile number used for OTP |
| `otp` | string | ✅ | 6-digit OTP received via SMS |

#### Response (Success)

```json
{
  "success": true,
  "message": "Login OTP verified successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "mobile": "+919876543210",
    "userId": "64f5a1b2c3d4e5f6g7h8i9j0",
    "user": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+919876543210",
      "role": "user",
      "profile_picture": null,
      "loyalty_points": 150,
      "liked_recipes": ["64f5a1b2c3d4e5f6g7h8i9j1", "64f5a1b2c3d4e5f6g7h8i9j2"]
    },
    "message": "Welcome back! You've been logged in successfully."
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Mobile and OTP are required"
}
```

```json
{
  "success": false,
  "message": "Invalid OTP"
}
```

```json
{
  "success": false,
  "message": "User not found. Please register first."
}
```

---

## 📝 Registration Flow (New Users)

### 3. Send Registration OTP

Sends OTP for new user registration after validating user doesn't already exist.

**Endpoint:** `POST /register/otp/send`

**Rate Limited:** ✅ (30 requests per 15 minutes)

**Authentication Required:** ❌

#### Request Body

```json
{
  "mobile": "9876543210",
  "name": "John Doe",
  "email": "john@example.com"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mobile` | string | ✅ | Mobile number (with or without +91 prefix) |
| `name` | string | ✅ | Full name of the user |
| `email` | string | ✅ | Email address |

#### Response (Success)

```json
{
  "success": true,
  "message": "Registration OTP sent successfully",
  "data": {
    "requestId": "msg91-request-id",
    "message": "OTP sent successfully"
  }
}
```

#### Response (Test Mode)

```json
{
  "success": true,
  "message": "Registration OTP sent successfully",
  "data": {
    "requestId": "mobile-test-request",
    "testOtp": "123456",
    "message": "OTP sent successfully"
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Mobile number, name, and email are required"
}
```

```json
{
  "success": false,
  "message": "User with this mobile number already exists. Please login."
}
```

```json
{
  "success": false,
  "message": "User with this email already exists. Please login."
}
```

---

### 4. Verify Registration OTP

Verifies OTP and creates a new user account.

**Endpoint:** `POST /register/otp/verify`

**Rate Limited:** ✅ (30 requests per 15 minutes)

**Authentication Required:** ❌

#### Request Body

```json
{
  "mobile": "9876543210",
  "otp": "123456",
  "name": "John Doe",
  "email": "john@example.com"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mobile` | string | ✅ | Mobile number used for OTP |
| `otp` | string | ✅ | 6-digit OTP received via SMS |
| `name` | string | ✅ | Full name of the user |
| `email` | string | ✅ | Email address |

#### Response (Success)

```json
{
  "success": true,
  "message": "Registration completed successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "mobile": "+919876543210",
    "userId": "64f5a1b2c3d4e5f6g7h8i9j0",
    "user": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+919876543210",
      "role": "user",
      "profile_picture": null,
      "loyalty_points": 0,
      "liked_recipes": []
    },
    "message": "Account created successfully! Welcome!"
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Mobile, OTP, name, and email are required"
}
```

```json
{
  "success": false,
  "message": "Invalid OTP"
}
```

```json
{
  "success": false,
  "message": "User already exists. Please login."
}
```

---

## 👤 Profile Management

### 5. Get User Profile

Retrieves the authenticated user's profile information including addresses.

**Endpoint:** `GET /profile`

**Rate Limited:** ❌

**Authentication Required:** ✅ (Bearer Token)

#### Request Headers

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response (Success)

```json
{
  "success": true,
  "message": "User profile fetched successfully",
  "data": {
    "user": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "+919876543210",
      "isVerified": true,
      "isProfileComplete": true,
      "role": "user",
      "loyalty_points": 150,
      "profile_picture": "https://s3.amazonaws.com/profile.jpg",
      "liked_recipes": ["64f5a1b2c3d4e5f6g7h8i9j1", "64f5a1b2c3d4e5f6g7h8i9j2"],
      "addresses": [
        {
          "_id": "64f5a1b2c3d4e5f6g7h8i9j1",
          "label": "Home",
          "address_line1": "123 Main St",
          "city": "Mumbai",
          "state": "Maharashtra",
          "postal_code": "400001",
          "is_default": true
        }
      ],
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Access denied. No token provided."
}
```

```json
{
  "success": false,
  "message": "Token expired. Please login again."
}
```

```json
{
  "success": false,
  "message": "Account not verified. Please verify your mobile number."
}
```

---

## 🔑 Password Management (Legacy Support)

### 6. Forgot Password

Sends a password reset link to the user's email.

**Endpoint:** `POST /forgot-password`

**Rate Limited:** ❌

**Authentication Required:** ❌

#### Request Body

```json
{
  "email": "john@example.com"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | ✅ | Registered email address |

#### Response (Success)

```json
{
  "success": true,
  "message": "Password reset link sent to your email",
  "data": {}
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "User not found"
}
```

---

### 7. Reset Password

Resets password using the token received via email.

**Endpoint:** `POST /reset-password`

**Rate Limited:** ❌

**Authentication Required:** ❌

#### Request Body

```json
{
  "token": "resetTokenFromEmail",
  "newPassword": "newSecurePassword123"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | ✅ | Reset token from email |
| `newPassword` | string | ✅ | New password (min 6 characters) |

#### Response (Success)

```json
{
  "success": true,
  "message": "Password reset successfully",
  "data": {
    "user": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "email": "john@example.com",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

---

### 8. Change Password

Changes password for authenticated users.

**Endpoint:** `POST /change-password`

**Rate Limited:** ❌

**Authentication Required:** ✅ (Bearer Token)

#### Request Headers

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Request Body

```json
{
  "oldPassword": "currentPassword123",
  "newPassword": "newSecurePassword123"
}
```

#### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `oldPassword` | string | ✅ | Current password |
| `newPassword` | string | ✅ | New password (min 6 characters) |

#### Response (Success)

```json
{
  "success": true,
  "message": "Password changed successfully",
  "data": {
    "user": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "email": "john@example.com",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

#### Error Responses

```json
{
  "success": false,
  "message": "Old password is incorrect"
}
```

---

## 🔧 Environment Configuration

### Required Environment Variables

```env
# JWT Configuration
JWT_SECRET=your-super-secret-key

# MSG91 OTP Configuration
MSG91_AUTH_KEY=your-msg91-auth-key
MSG91_FLOW_ID=your-msg91-template-id
USE_TEST_OTP=true  # Set to false in production

# Rate Limiting (Optional)
RATE_WINDOW_MS_AUTH=900000  # 15 minutes
RATE_MAX_AUTH=30           # Max requests per window
```

### Test Mode Configuration

When `USE_TEST_OTP=true`:
- Fixed test OTP: `123456`
- No actual SMS sent
- All OTP verifications accept `123456`
- Suitable for development and testing

---

## 📱 Mobile Number Formatting

The system automatically handles various mobile number formats:

| Input Format | Stored Format | Description |
|--------------|---------------|-------------|
| `9876543210` | `+919876543210` | Auto-adds country code |
| `919876543210` | `+919876543210` | Adds + prefix |
| `+919876543210` | `+919876543210` | Already formatted |

---

## 🛡️ Security Middleware

### Rate Limiting

Authentication endpoints are protected with rate limiting:
- **Window:** 15 minutes
- **Max Requests:** 30 per window per IP
- **Applies to:** Login/Register OTP endpoints

### JWT Token Protection

Protected routes require valid JWT tokens:
- **Format:** `Authorization: Bearer <token>`
- **Expiry:** 30 days
- **Validation:** User exists, verified, not deleted
- **Payload:** `{ id: userId, role: userRole }`

---

## 📊 User Data Model

### User Schema

```javascript
{
  _id: ObjectId,
  name: String,
  email: String (unique, lowercase),
  mobile: String (unique, +91 prefix),
  password: String (optional, for legacy support),
  isVerified: Boolean (default: false),
  isProfileComplete: Boolean (default: true for new registrations),
  role: String (enum: ["user", "admin", "manager"], default: "user"),
  loyalty_points: Number (default: 0),
  profile_picture: String,
  liked_recipes: [ObjectId] (references to Recipe model),
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  deleted: Boolean (default: false),
  createdAt: Date,
  updatedAt: Date
}
```

### Virtual Relations

- **addresses**: User's delivery addresses
- **loyaltyTransactions**: Points transaction history
- **liked_recipes**: Array of Recipe ObjectIds that the user has liked

### Field Descriptions

- **liked_recipes**: Array of Recipe document IDs that the user has liked through the Recipe API. This field is populated when users interact with the `/recipes/:id/like` endpoint. New users start with an empty array.

---

## 🚀 Getting Started

### 1. Send Registration OTP
```bash
curl -X POST http://localhost:5000/api/auth/register/otp/send \
  -H "Content-Type: application/json" \
  -d '{
    "mobile": "9876543210",
    "name": "John Doe",
    "email": "john@example.com"
  }'
```

### 2. Verify and Register
```bash
curl -X POST http://localhost:5000/api/auth/register/otp/verify \
  -H "Content-Type: application/json" \
  -d '{
    "mobile": "9876543210",
    "otp": "123456",
    "name": "John Doe",
    "email": "john@example.com"
  }'
```

### 3. Access Protected Endpoints
```bash
curl -X GET http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## ❗ Error Handling

### Standard Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "data": {} // Optional error details
}
```

### Common HTTP Status Codes

- `200` - Success
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (user doesn't exist)
- `429` - Too Many Requests (rate limited)
- `500` - Internal Server Error

---

## 📞 Support

For API support or issues:
- Check environment variables configuration
- Verify MSG91 credentials and balance
- Review rate limiting settings
- Check JWT secret configuration

### Related Documentation

- **Recipe API**: For liked recipes functionality, see `RECIPE_API_DOCS.md`
- **Blend API**: For blend-related operations, see `BLEND_API_DOCS.md`
- **Ingredient API**: For ingredient management, see `INGREDIENT_API_DOCS.md`

---

**Last Updated:** September 5, 2025  
**API Version:** 1.0  
**Documentation Version:** 1.1
