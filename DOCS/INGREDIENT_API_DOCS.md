# Ingredient API Documentation

## Overview
The Ingredient API provides endpoints for managing flour ingredients used in blend creation. The API is split into two sections:
- **App API**: Public endpoints for users to view ingredients
- **Admin API**: Administrative endpoints for managing ingredients (CRUD operations)

---

## App API (User Access)

### Base URL
```
/api/ingredients
```

### Authentication
No authentication required for app endpoints.

---

### 1. Get All Ingredients (App)
```http
GET /api/ingredients
```

**Description:** Retrieve all available ingredients for users to view when creating blends.

**Authentication:** None required

**Request Parameters:** None

**Response:**
```json
{
  "success": true,
  "message": "Fetched Ingredients",
  "data": [
    {
      "id": "64a7b8c9d1e2f3a4b5c6d7e8",
      "sku": "ING-WHE-1234",
      "name": "Wheat Flour",
      "description": "High-quality whole wheat flour",
      "isSeasonal": false,
      "is_available": true,
      "price_per_kg": 45.00,
      "ing_picture": "https://example.com/wheat-flour.jpg",
      "nutritional_info": {
        "calories": 340,
        "protein": 13.2,
        "carbs": 71.5
      },
      "displayName": "Wheat Flour (ING-WHE-1234)",
      "createdAt": "2023-07-07T10:30:00.000Z",
      "updatedAt": "2023-07-07T10:30:00.000Z"
    },
    {
      "id": "64a7b8c9d1e2f3a4b5c6d7e9",
      "sku": "ING-RIC-5678",
      "name": "Rice Flour",
      "description": "Fine ground rice flour",
      "isSeasonal": false,
      "is_available": true,
      "price_per_kg": 52.00,
      "ing_picture": null,
      "nutritional_info": {
        "calories": 366,
        "protein": 6.0,
        "carbs": 80.0
      },
      "displayName": "Rice Flour (ING-RIC-5678)",
      "createdAt": "2023-07-07T10:31:00.000Z",
      "updatedAt": "2023-07-07T10:31:00.000Z"
    }
  ]
}
```

**Error Responses:**
- `500` - Internal server error

---

## Admin API (Administrative Access)

### Base URL
```
/api/admin/ingredients
```

### Authentication
All admin endpoints require:
1. **Bearer Token Authentication** - Valid JWT token
2. **Admin/Manager Role** - User must have 'admin' or 'manager' role

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

---

### 1. Create Ingredient (Admin)
```http
POST /api/admin/ingredients
```

**Description:** Create a new ingredient in the system.

**Authentication:** Required (Admin/Manager only)

**Request Body:**
```json
{
  "name": "Quinoa Flour",
  "description": "Premium organic quinoa flour",
  "price_per_kg": 120.00,
  "is_available": true,
  "isSeasonal": false,
  "ing_picture": "https://example.com/quinoa-flour.jpg",
  "nutritional_info": {
    "calories": 368,
    "protein": 14.1,
    "carbs": 64.2
  }
}
```

**Required Fields:**
- `name` (string): Ingredient name
- `price_per_kg` (number): Price per kilogram (minimum: 0)

**Optional Fields:**
- `description` (string): Ingredient description
- `is_available` (boolean): Availability status (default: true)
- `isSeasonal` (boolean): Seasonal availability (default: false)
- `ing_picture` (string): Image URL
- `nutritional_info` (object): Nutritional information
  - `calories` (number): Calories per 100g (minimum: 0)
  - `protein` (number): Protein content in grams (minimum: 0)
  - `carbs` (number): Carbohydrate content in grams (minimum: 0)

**Response:**
```json
{
  "success": true,
  "message": "Ingredient created successfully",
  "data": {
    "id": "64a7b8c9d1e2f3a4b5c6d7ea",
    "sku": "ING-QUI-9876",
    "name": "Quinoa Flour",
    "description": "Premium organic quinoa flour",
    "isSeasonal": false,
    "is_available": true,
    "price_per_kg": 120.00,
    "ing_picture": "https://example.com/quinoa-flour.jpg",
    "nutritional_info": {
      "calories": 368,
      "protein": 14.1,
      "carbs": 64.2
    },
    "displayName": "Quinoa Flour (ING-QUI-9876)",
    "createdAt": "2023-07-07T12:00:00.000Z",
    "updatedAt": "2023-07-07T12:00:00.000Z"
  }
}
```

**Error Responses:**
- `400` - Validation error (invalid data)
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not admin or manager)
- `409` - Conflict (duplicate SKU, though this is auto-generated)
- `500` - Internal server error

---

### 2. Get All Ingredients (Admin)
```http
GET /api/admin/ingredients
```

**Description:** Retrieve all ingredients with full administrative details.

**Authentication:** Required (Admin/Manager only)

**Request Parameters:** None

**Response:**
```json
{
  "success": true,
  "message": "Fetched Ingredients",
  "data": [
    {
      "id": "64a7b8c9d1e2f3a4b5c6d7e8",
      "sku": "ING-WHE-1234",
      "name": "Wheat Flour",
      "description": "High-quality whole wheat flour",
      "isSeasonal": false,
      "is_available": true,
      "price_per_kg": 45.00,
      "ing_picture": "https://example.com/wheat-flour.jpg",
      "nutritional_info": {
        "calories": 340,
        "protein": 13.2,
        "carbs": 71.5
      },
      "displayName": "Wheat Flour (ING-WHE-1234)",
      "createdAt": "2023-07-07T10:30:00.000Z",
      "updatedAt": "2023-07-07T10:30:00.000Z"
    }
  ]
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not admin or manager)
- `500` - Internal server error

---

### 3. Get Ingredient by ID (Admin)
```http
GET /api/admin/ingredients/:id
```

**Description:** Retrieve a specific ingredient by its ID.

**Authentication:** Required (Admin/Manager only)

**Path Parameters:**
- `id` (string): Ingredient ID (MongoDB ObjectId)

**Response:**
```json
{
  "success": true,
  "message": "Fetched Ingredients",
  "data": {
    "id": "64a7b8c9d1e2f3a4b5c6d7e8",
    "sku": "ING-WHE-1234",
    "name": "Wheat Flour",
    "description": "High-quality whole wheat flour",
    "isSeasonal": false,
    "is_available": true,
    "price_per_kg": 45.00,
    "ing_picture": "https://example.com/wheat-flour.jpg",
    "nutritional_info": {
      "calories": 340,
      "protein": 13.2,
      "carbs": 71.5
    },
    "displayName": "Wheat Flour (ING-WHE-1234)",
    "createdAt": "2023-07-07T10:30:00.000Z",
    "updatedAt": "2023-07-07T10:30:00.000Z"
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not admin or manager)
- `404` - Ingredient not found
- `500` - Internal server error

---

### 4. Update Ingredient (Admin)
```http
PUT /api/admin/ingredients/:id
```

**Description:** Update an existing ingredient. SKU and timestamps are immutable and cannot be updated.

**Authentication:** Required (Admin/Manager only)

**Path Parameters:**
- `id` (string): Ingredient ID (MongoDB ObjectId)

**Request Body:**
```json
{
  "name": "Premium Wheat Flour",
  "description": "Organic premium whole wheat flour",
  "price_per_kg": 55.00,
  "is_available": true,
  "isSeasonal": false,
  "ing_picture": "https://example.com/premium-wheat-flour.jpg",
  "nutritional_info": {
    "calories": 350,
    "protein": 14.0,
    "carbs": 70.0
  }
}
```

**Updatable Fields:**
- `name` (string): Ingredient name
- `description` (string): Ingredient description
- `price_per_kg` (number): Price per kilogram
- `is_available` (boolean): Availability status
- `isSeasonal` (boolean): Seasonal availability
- `ing_picture` (string): Image URL
- `nutritional_info` (object): Nutritional information

**Immutable Fields:**
- `sku`: Cannot be changed after creation
- `createdAt`: System managed
- `updatedAt`: System managed
- `id`: Cannot be changed

**Response:**
```json
{
  "success": true,
  "message": "Ingredient updated successfully",
  "data": {
    "id": "64a7b8c9d1e2f3a4b5c6d7e8",
    "sku": "ING-WHE-1234",
    "name": "Premium Wheat Flour",
    "description": "Organic premium whole wheat flour",
    "isSeasonal": false,
    "is_available": true,
    "price_per_kg": 55.00,
    "ing_picture": "https://example.com/premium-wheat-flour.jpg",
    "nutritional_info": {
      "calories": 350,
      "protein": 14.0,
      "carbs": 70.0
    },
    "displayName": "Premium Wheat Flour (ING-WHE-1234)",
    "createdAt": "2023-07-07T10:30:00.000Z",
    "updatedAt": "2023-07-07T14:30:00.000Z"
  }
}
```

**Error Responses:**
- `400` - Validation error (invalid data)
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not admin or manager)
- `404` - Ingredient not found
- `500` - Internal server error

---

### 5. Delete Ingredient (Admin)
```http
DELETE /api/admin/ingredients/:id
```

**Description:** Permanently delete an ingredient from the system.

**Authentication:** Required (Admin/Manager only)

**Path Parameters:**
- `id` (string): Ingredient ID (MongoDB ObjectId)

**Request Body:** None

**Response:**
```json
{
  "success": true,
  "message": "Ingredient deleted successfully",
  "data": {
    "id": "64a7b8c9d1e2f3a4b5c6d7e8",
    "sku": "ING-WHE-1234",
    "name": "Wheat Flour",
    "description": "High-quality whole wheat flour",
    "isSeasonal": false,
    "is_available": true,
    "price_per_kg": 45.00,
    "ing_picture": "https://example.com/wheat-flour.jpg",
    "nutritional_info": {
      "calories": 340,
      "protein": 13.2,
      "carbs": 71.5
    },
    "displayName": "Wheat Flour (ING-WHE-1234)",
    "createdAt": "2023-07-07T10:30:00.000Z",
    "updatedAt": "2023-07-07T10:30:00.000Z"
  }
}
```

**Error Responses:**
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (not admin or manager)
- `404` - Ingredient not found
- `500` - Internal server error

---

## Data Models

### Ingredient Object
```json
{
  "id": "string (ObjectId)",
  "sku": "string (auto-generated, format: ING-XXX-9999)",
  "name": "string (required)",
  "description": "string (optional)",
  "isSeasonal": "boolean (default: false)",
  "is_available": "boolean (default: true)",
  "price_per_kg": "number (required, min: 0)",
  "ing_picture": "string (optional, URL)",
  "nutritional_info": {
    "calories": "number (optional, min: 0)",
    "protein": "number (optional, min: 0)",
    "carbs": "number (optional, min: 0)"
  },
  "displayName": "string (virtual field: 'name (sku)')",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

---

## Authentication & Authorization

### Role-Based Access Control

**App API:**
- **Public Access**: No authentication required
- **Purpose**: Allow users to browse ingredients for blend creation

**Admin API:**
- **Authentication Required**: Valid JWT token
- **Authorization Required**: User role must be 'admin' or 'manager'
- **Purpose**: Full CRUD operations for ingredient management

### Authentication Errors

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
  "message": "Access denied. Admin or manager privileges required."
}
```

---

## Business Rules

### SKU Generation
- **Format**: `ING-XXX-9999`
- **XXX**: First 3 letters of ingredient name (uppercase, padded with 'X' if needed)
- **9999**: 4 random digits
- **Examples**: 
  - "Wheat Flour" → "ING-WHE-1234"
  - "Rice Flour" → "ING-RIC-5678"
  - "Oat Flour" → "ING-OAT-9012"

### Validation Rules
- **Name**: Required, trimmed
- **Price**: Required, must be ≥ 0
- **Nutritional Info**: All values must be ≥ 0
- **SKU**: Auto-generated, immutable after creation
- **Description**: Optional, trimmed

### Search Capabilities
- Text search index on `name` and `sku` fields
- Static method `findBySKU(sku)` available for SKU-based queries

---

## Error Response Format

All error responses follow this format:
```json
{
  "success": false,
  "message": "Error description",
  "statusCode": 400
}
```

---

## Usage Examples

### Creating an Ingredient (Admin)
```bash
curl -X POST http://localhost:3000/api/admin/ingredients \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Almond Flour",
    "description": "Fine ground almond flour",
    "price_per_kg": 250.00,
    "is_available": true,
    "nutritional_info": {
      "calories": 576,
      "protein": 21.2,
      "carbs": 19.6
    }
  }'
```

### Getting All Ingredients (App)
```bash
curl -X GET http://localhost:3000/api/ingredients
```

### Updating Ingredient Price (Admin)
```bash
curl -X PUT http://localhost:3000/api/admin/ingredients/64a7b8c9d1e2f3a4b5c6d7e8 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "price_per_kg": 50.00
  }'
```

---

## Notes

- **SKU Uniqueness**: SKUs are auto-generated and guaranteed to be unique
- **Price Updates**: Affect future blend calculations, existing blends retain original prices
- **Soft Delete**: Current implementation uses hard delete; consider implementing soft delete for data integrity
- **Image Upload**: Picture URLs are stored as strings; implement separate upload endpoint for file handling
- **Search**: Text search is available via MongoDB text index
- **Caching**: Consider implementing caching for frequently accessed ingredient data
- **Pagination**: Consider adding pagination for large ingredient lists
