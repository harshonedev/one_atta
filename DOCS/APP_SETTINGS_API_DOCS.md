# App Settings API Documentation

## Overview
The App Settings system allows admins to manage global application settings like Terms & Conditions URL, Privacy Policy URL, support contact information, and maintenance mode. Users can access these public settings without authentication.

---

## App-Side Endpoints (User)

### 1. Get Public App Settings
**GET** `/api/app/app-settings`

Retrieve public app settings accessible to all users.

**Authentication Required:** No (Public)

**Response (200):**
```json
{
  "success": true,
  "message": "App settings fetched successfully",
  "data": {
    "_id": "settings123",
    "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
    "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
    "supportEmail": "support@oneatta.com",
    "supportPhone": "+91-1234567890",
    "appVersion": "2.1.5",
    "maintenanceMode": false,
    "maintenanceMessage": ""
  }
}
```

**Fields Description:**
- `termsAndConditionsUrl`: URL to the Terms & Conditions page
- `privacyPolicyUrl`: URL to the Privacy Policy page
- `supportEmail`: Customer support email address
- `supportPhone`: Customer support phone number
- `appVersion`: Current app version
- `maintenanceMode`: Boolean indicating if app is in maintenance mode
- `maintenanceMessage`: Message to display during maintenance (if applicable)

---

## Admin-Side Endpoints

### 1. Get App Settings (Admin)
**GET** `/api/admin/app-settings`

Retrieve complete app settings including admin metadata.

**Authentication Required:** Yes (Admin/Manager)

**Response (200):**
```json
{
  "success": true,
  "message": "App settings fetched successfully",
  "data": {
    "_id": "settings123",
    "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
    "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
    "supportEmail": "support@oneatta.com",
    "supportPhone": "+91-1234567890",
    "appVersion": "2.1.5",
    "maintenanceMode": false,
    "maintenanceMessage": "",
    "updatedBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "createdAt": "2025-10-01T10:00:00.000Z",
    "updatedAt": "2025-10-14T12:00:00.000Z"
  }
}
```

**Note:** If settings don't exist, they will be automatically created with empty/default values.

---

### 2. Create App Settings
**POST** `/api/admin/app-settings`

Create initial app settings (only if they don't exist).

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
  "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
  "supportEmail": "support@oneatta.com",
  "supportPhone": "+91-1234567890",
  "appVersion": "2.0.0",
  "maintenanceMode": false,
  "maintenanceMessage": ""
}
```

**Field Validations:**
- `termsAndConditionsUrl`: String (URL), optional, can be empty
- `privacyPolicyUrl`: String (URL), optional, can be empty
- `supportEmail`: String (email), optional, can be empty
- `supportPhone`: String, optional, can be empty
- `appVersion`: String, optional, can be empty
- `maintenanceMode`: Boolean, optional (default: false)
- `maintenanceMessage`: String, optional, can be empty

**Response (201):**
```json
{
  "success": true,
  "message": "App settings created successfully",
  "data": {
    "_id": "settings123",
    "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
    "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
    "supportEmail": "support@oneatta.com",
    "supportPhone": "+91-1234567890",
    "appVersion": "2.0.0",
    "maintenanceMode": false,
    "maintenanceMessage": "",
    "updatedBy": "admin123",
    "createdAt": "2025-10-14T12:00:00.000Z",
    "updatedAt": "2025-10-14T12:00:00.000Z"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "App settings already exist. Please update."
}
```

---

### 3. Update App Settings
**PUT** `/api/admin/app-settings`

Update existing app settings. Creates settings if they don't exist.

**Authentication Required:** Yes (Admin/Manager)

**Request Body:**
```json
{
  "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
  "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
  "supportEmail": "support@oneatta.com",
  "supportPhone": "+91-1234567890",
  "appVersion": "2.1.5",
  "maintenanceMode": false,
  "maintenanceMessage": ""
}
```

**Field Validations:**
- All fields are optional
- `termsAndConditionsUrl`: String (URL), can be empty
- `privacyPolicyUrl`: String (URL), can be empty
- `supportEmail`: String (email), can be empty
- `supportPhone`: String, can be empty
- `appVersion`: String, can be empty
- `maintenanceMode`: Boolean
- `maintenanceMessage`: String, can be empty

**Response (200):**
```json
{
  "success": true,
  "message": "App settings updated successfully",
  "data": {
    "_id": "settings123",
    "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions",
    "privacyPolicyUrl": "https://oneatta.com/privacy-policy",
    "supportEmail": "support@oneatta.com",
    "supportPhone": "+91-1234567890",
    "appVersion": "2.1.5",
    "maintenanceMode": false,
    "maintenanceMessage": "",
    "updatedBy": {
      "_id": "admin123",
      "name": "Admin User",
      "email": "admin@example.com"
    },
    "createdAt": "2025-10-01T10:00:00.000Z",
    "updatedAt": "2025-10-14T12:30:00.000Z"
  }
}
```

---

## Use Cases

### 1. Terms & Conditions URL
Update when legal terms change:
```json
{
  "termsAndConditionsUrl": "https://oneatta.com/terms-and-conditions-v2"
}
```

### 2. Privacy Policy URL
Update when privacy policy is modified:
```json
{
  "privacyPolicyUrl": "https://oneatta.com/privacy-policy-updated"
}
```

### 3. Support Contact Information
Update support channels:
```json
{
  "supportEmail": "help@oneatta.com",
  "supportPhone": "+91-9876543210"
}
```

### 4. Maintenance Mode
Enable maintenance mode with a message:
```json
{
  "maintenanceMode": true,
  "maintenanceMessage": "We are performing scheduled maintenance. The app will be back online by 2:00 PM IST. Thank you for your patience."
}
```

Disable maintenance mode:
```json
{
  "maintenanceMode": false,
  "maintenanceMessage": ""
}
```

### 5. App Version
Update app version after a release:
```json
{
  "appVersion": "2.2.0"
}
```

---

## Integration Examples

### Frontend: Display Terms & Conditions
```javascript
// Fetch settings
const response = await fetch('/api/app/app-settings');
const { data } = await response.json();

// Display link
if (data.termsAndConditionsUrl) {
  window.open(data.termsAndConditionsUrl, '_blank');
}
```

### Frontend: Display Privacy Policy
```javascript
// Fetch settings
const response = await fetch('/api/app/app-settings');
const { data } = await response.json();

// Display link
if (data.privacyPolicyUrl) {
  window.open(data.privacyPolicyUrl, '_blank');
}
```

### Frontend: Show Maintenance Message
```javascript
// Fetch settings on app startup
const response = await fetch('/api/app/app-settings');
const { data } = await response.json();

if (data.maintenanceMode) {
  // Show maintenance screen
  showMaintenanceScreen(data.maintenanceMessage);
}
```

### Frontend: Display Support Contact
```javascript
// Fetch settings
const response = await fetch('/api/app/app-settings');
const { data } = await response.json();

// Display support info
const supportInfo = `
  Email: ${data.supportEmail}
  Phone: ${data.supportPhone}
`;
```

---

## Admin Dashboard Integration

### Settings Form
```javascript
// Fetch current settings
const fetchSettings = async () => {
  const response = await fetch('/api/admin/app-settings', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  const { data } = await response.json();
  return data;
};

// Update settings
const updateSettings = async (formData) => {
  const response = await fetch('/api/admin/app-settings', {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(formData)
  });
  const result = await response.json();
  return result;
};
```

---

## Error Responses

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

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "error": "Invalid email format"
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

## Best Practices

### For Admins:
1. **Keep URLs updated**: Ensure legal documents are always accessible
2. **Test URLs**: Verify all URLs are working before updating
3. **Maintenance planning**: Schedule maintenance during low-traffic periods
4. **Clear messages**: Provide clear maintenance messages with expected downtime
5. **Version tracking**: Update app version after each release

### For Developers:
1. **Cache settings**: Cache public settings on the client side
2. **Refresh on focus**: Refetch settings when app comes to foreground
3. **Handle maintenance**: Implement proper maintenance mode UI
4. **Fallback values**: Have default values if settings are unavailable
5. **Error handling**: Handle network errors gracefully

---

## Notes

- Only one settings document exists in the database
- If settings don't exist, they're automatically created with default values
- Public endpoint doesn't require authentication for easy access
- Admin endpoints track who made the last update
- Empty strings are allowed for URLs (useful during initial setup)
- Maintenance mode should be used sparingly and with advance notice to users
