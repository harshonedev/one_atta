# Address API Documentation

## Base URL
All address endpoints require authentication via Bearer token in the Authorization header.

## Endpoints

### 1. Create Address
**POST** `/addresses`

#### Description:
Creates a new address for the authenticated user.

#### Headers:
```
Authorization: Bearer <token>
Content-Type: application/json
```

#### Request Body:
```json
{
  "label": "Home|Work|Apartment|Office|Other",
  "address_line1": "string (required, max 100 chars)",
  "address_line2": "string (optional, max 100 chars)",
  "landmark": "string (optional, max 100 chars)",
  "city": "string (required, max 50 chars)",
  "state": "string (required, max 50 chars)",
  "postal_code": "string (required, max 20 chars)",
  "country": "string (default: 'India', max 50 chars)",
  "recipient_name": "string (required, max 100 chars)",
  "primary_phone": "string (required, 10-15 digits)",
  "secondary_phone": "string (optional, 10-15 digits)",
  "geo": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "is_default": "boolean (default: false)",
  "instructions": "string (optional, max 200 chars)"
}
```

#### Response:
```json
{
  "success": true,
  "message": "Address created successfully",
  "data": {
    "_id": "string",
    "user": "string",
    "label": "string",
    "address_line1": "string",
    "address_line2": "string",
    "landmark": "string",
    "city": "string",
    "state": "string",
    "postal_code": "string",
    "country": "string",
    "recipient_name": "string",
    "primary_phone": "string",
    "secondary_phone": "string",
    "geo": {
      "type": "Point",
      "coordinates": [number, number]
    },
    "is_default": "boolean",
    "instructions": "string",
    "deleted": "boolean",
    "full_address": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

### 2. Get All Addresses
**GET** `/addresses`

#### Description:
Fetches all non-deleted addresses for the authenticated user.

#### Headers:
```
Authorization: Bearer <token>
```

#### Response:
```json
{
  "success": true,
  "message": "Fetched user addresses",
  "data": [
    {
      "_id": "string",
      "user": "string",
      "label": "string",
      "address_line1": "string",
      "address_line2": "string",
      "landmark": "string",
      "city": "string",
      "state": "string",
      "postal_code": "string",
      "country": "string",
      "recipient_name": "string",
      "primary_phone": "string",
      "secondary_phone": "string",
      "geo": {
        "type": "Point",
        "coordinates": [number, number]
      },
      "is_default": "boolean",
      "instructions": "string",
      "deleted": "boolean",
      "full_address": "string",
      "createdAt": "string",
      "updatedAt": "string"
    }
  ]
}
```

### 3. Get Address by ID
**GET** `/addresses/:id`

#### Description:
Fetches a specific non-deleted address by its ID for the authenticated user.

#### Headers:
```
Authorization: Bearer <token>
```

#### Path Parameters:
- `id` - Address ID (ObjectId)

#### Response:
```json
{
  "success": true,
  "message": "Fetched address",
  "data": {
    "_id": "string",
    "user": "string",
    "label": "string",
    "address_line1": "string",
    "address_line2": "string",
    "landmark": "string",
    "city": "string",
    "state": "string",
    "postal_code": "string",
    "country": "string",
    "recipient_name": "string",
    "primary_phone": "string",
    "secondary_phone": "string",
    "geo": {
      "type": "Point",
      "coordinates": [number, number]
    },
    "is_default": "boolean",
    "instructions": "string",
    "deleted": "boolean",
    "full_address": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

### 4. Update Address
**PUT** `/addresses/:id`

#### Description:
Updates an existing address for the authenticated user.

#### Headers:
```
Authorization: Bearer <token>
Content-Type: application/json
```

#### Path Parameters:
- `id` - Address ID (ObjectId)

#### Request Body:
```json
{
  "label": "Home|Work|Apartment|Office|Other",
  "address_line1": "string (max 100 chars)",
  "address_line2": "string (max 100 chars)",
  "landmark": "string (max 100 chars)",
  "city": "string (max 50 chars)",
  "state": "string (max 50 chars)",
  "postal_code": "string (max 20 chars)",
  "country": "string (max 50 chars)",
  "recipient_name": "string (max 100 chars)",
  "primary_phone": "string (10-15 digits)",
  "secondary_phone": "string (10-15 digits)",
  "geo": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "is_default": "boolean",
  "instructions": "string (max 200 chars)"
}
```

#### Response:
```json
{
  "success": true,
  "message": "Address updated successfully",
  "data": {
    "_id": "string",
    "user": "string",
    "label": "string",
    "address_line1": "string",
    "address_line2": "string",
    "landmark": "string",
    "city": "string",
    "state": "string",
    "postal_code": "string",
    "country": "string",
    "recipient_name": "string",
    "primary_phone": "string",
    "secondary_phone": "string",
    "geo": {
      "type": "Point",
      "coordinates": [number, number]
    },
    "is_default": "boolean",
    "instructions": "string",
    "deleted": "boolean",
    "full_address": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

### 5. Delete Address
**DELETE** `/addresses/:id`

#### Description:
Soft deletes an address (marks as deleted) for the authenticated user.

#### Headers:
```
Authorization: Bearer <token>
```

#### Path Parameters:
- `id` - Address ID (ObjectId)

#### Response:
```json
{
  "success": true,
  "message": "Address deleted",
  "data": {
    "_id": "string",
    "user": "string",
    "label": "string",
    "address_line1": "string",
    "address_line2": "string",
    "landmark": "string",
    "city": "string",
    "state": "string",
    "postal_code": "string",
    "country": "string",
    "recipient_name": "string",
    "primary_phone": "string",
    "secondary_phone": "string",
    "geo": {
      "type": "Point",
      "coordinates": [number, number]
    },
    "is_default": "boolean",
    "instructions": "string",
    "deleted": true,
    "full_address": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

## Error Responses

All endpoints may return these error responses:

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Not authorized"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Address not found"
}
```

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error message"
}
```