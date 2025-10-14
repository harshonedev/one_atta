# Product API Documentation

## Overview
This document describes the Product API endpoints for both admin operations and app user operations in the One Atta Backend system.

## What's New (October 15, 2025)
✨ **Out of Stock Feature Added**
- New `outOfStock` field added to Product model (default: `false`)
- Admin endpoint: `PATCH /:id/toggle-outofstock` to toggle stock status
- Admin filtering: Query parameter `outOfStock=true/false` to filter products
- Product stats now include `inStockProducts` and `outOfStockProducts` counts
- App endpoints include out-of-stock products with the `outOfStock` field for UI display
- **Important**: Out-of-stock products are visible in app responses (not filtered out) so the frontend can display "Out of Stock" badges

### Key Differences: `is_available` vs `outOfStock`
| Field | Purpose | Controlled By | App Visibility |
|-------|---------|---------------|----------------|
| `is_available` | Product is published/active | Admin (product management) | Only `true` values shown |
| `outOfStock` | Product is temporarily out of stock | Admin/Inventory | Both `true` and `false` shown |

---

## Admin API Endpoints

**Base URL:** `/api/admin/products`

**Authentication:** All endpoints require authentication and admin/manager role.

---

## Endpoints

### 1. Create Product
**POST** `/`

Creates a new product in the system.

**Request Body:**
```json
{
  "name": "Premium Wheat Flour",
  "description": "High-quality wheat flour perfect for baking",
  "isSeasonal": false,
  "is_available": true,
  "outOfStock": false,
  "price_per_kg": 45.50,
  "prod_picture": "https://example.com/flour.jpg",
  "nutritional_info": {
    "calories": 364,
    "protein": 10.3,
    "carbs": 76.3
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "sku": "PRO-PRE-1234",
    "name": "Premium Wheat Flour",
    "description": "High-quality wheat flour perfect for baking",
    "isSeasonal": false,
    "is_available": true,
    "outOfStock": false,
    "price_per_kg": 45.50,
    "prod_picture": "https://example.com/flour.jpg",
    "nutritional_info": {
      "calories": 364,
      "protein": 10.3,
      "carbs": 76.3
    },
    "createdAt": "2023-07-05T10:30:00.000Z",
    "updatedAt": "2023-07-05T10:30:00.000Z"
  }
}
```

---

### 2. Get All Products
**GET** `/`

Retrieves all products with optional filtering, searching, sorting, and pagination.

**Query Parameters:**
- `is_available` (boolean): Filter by availability status
- `isSeasonal` (boolean): Filter by seasonal status
- `outOfStock` (boolean): Filter by stock status (true = out of stock, false = in stock)
- `search` (string): Search in name, SKU, or description
- `minPrice` (number): Minimum price filter
- `maxPrice` (number): Maximum price filter
- `sortBy` (string): Sort field (name, price_per_kg, createdAt, etc.)
- `sortOrder` (string): Sort direction (asc, desc)
- `page` (number): Page number for pagination
- `limit` (number): Items per page (default: 10)

**Example Request:**
```
GET /api/admin/products?is_available=true&outOfStock=false&search=wheat&sortBy=price_per_kg&sortOrder=asc&page=1&limit=5
```

**Response:**
```json
{
  "success": true,
  "message": "Fetched products",
  "data": {
    "products": [
      {
        "id": "64a1b2c3d4e5f6789012345",
        "sku": "PRO-WHE-1234",
        "name": "Wheat Flour",
        "description": "Premium quality wheat flour",
        "isSeasonal": false,
        "is_available": true,
        "outOfStock": false,
        "price_per_kg": 42.00,
        "prod_picture": "https://example.com/wheat.jpg",
        "nutritional_info": {
          "calories": 364,
          "protein": 10.3,
          "carbs": 76.3
        },
        "createdAt": "2023-07-05T10:30:00.000Z",
        "updatedAt": "2023-07-05T10:30:00.000Z"
      }
    ],
    "totalCount": 15,
    "currentPage": 1,
    "totalPages": 3
  }
}
```

---

### 3. Get Product by ID
**GET** `/:id`

Retrieves a specific product by its ID.

**Parameters:**
- `id` (string): Product ID

**Response:**
```json
{
  "success": true,
  "message": "Fetched product",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "sku": "PRO-WHE-1234",
    "name": "Wheat Flour",
    "description": "Premium quality wheat flour",
    "isSeasonal": false,
    "is_available": true,
    "outOfStock": false,
    "price_per_kg": 42.00,
    "prod_picture": "https://example.com/wheat.jpg",
    "nutritional_info": {
      "calories": 364,
      "protein": 10.3,
      "carbs": 76.3
    },
    "createdAt": "2023-07-05T10:30:00.000Z",
    "updatedAt": "2023-07-05T10:30:00.000Z"
  }
}
```

---

### 4. Get Product by SKU
**GET** `/sku/:sku`

Retrieves a specific product by its SKU code.

**Parameters:**
- `sku` (string): Product SKU code (e.g., PRO-WHE-1234)

**Response:**
Same as Get Product by ID

---

### 5. Update Product
**PUT** `/:id`

Updates an existing product.

**Parameters:**
- `id` (string): Product ID

**Request Body:**
```json
{
  "name": "Updated Wheat Flour",
  "price_per_kg": 48.00,
  "is_available": false,
  "outOfStock": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "sku": "PRO-UPD-1234",
    "name": "Updated Wheat Flour",
    "price_per_kg": 48.00,
    "is_available": false,
    "outOfStock": true,
    // ... other fields
  }
}
```

---

### 6. Delete Product
**DELETE** `/:id`

Deletes a product from the system.

**Parameters:**
- `id` (string): Product ID

**Response:**
```json
{
  "success": true,
  "message": "Product deleted successfully",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "name": "Deleted Product Name"
    // ... other fields of deleted product
  }
}
```

---

### 7. Toggle Product Availability
**PATCH** `/:id/toggle-availability`

Toggles the availability status of a product (enables/disables).

**Parameters:**
- `id` (string): Product ID

**Response:**
```json
{
  "success": true,
  "message": "Product enabled successfully",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "name": "Wheat Flour",
    "is_available": true,
    // ... other fields
  }
}
```

---

### 8. Toggle Product Out of Stock Status
**PATCH** `/:id/toggle-outofstock`

Toggles the out-of-stock status of a product.

**Parameters:**
- `id` (string): Product ID

**Response:**
```json
{
  "success": true,
  "message": "Product marked as out of stock successfully",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "name": "Wheat Flour",
    "is_available": true,
    "outOfStock": true,
    // ... other fields
  }
}
```

**Note:** When toggled to `true`, the product is marked as out of stock. In the app, products with `outOfStock: true` will be displayed with an "Out of Stock" badge.

---

### 9. Bulk Update Products
**PATCH** `/bulk-update`

Updates multiple products at once.

**Request Body:**
```json
{
  "productIds": [
    "64a1b2c3d4e5f6789012345",
    "64a1b2c3d4e5f6789012346"
  ],
  "updateData": {
    "is_available": false,
    "isSeasonal": true,
    "outOfStock": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Successfully updated 2 products",
  "data": {
    "modifiedCount": 2,
    "matchedCount": 2
  }
}
```

---

### 10. Search Products
**GET** `/search`

Searches products by name, SKU, or description.

**Query Parameters:**
- `query` (string, required): Search term
- `limit` (number, optional): Maximum results to return

**Example Request:**
```
GET /api/admin/products/search?query=wheat&limit=5
```

**Response:**
```json
{
  "success": true,
  "message": "Search results",
  "data": [
    {
      "id": "64a1b2c3d4e5f6789012345",
      "sku": "PRO-WHE-1234",
      "name": "Wheat Flour",
      "description": "Premium quality wheat flour",
      "price_per_kg": 42.00,
      // ... other fields
    }
  ]
}
```

---

### 11. Get Product Statistics
**GET** `/stats`

Retrieves statistical information about products.

**Response:**
```json
{
  "success": true,
  "message": "Product statistics",
  "data": {
    "totalProducts": 25,
    "availableProducts": 20,
    "unavailableProducts": 5,
    "inStockProducts": 18,
    "outOfStockProducts": 7,
    "seasonalProducts": 8,
    "averagePrice": 45.75,
    "minPrice": 15.00,
    "maxPrice": 120.00
  }
}
```

---

## App API Endpoints

**Base URL:** `/api/app/products`

**Authentication:** No authentication required for public product viewing.

**Note:** 
- App endpoints only return products that are available (`is_available: true`)
- Products with `outOfStock: true` are **included** in responses to allow the app to display "Out of Stock" status to users
- The app frontend should display appropriate UI (badges, disabled buttons) based on the `outOfStock` field

### 1. Get All Products (App)
**GET** `/`

Retrieves all available products for app users with optional filtering, searching, sorting, and pagination.

**Query Parameters:**
- `isSeasonal` (boolean): Filter by seasonal status
- `search` (string): Search in name, SKU, or description
- `minPrice` (number): Minimum price filter
- `maxPrice` (number): Maximum price filter
- `sortBy` (string): Sort field (name, price_per_kg, createdAt, etc.)
- `sortOrder` (string): Sort direction (asc, desc)
- `page` (number): Page number for pagination
- `limit` (number): Items per page (default: 12)

**Example Request:**
```
GET /api/app/products?search=wheat&sortBy=price_per_kg&sortOrder=asc&page=1&limit=8
```

**Response:**
```json
{
  "success": true,
  "message": "Fetched products",
  "data": {
    "products": [
      {
        "id": "64a1b2c3d4e5f6789012345",
        "sku": "PRO-WHE-1234",
        "name": "Wheat Flour",
        "description": "Premium quality wheat flour",
        "isSeasonal": false,
        "is_available": true,
        "outOfStock": false,
        "price_per_kg": 42.00,
        "prod_picture": "https://example.com/wheat.jpg",
        "nutritional_info": {
          "calories": 364,
          "protein": 10.3,
          "carbs": 76.3
        },
        "createdAt": "2023-07-05T10:30:00.000Z",
        "updatedAt": "2023-07-05T10:30:00.000Z"
      },
      {
        "id": "64a1b2c3d4e5f6789012346",
        "sku": "PRO-RIC-5678",
        "name": "Rice Flour",
        "description": "Fine quality rice flour",
        "isSeasonal": false,
        "is_available": true,
        "outOfStock": true,
        "price_per_kg": 55.00,
        "prod_picture": "https://example.com/rice.jpg",
        "nutritional_info": {
          "calories": 366,
          "protein": 6.0,
          "carbs": 80.0
        },
        "createdAt": "2023-07-05T10:30:00.000Z",
        "updatedAt": "2023-07-05T10:30:00.000Z"
      }
    ],
    "totalCount": 12,
    "currentPage": 1,
    "totalPages": 2
  }
}
```

**Note:** In the example above, the second product has `outOfStock: true`, which should trigger the app to display an "Out of Stock" badge and disable the "Add to Cart" functionality.

### 2. Get Product by ID (App)
**GET** `/:id`

Retrieves a specific available product by its ID for app users.

**Parameters:**
- `id` (string): Product ID

**Response:**
```json
{
  "success": true,
  "message": "Fetched product",
  "data": {
    "id": "64a1b2c3d4e5f6789012345",
    "sku": "PRO-WHE-1234",
    "name": "Wheat Flour",
    "description": "Premium quality wheat flour",
    "isSeasonal": false,
    "is_available": true,
    "outOfStock": false,
    "price_per_kg": 42.00,
    "prod_picture": "https://example.com/wheat.jpg",
    "nutritional_info": {
      "calories": 364,
      "protein": 10.3,
      "carbs": 76.3
    },
    "createdAt": "2023-07-05T10:30:00.000Z",
    "updatedAt": "2023-07-05T10:30:00.000Z"
  }
}
```

**Note:** If the product has `outOfStock: true`, it will still be returned (not a 404). The app should check this field and display appropriate UI.

**Error Response (Product not available or not found):**
```json
{
  "success": false,
  "message": "Product not found or unavailable"
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Access denied. No token provided"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Access denied. Admin role required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Product not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## Data Models

### Product Schema
```javascript
{
  sku: {
    type: String,
    required: true,
    unique: true,
    format: "PRO-XXX-9999"
  },
  name: {
    type: String,
    required: true,
    unique: true
  },
  description: {
    type: String
  },
  isSeasonal: {
    type: Boolean,
    default: false
  },
  is_available: {
    type: Boolean,
    default: true
  },
  outOfStock: {
    type: Boolean,
    default: false
  },
  price_per_kg: {
    type: Number,
    required: true,
    minimum: 0
  },
  prod_picture: {
    type: String
  },
  nutritional_info: {
    calories: { type: Number, minimum: 0 },
    protein: { type: Number, minimum: 0 },
    carbs: { type: Number, minimum: 0 }
  },
  createdAt: { type: Date },
  updatedAt: { type: Date }
}
```

---

## Notes

### Admin vs App Endpoints:
- **Admin endpoints** (`/api/admin/products`) provide full CRUD operations and can access all products regardless of availability or stock status
- **App endpoints** (`/api/app/products`) are read-only and only show available products (`is_available: true`) to end users
- **Admin endpoints** require authentication and admin/manager role
- **App endpoints** are publicly accessible for viewing products
- **Out of Stock Handling**: 
  - Admin can filter products by `outOfStock` status and toggle stock status
  - App includes out-of-stock products in responses but displays them with appropriate UI indicators

### Stock Status Management:
- **`is_available`**: Controls whether a product is published/active in the system (admin decision)
- **`outOfStock`**: Indicates current inventory status (temporary condition)
- Products can be `is_available: true` but `outOfStock: true` - these are shown in the app with "Out of Stock" messaging
- Admin can toggle stock status using the `/toggle-outofstock` endpoint

### General Notes:
1. **SKU Generation**: SKU codes are automatically generated based on product names in the format `PRO-XXX-9999` where XXX are the first 3 letters of the product name and 9999 is a random 4-digit number.

2. **Authentication**: Admin endpoints require a valid JWT token and admin/manager role.

3. **Validation**: Product names must be unique, prices must be non-negative, and SKU format is strictly validated.

4. **Search**: The search functionality is case-insensitive and searches across name, SKU, and description fields.

5. **Pagination**: 
   - Admin endpoints: Default 10 items per page, or all results if no pagination specified
   - App endpoints: Default 12 items per page (optimized for grid display)

6. **Bulk Operations**: Only available in admin endpoints for management purposes.

7. **File Uploads**: Product images should be uploaded using the upload endpoints before creating/updating products.

8. **Availability Filter**: App endpoints automatically filter to show only available products (`is_available: true`), while admin endpoints can access all products.

9. **Out of Stock Display**: 
   - App endpoints include out-of-stock products in responses (unlike unavailable products which are filtered out)
   - Frontend should check the `outOfStock` field to display appropriate UI (badges, disabled buttons, etc.)
   - Example UI implementations:
     - Show "Out of Stock" badge on product cards
     - Disable "Add to Cart" button
     - Display expected restock date (if available)
     - Allow users to sign up for back-in-stock notifications

10. **Toggle Endpoints**: 
    - `/toggle-availability` - Controls product visibility (publish/unpublish)
    - `/toggle-outofstock` - Controls inventory status (in stock/out of stock)