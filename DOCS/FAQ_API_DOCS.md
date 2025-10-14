# FAQ System API Documentation

## Overview
The FAQ (Frequently Asked Questions) System allows admins to create and manage FAQs, while users can browse, search, and provide feedback on helpful FAQs.

---

## App-Side Endpoints (User)

### 1. Get All Active FAQs
**GET** `/api/app/faqs`

Retrieve all active FAQs with optional filtering.

**Authentication Required:** No (Public)

**Query Parameters:**
- `category`: String ["general", "orders", "delivery", "payment", "account", "products", "loyalty", "other"]
- `page`: Number (default: 1)
- `limit`: Number (default: 50)

**Example:**
```
GET /api/app/faqs?category=orders&page=1&limit=20
```

**Response (200):**
```json
{
  "success": true,
  "message": "FAQs fetched successfully",
  "data": {
    "faqs": [
      {
        "_id": "faq123",
        "question": "How long does delivery take?",
        "answer": "Standard delivery takes 3-5 business days. Express delivery is available for 1-2 days.",
        "category": "delivery",
        "order": 1,
        "isActive": true,
        "viewCount": 1245,
        "helpfulCount": 890,
        "createdAt": "2025-10-01T10:00:00.000Z",
        "updatedAt": "2025-10-01T10:00:00.000Z"
      },
      {
        "_id": "faq124",
        "question": "What payment methods do you accept?",
        "answer": "We accept credit/debit cards, UPI, net banking, and wallet payments.",
        "category": "payment",
        "order": 2,
        "isActive": true,
        "viewCount": 980,
        "helpfulCount": 720,
        "createdAt": "2025-10-01T10:05:00.000Z",
        "updatedAt": "2025-10-01T10:05:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

---

### 2. Get FAQs by Category
**GET** `/api/app/faqs/category/:category`

Retrieve all FAQs for a specific category.

**Authentication Required:** No (Public)

**Path Parameters:**
- `category`: String ["general", "orders", "delivery", "payment", "account", "products", "loyalty", "other"]

**Example:**
```
GET /api/app/faqs/category/orders
```

**Response (200):**
```json
{
  "success": true,
  "message": "FAQs fetched successfully",
  "data": [
    {
      "_id": "faq125",
      "question": "How can I track my order?",
      "answer": "You can track your order from the Orders section in the app. Click on any order to see its tracking details.",
      "category": "orders",
      "order": 1,
      "isActive": true,
      "viewCount": 1500,
      "helpfulCount": 1200,
      "createdAt": "2025-10-01T10:10:00.000Z",
      "updatedAt": "2025-10-01T10:10:00.000Z"
    },
    {
      "_id": "faq126",
      "question": "Can I cancel my order?",
      "answer": "Yes, you can cancel your order within 24 hours of placing it. Go to Orders > Select Order > Cancel Order.",
      "category": "orders",
      "order": 2,
      "isActive": true,
      "viewCount": 1350,
      "helpfulCount": 1100,
      "createdAt": "2025-10-01T10:15:00.000Z",
      "updatedAt": "2025-10-01T10:15:00.000Z"
    }
  ]
}
```

---

### 3. Search FAQs
**GET** `/api/app/faqs/search`

Search for FAQs by keyword in questions or answers.

**Authentication Required:** No (Public)

**Query Parameters:**
- `search`: String (required) - Search term

**Example:**
```
GET /api/app/faqs/search?search=refund
```

**Response (200):**
```json
{
  "success": true,
  "message": "FAQs fetched successfully",
  "data": [
    {
      "_id": "faq127",
      "question": "How do I request a refund?",
      "answer": "To request a refund, go to Orders > Select Order > Request Refund. Refunds are processed within 5-7 business days.",
      "category": "orders",
      "order": 5,
      "isActive": true,
      "viewCount": 890,
      "helpfulCount": 650,
      "createdAt": "2025-10-01T10:20:00.000Z",
      "updatedAt": "2025-10-01T10:20:00.000Z"
    }
  ]
}
```

---

### 4. Mark FAQ as Helpful
**POST** `/api/app/faqs/:id/helpful`

Increment the helpful count for an FAQ.

**Authentication Required:** No (Public)

**Response (200):**
```json
{
  "success": true,
  "message": "Thank you for your feedback",
  "data": {
    "_id": "faq123",
    "question": "How long does delivery take?",
    "helpfulCount": 891
  }
}
```

---

## Admin-Side Endpoints

### 1. Create FAQ
**POST** `/api/admin/faqs`

Create a new FAQ.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "question": "What is the return policy?",
  "answer": "You can return any product within 30 days of delivery if it's in its original condition with tags attached. Go to Orders > Select Order > Return Item to initiate a return.",
  "category": "orders",
  "order": 10,
  "isActive": true
}
```

**Field Validations:**
- `question`: String, 10-500 characters, required
- `answer`: String, 20-5000 characters, required
- `category`: Enum ["general", "orders", "delivery", "payment", "account", "products", "loyalty", "other"], required
- `order`: Number, integer >= 0, optional (default: 0)
- `isActive`: Boolean, optional (default: true)

**Response (201):**
```json
{
  "success": true,
  "message": "FAQ created successfully",
  "data": {
    "_id": "faq128",
    "question": "What is the return policy?",
    "answer": "You can return any product within 30 days...",
    "category": "orders",
    "order": 10,
    "isActive": true,
    "viewCount": 0,
    "helpfulCount": 0,
    "createdBy": "admin123",
    "createdAt": "2025-10-14T12:00:00.000Z",
    "updatedAt": "2025-10-14T12:00:00.000Z"
  }
}
```

---

### 2. Get All FAQs (Admin)
**GET** `/api/admin/faqs`

Retrieve all FAQs including inactive ones.

**Authentication Required:** Yes (Admin/Manager)

**Query Parameters:**
- `category`: String ["general", "orders", "delivery", "payment", "account", "products", "loyalty", "other"]
- `isActive`: Boolean
- `page`: Number (default: 1)
- `limit`: Number (default: 20)
- `sortBy`: String (default: "order")

**Example:**
```
GET /api/admin/faqs?category=orders&isActive=false&page=1&limit=20
```

**Response (200):**
```json
{
  "success": true,
  "message": "FAQs fetched successfully",
  "data": {
    "faqs": [
      {
        "_id": "faq123",
        "question": "How long does delivery take?",
        "answer": "Standard delivery takes 3-5 business days...",
        "category": "delivery",
        "order": 1,
        "isActive": true,
        "viewCount": 1245,
        "helpfulCount": 890,
        "createdBy": {
          "_id": "admin123",
          "name": "Admin User",
          "email": "admin@example.com"
        },
        "updatedBy": {
          "_id": "admin123",
          "name": "Admin User",
          "email": "admin@example.com"
        },
        "createdAt": "2025-10-01T10:00:00.000Z",
        "updatedAt": "2025-10-12T15:30:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

---

### 3. Get FAQ by ID
**GET** `/api/admin/faqs/:id`

Get details of a specific FAQ.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "FAQ fetched successfully",
  "data": {
    "_id": "faq123",
    "question": "How long does delivery take?",
    "answer": "Standard delivery takes 3-5 business days...",
    "category": "delivery",
    "order": 1,
    "isActive": true,
    "viewCount": 1245,
    "helpfulCount": 890,
    "createdBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "updatedBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "createdAt": "2025-10-01T10:00:00.000Z",
    "updatedAt": "2025-10-12T15:30:00.000Z"
  }
}
```

---

### 4. Update FAQ
**PUT** `/api/admin/faqs/:id`

Update an existing FAQ.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "question": "How long does delivery take? (Updated)",
  "answer": "Standard delivery takes 2-4 business days. Express delivery is available for next-day delivery.",
  "category": "delivery",
  "order": 1,
  "isActive": true
}
```

**Field Validations:**
- All fields are optional
- `question`: String, 10-500 characters
- `answer`: String, 20-5000 characters
- `category`: Enum ["general", "orders", "delivery", "payment", "account", "products", "loyalty", "other"]
- `order`: Number, integer >= 0
- `isActive`: Boolean

**Response (200):**
```json
{
  "success": true,
  "message": "FAQ updated successfully",
  "data": {
    "_id": "faq123",
    "question": "How long does delivery take? (Updated)",
    "answer": "Standard delivery takes 2-4 business days...",
    "category": "delivery",
    "order": 1,
    "isActive": true,
    "viewCount": 1245,
    "helpfulCount": 890,
    "createdBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "updatedBy": {
      "_id": "admin456",
      "name": "Another Admin",
      "email": "admin2@example.com"
    },
    "createdAt": "2025-10-01T10:00:00.000Z",
    "updatedAt": "2025-10-14T12:30:00.000Z"
  }
}
```

---

### 5. Delete FAQ
**DELETE** `/api/admin/faqs/:id`

Delete an FAQ permanently.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "FAQ deleted successfully",
  "data": {
    "_id": "faq123",
    "question": "How long does delivery take?"
  }
}
```

---

### 6. Reorder FAQs
**POST** `/api/admin/faqs/reorder`

Update the display order of multiple FAQs at once.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "faqs": [
    { "id": "faq123", "order": 1 },
    { "id": "faq124", "order": 2 },
    { "id": "faq125", "order": 3 },
    { "id": "faq126", "order": 4 }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "FAQs reordered successfully",
  "data": [
    {
      "_id": "faq123",
      "question": "How long does delivery take?",
      "order": 1
    },
    {
      "_id": "faq124",
      "question": "What payment methods do you accept?",
      "order": 2
    },
    {
      "_id": "faq125",
      "question": "How can I track my order?",
      "order": 3
    },
    {
      "_id": "faq126",
      "question": "Can I cancel my order?",
      "order": 4
    }
  ]
}
```

---

## FAQ Categories

- **general**: General questions about the app/service
- **orders**: Questions about placing and managing orders
- **delivery**: Delivery and shipping related questions
- **payment**: Payment methods and transactions
- **account**: User account management
- **products**: Product information and specifications
- **loyalty**: Loyalty program and rewards
- **other**: Miscellaneous questions

---

## Best Practices

### For Admins:
1. **Keep answers concise**: Aim for clear, brief answers (under 500 words)
2. **Use proper ordering**: Order FAQs by popularity or importance
3. **Update regularly**: Review and update FAQs based on user feedback
4. **Categorize properly**: Use appropriate categories for easy filtering
5. **Monitor metrics**: Check viewCount and helpfulCount to identify popular/useful FAQs

### For Users:
1. **Search first**: Use the search feature before submitting feedback
2. **Mark helpful**: Help others by marking helpful FAQs
3. **Check categories**: Browse by category for organized information

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "error": "Question must be at least 10 characters long"
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
  "message": "FAQ not found"
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

## Notes

- View count is automatically incremented when FAQs are fetched
- Helpful count can only be incremented (no decrement)
- Inactive FAQs are hidden from users but visible to admins
- FAQs are sorted by `order` field by default (ascending)
- Public endpoints don't require authentication
