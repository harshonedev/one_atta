# Blend API Documentation

## Overview
The Blend API allows users to create, manage, and share custom flour blends with various ingredients. Users can track pricing changes, share blends with others, and subscribe to public blends.

## Base URL
```
/api/blends
```

## Authentication
Most endpoints require Bearer token authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Data Models

### Blend Object
```json
{
  "id": "string",
  "name": "string",
  "additives": [
    {
      "ingredient": "ObjectId",
      "percentage": "number",
      "original_details": {
        "sku": "string",
        "name": "string", 
        "price_per_kg": "number"
      }
    }
  ],
  "created_by": "ObjectId",
  "share_code": "string",
  "share_count": "number",
  "is_public": "boolean",
  "price_per_kg": "number",
  "total_price": "number",
  "expiry_days": "number",
  "deleted": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Additive Object
```json
{
  "ingredient": "ObjectId (required)",
  "percentage": "number (required, min: 0.1, max: 100)"
}
```

---

## Endpoints

### 1. Get All Public Blends
```http
GET /api/blends
```

**Description:** Retrieve all publicly available blends.

**Authentication:** None required

**Request Parameters:** None

**Response:**
```json
{
  "success": true,
  "message": "Fetched all blends",
  "data": {
    "blends": [
      {
        "id": "64a7b8c9d1e2f3a4b5c6d7e8",
        "name": "Multigrain Blend",
        "additives": [...],
        "created_by": {
          "id": "64a7b8c9d1e2f3a4b5c6d7e9",
          "name": "John Doe"
        },
        "share_code": "JOH1234",
        "share_count": 5,
        "is_public": true,
        "price_per_kg": 85.50,
        "expiry_days": 30,
        "createdAt": "2023-07-07T10:30:00.000Z",
        "updatedAt": "2023-07-07T10:30:00.000Z"
      }
    ]
  }
}
```

**Error Responses:**
- `500` - Internal server error

---

### 2. Create Blend
```http
POST /api/blends
```

**Description:** Create a new custom blend.

**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "name": "My Custom Blend",
  "additives": [
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7e8",
      "percentage": 50
    },
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7e9",
      "percentage": 30
    },
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7ea",
      "percentage": 20
    }
  ],
  "is_public": false,
  "weight_kg": 5
}
```

**Required Fields:**
- `additives` (array): At least one additive with valid ingredient ID and percentage
- `additives[].ingredient` (ObjectId): Valid ingredient ID
- `additives[].percentage` (number): Between 0.1 and 100

**Optional Fields:**
- `name` (string): Defaults to "Multigrain Blend"
- `is_public` (boolean): Defaults to false
- `weight_kg` (number): For total price calculation

**Response:**
```json
{
  "success": true,
  "message": "Blend created successfully",
  "data": {
    "blend": {
      "id": "64a7b8c9d1e2f3a4b5c6d7e8",
      "name": "My Custom Blend",
      "additives": [
        {
          "ingredient": "64a7b8c9d1e2f3a4b5c6d7e8",
          "percentage": 50,
          "original_details": {
            "sku": "ING-WHE-1234",
            "name": "Wheat Flour",
            "price_per_kg": 45.00
          }
        }
      ],
      "created_by": "64a7b8c9d1e2f3a4b5c6d7e9",
      "share_code": "JOH5678",
      "share_count": 0,
      "is_public": false,
      "price_per_kg": 85.50,
      "total_price": 427.50,
      "expiry_days": 30,
      "deleted": false,
      "createdAt": "2023-07-07T10:30:00.000Z",
      "updatedAt": "2023-07-07T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**
- `400` - Invalid request data or ingredient percentages don't add up correctly
- `401` - Unauthorized (invalid or missing token)
- `404` - One or more ingredients not found
- `500` - Internal server error

---

### 3. Get Blend Details with Price Analysis
```http
GET /api/blends/:id
```

**Description:** Get detailed information about a specific blend including current vs original pricing analysis.

**Authentication:** Required (Bearer token)

**Path Parameters:**
- `id` (string): Blend ID

**Response:**
```json
{
  "id": "64a7b8c9d1e2f3a4b5c6d7e8",
  "name": "My Custom Blend",
  "additives": [
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7e8",
      "percentage": 50,
      "original_details": {
        "sku": "ING-WHE-1234",
        "name": "Wheat Flour",
        "price_per_kg": 45.00
      }
    }
  ],
  "created_by": "64a7b8c9d1e2f3a4b5c6d7e9",
  "share_code": "JOH5678",
  "share_count": 0,
  "is_public": false,
  "price_per_kg": 85.50,
  "total_price": 427.50,
  "expiry_days": 30,
  "priceAnalysis": [
    {
      "ingredientId": "64a7b8c9d1e2f3a4b5c6d7e8",
      "percentageChange": 5.56,
      "status": "increased",
      "currentPrice": 47.50,
      "originalPrice": 45.00
    }
  ],
  "blendPriceComparison": {
    "currentPricePerKg": 90.25,
    "originalPricePerKg": 85.50,
    "percentageChange": 5.56,
    "status": "increased"
  },
  "pricing": {
    "current": {
      "perKg": 90.25
    },
    "original": {
      "perKg": 85.50
    }
  },
  "createdAt": "2023-07-07T10:30:00.000Z",
  "updatedAt": "2023-07-07T10:30:00.000Z"
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `404` - Blend not found
- `500` - Internal server error

---

### 4. Share Blend
```http
POST /api/blends/:id/share
```

**Description:** Share a blend and increment its share count.

**Authentication:** Required (Bearer token)

**Path Parameters:**
- `id` (string): Blend ID

**Request Body:** None

**Response:**
```json
{
  "success": true,
  "message": "Blend shared successfully",
  "data": {
    "share_code": "JOH5678"
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `404` - Blend not found
- `500` - Internal server error

---

### 5. Subscribe to Blend
```http
POST /api/blends/:id/subscribe
```

**Description:** Subscribe to a blend (logs the subscription action in blend history).

**Authentication:** Required (Bearer token)

**Path Parameters:**
- `id` (string): Blend ID

**Request Body:** None

**Response:**
```json
{
  "success": true,
  "message": "Subscribed to blend successfully",
  "data": {
    "message": "Subscribed"
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `404` - Blend not found
- `500` - Internal server error

---

### 6. Update Blend
```http
PUT /api/blends/:id
```

**Description:** Update a blend (only the creator can update their blend).

**Authentication:** Required (Bearer token)

**Path Parameters:**
- `id` (string): Blend ID

**Request Body:**
```json
{
  "name": "Updated Blend Name",
  "base_grain": "Wheat",
  "additives": [
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7e8",
      "percentage": 60
    },
    {
      "ingredient": "64a7b8c9d1e2f3a4b5c6d7e9",
      "percentage": 40
    }
  ],
  "is_public": true,
  "price_per_kg": 95.00
}
```

**Optional Fields:**
- `name` (string): New blend name
- `base_grain` (string): Base grain type
- `additives` (array): Updated additives list
- `is_public` (boolean): Public visibility
- `price_per_kg` (number): Manual price override

**Response:**
```json
{
  "success": true,
  "message": "Blend updated successfully",
  "data": {
    "blend": {
      "id": "64a7b8c9d1e2f3a4b5c6d7e8",
      "name": "Updated Blend Name",
      "additives": [...],
      "created_by": "64a7b8c9d1e2f3a4b5c6d7e9",
      "share_code": "JOH5678",
      "share_count": 0,
      "is_public": true,
      "price_per_kg": 95.00,
      "expiry_days": 30,
      "deleted": false,
      "createdAt": "2023-07-07T10:30:00.000Z",
      "updatedAt": "2023-07-07T11:45:00.000Z"
    }
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not authorized to edit this blend)
- `404` - Blend not found
- `500` - Internal server error

---

### 7. Get Blend by Share Code
```http
GET /api/blends/by-share-code/:share_code
```

**Description:** Retrieve a public blend using its share code.

**Authentication:** None required

**Path Parameters:**
- `share_code` (string): Blend share code (format: XXX#### where XXX are letters and #### are digits)

**Response:**
```json
{
  "success": true,
  "message": "Blend fetched by share code",
  "data": {
    "blend": {
      "id": "64a7b8c9d1e2f3a4b5c6d7e8",
      "name": "Shared Blend",
      "additives": [...],
      "created_by": {
        "id": "64a7b8c9d1e2f3a4b5c6d7e9",
        "name": "John Doe"
      },
      "share_code": "JOH5678",
      "share_count": 15,
      "is_public": true,
      "price_per_kg": 85.50,
      "expiry_days": 30,
      "createdAt": "2023-07-07T10:30:00.000Z",
      "updatedAt": "2023-07-07T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**
- `404` - Blend not found or not public
- `500` - Internal server error

---

## Authentication Errors

All protected endpoints may return these authentication-related errors:

### 401 Unauthorized
```json
{
  "success": false,
  "message": "No token provided"
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
  "message": "Invalid token"
}
```

```json
{
  "success": false,
  "message": "User not found"
}
```

```json
{
  "success": false,
  "message": "Account has been deactivated"
}
```

```json
{
  "success": false,
  "message": "Account not verified. Please verify your mobile number."
}
```

---

## Common Error Response Format

All error responses follow this format:
```json
{
  "success": false,
  "message": "Error description",
  "statusCode": 400
}
```

## Business Rules

1. **Ingredient Percentages:** Must be between 0.1 and 100
2. **Blend Creation:** Automatically calculates price based on ingredient prices and percentages
3. **Share Codes:** Auto-generated using first 3 letters of creator's name + 4 random digits
4. **Price Tracking:** Original ingredient prices are stored for price comparison
5. **Authorization:** Only blend creators can update their blends
6. **Public Access:** Only public blends can be accessed via share codes
7. **Blend History:** All actions (create, view, share, subscribe) are logged for tracking

## Price Calculation Logic

### Blend Price Calculation
- `price_per_kg` = Sum of (ingredient_price_per_kg × percentage ÷ 100) for all additives
- `total_price` = price_per_kg × weight_kg (if weight provided)

### Price Comparison
- Compares original prices (stored when blend was created) vs current ingredient prices
- Calculates percentage change: `((current_price - original_price) / original_price) × 100`
- Status can be: "increased", "decreased", or "unchanged"

## Notes

- All endpoints use JSON for request and response bodies
- Timestamps are in ISO 8601 format
- ObjectIds are MongoDB ObjectId strings
- Price values are in currency units (assumed to be the system's base currency)
- Share codes are case-sensitive
- Blend names default to "Multigrain Blend" if not provided
