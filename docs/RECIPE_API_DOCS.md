# Recipe API Documentation

This document provides comprehensive information about the Recipe API endpoints, including authentication requirements, request/response formats, and usage examples.

## Base URL
```
/recipes
```

## Authentication

Some endpoints require authentication using Bearer tokens. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Authentication Middleware
The `protect` middleware is used to authenticate users:
- Validates JWT tokens from the Authorization header
- Populates `req.user` with authenticated user data
- Returns 401 for invalid/missing tokens

## Recipe Model Schema

```javascript
{
  title: String (required),
  ingredients: [
    {
      name: String (required),      // e.g., "salt"
      quantity: Number (required),  // e.g., 2
      unit: String (required)       // e.g., "gm", "kg", "liter"
    }
  ],
  steps: [String],                  // Array of cooking steps
  description: String,
  blend_used: ObjectId,            // Reference to Blend model
  video_url: String,
  likes: Number (default: 0),
  recipe_picture: String,          // Image URL
  created_by: ObjectId (required), // Reference to User model
  createdAt: Date,
  updatedAt: Date
}
```

## API Endpoints

### 1. Get All Recipes

**GET** `/recipes`

Retrieves all recipes with populated blend and user information.

#### Request
- **Authentication**: None required
- **Headers**: None required

#### Response

**Success (200)**
```json
{
  "success": true,
  "message": "All recipes fetched successfully",
  "data": [
    {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
      "title": "Spicy Chicken Curry",
      "ingredients": [
        {
          "name": "chicken",
          "quantity": 500,
          "unit": "gm"
        },
        {
          "name": "onions",
          "quantity": 2,
          "unit": "pieces"
        }
      ],
      "steps": [
        "Heat oil in a pan",
        "Add onions and cook until golden",
        "Add chicken and spices"
      ],
      "description": "A delicious spicy chicken curry recipe",
      "blend_used": {
        "_id": "64f5a1b2c3d4e5f6g7h8i9j1",
        "name": "Garam Masala Blend",
        "description": "Traditional Indian spice blend"
      },
      "video_url": "https://youtube.com/watch?v=example",
      "likes": 25,
      "recipe_picture": "https://s3.amazonaws.com/recipe-images/curry.jpg",
      "created_by": {
        "_id": "64f5a1b2c3d4e5f6g7h8i9j2",
        "name": "Chef John",
        "email": "chef@example.com"
      },
      "createdAt": "2023-09-04T10:30:00.000Z",
      "updatedAt": "2023-09-04T10:30:00.000Z"
    }
  ]
}
```

### 2. Get Recipe by ID

**GET** `/recipes/:id`

Retrieves a specific recipe by its ID with populated references.

#### Request
- **Authentication**: None required
- **Parameters**: 
  - `id` (string, required): MongoDB ObjectId of the recipe

#### Response

**Success (200)**
```json
{
  "success": true,
  "message": "Recipe fetched successfully",
  "data": {
    "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
    "title": "Spicy Chicken Curry",
    "ingredients": [
      {
        "name": "chicken",
        "quantity": 500,
        "unit": "gm"
      }
    ],
    "steps": ["Heat oil in a pan", "Add onions and cook until golden"],
    "description": "A delicious spicy chicken curry recipe",
    "blend_used": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j1",
      "name": "Garam Masala Blend"
    },
    "video_url": "https://youtube.com/watch?v=example",
    "likes": 25,
    "recipe_picture": "https://s3.amazonaws.com/recipe-images/curry.jpg",
    "created_by": {
      "_id": "64f5a1b2c3d4e5f6g7h8i9j2",
      "name": "Chef John"
    },
    "createdAt": "2023-09-04T10:30:00.000Z",
    "updatedAt": "2023-09-04T10:30:00.000Z"
  }
}
```

**Error (404)**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

### 3. Create Recipe

**POST** `/recipes`

Creates a new recipe.

#### Request
- **Authentication**: None required (user info populated if authenticated)
- **Headers**: 
  - `Content-Type: application/json`
- **Body**:

```json
{
  "title": "Vegetable Stir Fry",
  "ingredients": [
    {
      "name": "mixed vegetables",
      "quantity": 300,
      "unit": "gm"
    },
    {
      "name": "soy sauce",
      "quantity": 2,
      "unit": "tbsp"
    }
  ],
  "steps": [
    "Heat oil in wok",
    "Add vegetables and stir fry for 5 minutes",
    "Add soy sauce and serve"
  ],
  "description": "Quick and healthy vegetable stir fry",
  "blend_used": "64f5a1b2c3d4e5f6g7h8i9j1",
  "video_url": "https://youtube.com/watch?v=example",
  "recipe_picture": "https://s3.amazonaws.com/recipe-images/stirfry.jpg"
}
```

#### Response

**Success (200)**
```json
{
  "success": true,
  "message": "Recipe created successfully",
  "data": {
    "_id": "64f5a1b2c3d4e5f6g7h8i9j3",
    "title": "Vegetable Stir Fry",
    "ingredients": [
      {
        "name": "mixed vegetables",
        "quantity": 300,
        "unit": "gm"
      }
    ],
    "steps": ["Heat oil in wok", "Add vegetables and stir fry"],
    "description": "Quick and healthy vegetable stir fry",
    "blend_used": "64f5a1b2c3d4e5f6g7h8i9j1",
    "video_url": "https://youtube.com/watch?v=example",
    "likes": 0,
    "recipe_picture": "https://s3.amazonaws.com/recipe-images/stirfry.jpg",
    "created_by": "000000000000000000000000",
    "createdAt": "2023-09-04T11:00:00.000Z",
    "updatedAt": "2023-09-04T11:00:00.000Z"
  }
}
```

**Error (400)**
```json
{
  "success": false,
  "message": "Validation error: Title is required"
}
```

### 4. Update Recipe

**PUT** `/recipes/:id`

Updates an existing recipe.

#### Request
- **Authentication**: Required (Bearer token)
- **Headers**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **Parameters**: 
  - `id` (string, required): MongoDB ObjectId of the recipe
- **Body**: Any recipe fields to update

```json
{
  "title": "Updated Recipe Title",
  "description": "Updated description",
  "likes": 30
}
```

#### Response

**Success (200)**
```json
{
  "success": true,
  "message": "Recipe updated successfully",
  "data": {
    "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
    "title": "Updated Recipe Title",
    "description": "Updated description",
    "likes": 30,
    "updatedAt": "2023-09-04T12:00:00.000Z"
  }
}
```

**Error (401)**
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```

**Error (404)**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

### 5. Delete Recipe

**DELETE** `/recipes/:id`

Deletes a recipe by ID.

#### Request
- **Authentication**: Required (Bearer token)
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Parameters**: 
  - `id` (string, required): MongoDB ObjectId of the recipe

#### Response

**Success (200)**
```json
{
  "success": true,
  "message": "Recipe deleted successfully",
  "data": {
    "_id": "64f5a1b2c3d4e5f6g7h8i9j0",
    "title": "Deleted Recipe"
  }
}
```

**Error (401)**
```json
{
  "success": false,
  "message": "No token provided"
}
```

**Error (404)**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

## Error Responses

All endpoints follow a consistent error response format:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Common HTTP Status Codes

- **200**: Success
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (authentication required)
- **404**: Not Found (resource doesn't exist)
- **500**: Internal Server Error

## Request Examples

### Using cURL

#### Get All Recipes
```bash
curl -X GET http://localhost:3000/recipes
```

#### Create Recipe
```bash
curl -X POST http://localhost:3000/recipes \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Recipe",
    "ingredients": [{"name": "salt", "quantity": 1, "unit": "tsp"}],
    "steps": ["Mix ingredients"],
    "description": "Test recipe description"
  }'
```

#### Update Recipe (Authenticated)
```bash
curl -X PUT http://localhost:3000/recipes/64f5a1b2c3d4e5f6g7h8i9j0 \
  -H "Authorization: Bearer your_jwt_token" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Recipe Title"}'
```

#### Delete Recipe (Authenticated)
```bash
curl -X DELETE http://localhost:3000/recipes/64f5a1b2c3d4e5f6g7h8i9j0 \
  -H "Authorization: Bearer your_jwt_token"
```

### Using JavaScript/Fetch

#### Get Recipe by ID
```javascript
fetch('/recipes/64f5a1b2c3d4e5f6g7h8i9j0')
  .then(response => response.json())
  .then(data => console.log(data));
```

#### Create Recipe with Authentication
```javascript
fetch('/recipes', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  },
  body: JSON.stringify({
    title: 'New Recipe',
    ingredients: [
      { name: 'ingredient1', quantity: 100, unit: 'gm' }
    ],
    steps: ['Step 1', 'Step 2'],
    description: 'Recipe description'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

## Notes

1. **User Assignment**: When creating recipes without authentication, `created_by` defaults to "000000000000000000000000"
2. **Population**: GET endpoints automatically populate `blend_used` and `created_by` references
3. **Timestamps**: All recipes include `createdAt` and `updatedAt` timestamps
4. **Validation**: The `title` field is required for recipe creation
5. **Ingredients Structure**: Each ingredient must have `name`, `quantity`, and `unit` fields
6. **Authentication**: Update and delete operations require valid JWT authentication

## Related Models

- **Blend**: Referenced in `blend_used` field
- **User**: Referenced in `created_by` field

For more information about authentication and user management, refer to the Auth API documentation.
