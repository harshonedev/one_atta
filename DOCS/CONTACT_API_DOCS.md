# Contact API Documentation

## Overview
The Contact feature allows administrators to manage company contact information and provides public access for app users to retrieve contact details including emails, phone numbers, office address, social media links, and business hours.

---

## Admin Endpoints

### Base URL
```
/api/admin/contact
```

All admin endpoints require authentication and admin/manager role.

---

### 1. Get Contact Details (Admin)

**Endpoint:** `GET /api/admin/contact`

**Description:** Retrieve all contact details (including metadata like updatedBy).

**Authentication:** Required (Admin/Manager)

**Request Headers:**
```
Authorization: Bearer <admin_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact details fetched successfully",
  "data": {
    "_id": "671234567890abcdef123456",
    "supportEmail": "support@oneatta.com",
    "salesEmail": "sales@oneatta.com",
    "infoEmail": "info@oneatta.com",
    "supportPhone": "9876543210",
    "salesPhone": "9876543211",
    "whatsappNumber": "9876543212",
    "officeAddress": {
      "address_line1": "123 Main Street",
      "address_line2": "Building A, Floor 2",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postal_code": "400001",
      "country": "India"
    },
    "socialMedia": {
      "facebook": "https://facebook.com/oneatta",
      "instagram": "https://instagram.com/oneatta",
      "twitter": "https://twitter.com/oneatta",
      "linkedin": "https://linkedin.com/company/oneatta",
      "youtube": "https://youtube.com/@oneatta"
    },
    "businessHours": {
      "monday": "9:00 AM - 6:00 PM",
      "tuesday": "9:00 AM - 6:00 PM",
      "wednesday": "9:00 AM - 6:00 PM",
      "thursday": "9:00 AM - 6:00 PM",
      "friday": "9:00 AM - 6:00 PM",
      "saturday": "9:00 AM - 2:00 PM",
      "sunday": "Closed"
    },
    "website": "https://oneatta.com",
    "mapLink": "https://maps.google.com/?q=One+Atta+Office",
    "updatedBy": {
      "_id": "65f1234567890abcdef12345",
      "name": "Admin User",
      "email": "admin@oneatta.com"
    },
    "createdAt": "2024-10-20T10:30:00.000Z",
    "updatedAt": "2024-10-27T14:25:00.000Z"
  }
}
```

---

### 2. Create Contact Details (Admin)

**Endpoint:** `POST /api/admin/contact`

**Description:** Create initial contact details (only if not already exists).

**Authentication:** Required (Admin/Manager)

**Request Headers:**
```
Authorization: Bearer <admin_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "supportEmail": "support@oneatta.com",
  "salesEmail": "sales@oneatta.com",
  "infoEmail": "info@oneatta.com",
  "supportPhone": "9876543210",
  "salesPhone": "9876543211",
  "whatsappNumber": "9876543212",
  "officeAddress": {
    "address_line1": "123 Main Street",
    "address_line2": "Building A, Floor 2",
    "city": "Mumbai",
    "state": "Maharashtra",
    "postal_code": "400001",
    "country": "India"
  },
  "socialMedia": {
    "facebook": "https://facebook.com/oneatta",
    "instagram": "https://instagram.com/oneatta",
    "twitter": "https://twitter.com/oneatta",
    "linkedin": "https://linkedin.com/company/oneatta",
    "youtube": "https://youtube.com/@oneatta"
  },
  "businessHours": {
    "monday": "9:00 AM - 6:00 PM",
    "tuesday": "9:00 AM - 6:00 PM",
    "wednesday": "9:00 AM - 6:00 PM",
    "thursday": "9:00 AM - 6:00 PM",
    "friday": "9:00 AM - 6:00 PM",
    "saturday": "9:00 AM - 2:00 PM",
    "sunday": "Closed"
  },
  "website": "https://oneatta.com",
  "mapLink": "https://maps.google.com/?q=One+Atta+Office"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Contact details created successfully",
  "data": {
    "_id": "671234567890abcdef123456",
    "supportEmail": "support@oneatta.com",
    "salesEmail": "sales@oneatta.com",
    // ... all contact fields
    "updatedBy": "65f1234567890abcdef12345",
    "createdAt": "2024-10-27T14:25:00.000Z",
    "updatedAt": "2024-10-27T14:25:00.000Z"
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Contact details already exist. Please update."
}
```

---

### 3. Update Contact Details (Admin)

**Endpoint:** `PUT /api/admin/contact`

**Description:** Update existing contact details.

**Authentication:** Required (Admin/Manager)

**Request Headers:**
```
Authorization: Bearer <admin_token>
Content-Type: application/json
```

**Request Body (Partial Update Supported):**
```json
{
  "supportEmail": "newsupport@oneatta.com",
  "supportPhone": "9876543213",
  "socialMedia": {
    "facebook": "https://facebook.com/oneattaofficial",
    "instagram": "https://instagram.com/oneattaofficial"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact details updated successfully",
  "data": {
    "_id": "671234567890abcdef123456",
    "supportEmail": "newsupport@oneatta.com",
    "supportPhone": "9876543213",
    // ... all contact fields
    "updatedBy": {
      "_id": "65f1234567890abcdef12345",
      "name": "Admin User",
      "email": "admin@oneatta.com"
    },
    "createdAt": "2024-10-20T10:30:00.000Z",
    "updatedAt": "2024-10-27T15:00:00.000Z"
  }
}
```

---

## App Endpoints (Public)

### Base URL
```
/api/contact
```

---

### 1. Get Public Contact Details

**Endpoint:** `GET /api/contact`

**Description:** Retrieve public contact details (no authentication required).

**Authentication:** Not Required

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact details fetched successfully",
  "data": {
    "_id": "671234567890abcdef123456",
    "supportEmail": "support@oneatta.com",
    "salesEmail": "sales@oneatta.com",
    "infoEmail": "info@oneatta.com",
    "supportPhone": "9876543210",
    "salesPhone": "9876543211",
    "whatsappNumber": "9876543212",
    "officeAddress": {
      "address_line1": "123 Main Street",
      "address_line2": "Building A, Floor 2",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postal_code": "400001",
      "country": "India"
    },
    "socialMedia": {
      "facebook": "https://facebook.com/oneatta",
      "instagram": "https://instagram.com/oneatta",
      "twitter": "https://twitter.com/oneatta",
      "linkedin": "https://linkedin.com/company/oneatta",
      "youtube": "https://youtube.com/@oneatta"
    },
    "businessHours": {
      "monday": "9:00 AM - 6:00 PM",
      "tuesday": "9:00 AM - 6:00 PM",
      "wednesday": "9:00 AM - 6:00 PM",
      "thursday": "9:00 AM - 6:00 PM",
      "friday": "9:00 AM - 6:00 PM",
      "saturday": "9:00 AM - 2:00 PM",
      "sunday": "Closed"
    },
    "website": "https://oneatta.com",
    "mapLink": "https://maps.google.com/?q=One+Atta+Office",
    "createdAt": "2024-10-20T10:30:00.000Z",
    "updatedAt": "2024-10-27T14:25:00.000Z"
  }
}
```

**Note:** The public endpoint excludes `updatedBy` and internal metadata.

---

## Field Validation

### Email Fields
- **Format:** Valid email format (user@domain.com)
- **Optional:** All email fields are optional
- **Examples:** 
  - `supportEmail`: "support@oneatta.com"
  - `salesEmail`: "sales@oneatta.com"
  - `infoEmail`: "info@oneatta.com"

### Phone Fields
- **Format:** 10-15 digits, numbers only
- **Optional:** All phone fields are optional
- **Examples:**
  - `supportPhone`: "9876543210"
  - `salesPhone`: "9876543211"
  - `whatsappNumber`: "9876543212"

### Office Address
- **Structure:** Nested object with address components
- **Optional:** All fields are optional
- **Fields:**
  - `address_line1`: String, max 100 characters
  - `address_line2`: String, max 100 characters
  - `city`: String, max 50 characters
  - `state`: String, max 50 characters
  - `postal_code`: String, max 20 characters
  - `country`: String, max 50 characters (default: "India")

### Social Media
- **Structure:** Nested object with platform URLs
- **Optional:** All fields are optional
- **Fields:** facebook, instagram, twitter, linkedin, youtube

### Business Hours
- **Structure:** Nested object with day-wise timings
- **Format:** String (e.g., "9:00 AM - 6:00 PM")
- **Default Values:** Pre-filled with standard business hours
- **Days:** monday, tuesday, wednesday, thursday, friday, saturday, sunday

### Additional Fields
- `website`: URL string (optional)
- `mapLink`: URL string (optional)

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Invalid email format" // or other validation error
}
```

### 401 Unauthorized (Admin routes)
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```

### 403 Forbidden (Admin routes)
```json
{
  "success": false,
  "message": "Access denied. Admin or Manager role required."
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Server error message"
}
```

---

## Usage Examples

### cURL Examples

#### Get Public Contact (No Auth)
```bash
curl -X GET http://localhost:5000/api/contact
```

#### Get Contact Details (Admin)
```bash
curl -X GET http://localhost:5000/api/admin/contact \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### Update Contact Details (Admin)
```bash
curl -X PUT http://localhost:5000/api/admin/contact \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "supportEmail": "newsupport@oneatta.com",
    "supportPhone": "9876543213"
  }'
```

---

## Model Structure

```javascript
Contact {
  supportEmail: String (optional, validated)
  salesEmail: String (optional, validated)
  infoEmail: String (optional, validated)
  supportPhone: String (optional, 10-15 digits)
  salesPhone: String (optional, 10-15 digits)
  whatsappNumber: String (optional, 10-15 digits)
  officeAddress: {
    address_line1: String (max 100)
    address_line2: String (max 100)
    city: String (max 50)
    state: String (max 50)
    postal_code: String (max 20)
    country: String (max 50, default: "India")
  }
  socialMedia: {
    facebook: String
    instagram: String
    twitter: String
    linkedin: String
    youtube: String
  }
  businessHours: {
    monday: String
    tuesday: String
    wednesday: String
    thursday: String
    friday: String
    saturday: String
    sunday: String
  }
  website: String
  mapLink: String
  updatedBy: ObjectId (ref: User)
  createdAt: Date (auto)
  updatedAt: Date (auto)
}
```

---

## Best Practices

1. **Admin Updates**: Always use PUT endpoint for updates rather than POST
2. **Validation**: Validate email and phone formats on the client side before submission
3. **Partial Updates**: You can update only specific fields without sending all data
4. **Business Hours**: Use consistent time format (e.g., "9:00 AM - 6:00 PM")
5. **Social Media**: Use full URLs including protocol (https://)
6. **Phone Numbers**: Store numbers without country code prefix or special characters
7. **Public Access**: The public endpoint is cached, so updates may take a few minutes to reflect

---

## Notes

- Only one contact document exists in the database
- First-time setup creates default empty contact details
- Updates are tracked with `updatedBy` field and timestamps
- All fields are optional to provide flexibility
- The system automatically creates a contact document if none exists when fetching
