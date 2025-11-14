# Invoice with Shipment Tracking - API Documentation

## Overview
Invoice system now includes Shiprocket tracking details (AWB number, courier info, tracking URL) for admin invoices, plus user-side endpoints for accessing their invoices.

---

## Updates to Admin Invoice System

### Shipment Details in Invoice

Invoices now automatically capture Shiprocket shipment information when available:

**Shipment Fields Added to Invoice:**
```json
{
  "shipment_details": {
    "shiprocket_order_id": "SR12345",
    "shiprocket_shipment_id": "SHIP12345",
    "awb_number": "AWB123456789",
    "courier_name": "Delhivery",
    "courier_company_id": 123,
    "tracking_url": "https://shiprocket.co/tracking/AWB123456789",
    "current_status": "IN_TRANSIT",
    "expected_delivery_date": "2025-11-20T00:00:00.000Z",
    "actual_delivery_date": null,
    "pickup_scheduled_date": "2025-11-15T00:00:00.000Z",
    "pickup_token_number": "PKP12345"
  }
}
```

### Invoice Generation (Admin)

**Endpoint:** `POST /api/admin/invoices/generate`

**Behavior:**
- Automatically fetches shipment details from Shipment model
- Includes AWB number, courier name, tracking URL in invoice
- Displays tracking info in invoice PDF/HTML

**Example Response:**
```json
{
  "success": true,
  "message": "Invoice generated successfully",
  "data": {
    "invoice_number": "INV-1001",
    "shipment_details": {
      "awb_number": "AWB123456789",
      "courier_name": "Delhivery",
      "current_status": "IN_TRANSIT",
      "tracking_url": "https://shiprocket.co/tracking/AWB123456789"
    },
    // ... other invoice fields
  }
}
```

### Invoice PDF/HTML Updates

The generated invoice now includes a **Shipment Tracking** section (when available):

**Displayed Information:**
- AWB Number
- Courier Name
- Current Status
- Expected Delivery Date
- Tracking URL (clickable link)

**Visual:**
- Blue-bordered box
- Easy to locate tracking information
- Print-friendly format

---

## User-Side Invoice API

### Base URL
```
/api/app/invoices
```

### Authentication
All endpoints require user authentication (JWT token).

---

## User Endpoints

### 1. Get User's Invoices
Retrieve all invoices for the authenticated user.

**Endpoint:** `GET /api/app/invoices`

**Query Parameters:**
- `page` (number, default: 1) - Page number
- `limit` (number, default: 20) - Items per page
- `status` (string, optional) - Filter by status: `draft`, `issued`, `paid`, `cancelled`, `refunded`

**Example Request:**
```bash
GET /api/app/invoices?page=1&limit=10&status=paid
```

**Response (200):**
```json
{
  "success": true,
  "message": "Invoices retrieved successfully",
  "data": {
    "invoices": [
      {
        "_id": "invoice_id",
        "invoice_number": "INV-1001",
        "invoice_date": "2025-11-14T10:00:00.000Z",
        "total_amount": 1050,
        "tax_type": "INTRA_STATE",
        "status": "paid",
        "payment_status": "completed",
        "pdf_url": "/invoices/INV-1001.html",
        "shipment_details": {
          "awb_number": "AWB123456789",
          "courier_name": "Delhivery",
          "current_status": "DELIVERED"
        }
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 3,
      "totalInvoices": 25,
      "limit": 10
    }
  }
}
```

---

### 2. Get Invoice by Order ID
Retrieve invoice for a specific order.

**Endpoint:** `GET /api/app/invoices/order/:orderId`

**Example Request:**
```bash
GET /api/app/invoices/order/673abc123def456789012345
```

**Response (200):**
```json
{
  "success": true,
  "message": "Invoice retrieved successfully",
  "data": {
    "_id": "invoice_id",
    "invoice_number": "INV-1001",
    "invoice_date": "2025-11-14T10:00:00.000Z",
    "order_id": "673abc123def456789012345",
    "customer": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "items": [
      // ... invoice items
    ],
    "total_amount": 1050,
    "shipment_details": {
      "awb_number": "AWB123456789",
      "courier_name": "Delhivery",
      "tracking_url": "https://shiprocket.co/tracking/AWB123456789",
      "current_status": "IN_TRANSIT"
    }
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "message": "Invoice not found"
}
```

---

### 3. Get Invoice by ID
Retrieve a specific invoice by invoice ID.

**Endpoint:** `GET /api/app/invoices/:id`

**Example Request:**
```bash
GET /api/app/invoices/673def456abc789012345678
```

**Response (200):**
```json
{
  "success": true,
  "message": "Invoice retrieved successfully",
  "data": {
    // Complete invoice object
  }
}
```

---

### 4. Download Invoice
Get the download URL for an invoice.

**Endpoint:** `GET /api/app/invoices/:id/download`

**Example Request:**
```bash
GET /api/app/invoices/673def456abc789012345678/download
```

**Response (200):**
```json
{
  "success": true,
  "message": "Invoice download URL retrieved",
  "data": {
    "invoice_number": "INV-1001",
    "download_url": "/invoices/INV-1001.html",
    "pdf_generated_at": "2025-11-14T10:05:00.000Z"
  }
}
```

**Usage:**
```javascript
// In frontend, construct full URL
const downloadUrl = `${baseURL}${data.download_url}`;
window.open(downloadUrl, '_blank');
```

---

### 5. Preview Invoice
Preview invoice HTML in browser.

**Endpoint:** `GET /api/app/invoices/:id/preview`

**Example Request:**
```bash
GET /api/app/invoices/673def456abc789012345678/preview
```

**Response:** Returns HTML content directly for browser display

**Usage:**
```javascript
// Open in new tab
window.open(`/api/app/invoices/${invoiceId}/preview`, '_blank');
```

---

### 6. Get Tracking Details
Get shipment tracking information from invoice.

**Endpoint:** `GET /api/app/invoices/:id/tracking`

**Example Request:**
```bash
GET /api/app/invoices/673def456abc789012345678/tracking
```

**Response (200):**
```json
{
  "success": true,
  "message": "Tracking information retrieved successfully",
  "data": {
    "invoice_number": "INV-1001",
    "tracking": {
      "shiprocket_order_id": "SR12345",
      "shiprocket_shipment_id": "SHIP12345",
      "awb_number": "AWB123456789",
      "courier_name": "Delhivery",
      "tracking_url": "https://shiprocket.co/tracking/AWB123456789",
      "current_status": "IN_TRANSIT",
      "expected_delivery_date": "2025-11-20T00:00:00.000Z"
    }
  }
}
```

**Error (404):**
```json
{
  "success": false,
  "message": "Tracking information not available for this invoice"
}
```

---

## Security Features

### User Access Control
- ✅ Users can only access their own invoices
- ✅ Queries filtered by `customer.user_id`
- ✅ Prevents unauthorized access to other users' invoices
- ✅ JWT authentication required

### Admin vs User Differences

**Admin Endpoints (`/api/admin/invoices`):**
- Generate invoices
- View all invoices
- Update invoice status
- Cancel invoices
- Access any user's invoice

**User Endpoints (`/api/app/invoices`):**
- View own invoices only
- Download own invoices
- Get tracking info
- No creation/modification rights

---

## Frontend Integration Examples

### 1. Display User Invoices List
```javascript
// Fetch user's invoices
const response = await fetch('/api/app/invoices?page=1&limit=10', {
  headers: {
    'Authorization': `Bearer ${userToken}`
  }
});

const { data } = await response.json();

// Display invoices
data.invoices.forEach(invoice => {
  console.log(`Invoice: ${invoice.invoice_number}`);
  console.log(`Amount: ₹${invoice.total_amount}`);
  console.log(`Status: ${invoice.status}`);
  
  if (invoice.shipment_details?.awb_number) {
    console.log(`AWB: ${invoice.shipment_details.awb_number}`);
    console.log(`Courier: ${invoice.shipment_details.courier_name}`);
  }
});
```

### 2. Download Invoice
```javascript
// Get download URL
const response = await fetch(`/api/app/invoices/${invoiceId}/download`, {
  headers: {
    'Authorization': `Bearer ${userToken}`
  }
});

const { data } = await response.json();

// Open in new window or download
window.open(data.download_url, '_blank');
```

### 3. Track Order from Invoice
```javascript
// Get tracking details
const response = await fetch(`/api/app/invoices/${invoiceId}/tracking`, {
  headers: {
    'Authorization': `Bearer ${userToken}`
  }
});

const { data } = await response.json();

// Display tracking info
console.log(`AWB: ${data.tracking.awb_number}`);
console.log(`Status: ${data.tracking.current_status}`);

// Open tracking URL
if (data.tracking.tracking_url) {
  window.open(data.tracking.tracking_url, '_blank');
}
```

---

## Common Use Cases

### Use Case 1: Order History with Invoices
```javascript
// User views their orders
// For each order, fetch invoice if available
const invoice = await fetchInvoiceByOrderId(orderId);

if (invoice) {
  showInvoiceButton(invoice.id);
  showTrackingInfo(invoice.shipment_details);
}
```

### Use Case 2: Download Invoice from Order Details
```javascript
// On order details page
<button onClick={() => downloadInvoice(order.invoice_id)}>
  Download Invoice
</button>

function downloadInvoice(invoiceId) {
  fetch(`/api/app/invoices/${invoiceId}/download`)
    .then(res => res.json())
    .then(data => window.open(data.data.download_url));
}
```

### Use Case 3: Track Shipment from Invoice
```javascript
// Show tracking button if AWB available
{invoice.shipment_details?.awb_number && (
  <button onClick={() => trackShipment(invoice.id)}>
    Track Order (AWB: {invoice.shipment_details.awb_number})
  </button>
)}

function trackShipment(invoiceId) {
  fetch(`/api/app/invoices/${invoiceId}/tracking`)
    .then(res => res.json())
    .then(data => {
      if (data.data.tracking.tracking_url) {
        window.open(data.data.tracking.tracking_url);
      }
    });
}
```

---

## Invoice PDF Updates

The invoice HTML/PDF now includes:

### Shipment Tracking Section
Located after "Amount in Words" section, displays:
- **AWB Number:** Airway Bill number
- **Courier:** Delivery partner name
- **Current Status:** Shipment status (formatted)
- **Expected Delivery:** Delivery date
- **Track Your Order:** Clickable tracking URL

**Visual:**
- Light blue background (#f0f8ff)
- Blue border
- Grid layout (2 columns)
- Prominent and easy to find

---

## Error Handling

### Common Errors

**Invoice Not Found:**
```json
{
  "success": false,
  "message": "Invoice not found"
}
```

**Tracking Not Available:**
```json
{
  "success": false,
  "message": "Tracking information not available for this invoice"
}
```

**PDF Not Generated:**
```json
{
  "success": false,
  "message": "Invoice PDF not available"
}
```

**Unauthorized Access:**
```json
{
  "success": false,
  "message": "Not authorized"
}
```

---

## Testing

### Test User Invoice Access

1. **As User - Get Invoices:**
```bash
curl -X GET http://localhost:5000/api/app/invoices \
  -H "Authorization: Bearer USER_TOKEN"
```

2. **As User - Download Invoice:**
```bash
curl -X GET http://localhost:5000/api/app/invoices/INVOICE_ID/download \
  -H "Authorization: Bearer USER_TOKEN"
```

3. **As User - Get Tracking:**
```bash
curl -X GET http://localhost:5000/api/app/invoices/INVOICE_ID/tracking \
  -H "Authorization: Bearer USER_TOKEN"
```

4. **Verify Access Control:**
```bash
# Try to access another user's invoice (should fail)
curl -X GET http://localhost:5000/api/app/invoices/OTHER_USER_INVOICE_ID \
  -H "Authorization: Bearer USER_TOKEN"
```

---

## Summary of Changes

### Models
- ✅ Updated `Invoice.js` - Added `shipment_details` field

### Services
- ✅ Updated `invoiceService.js` - Fetch shipment data during invoice generation
- ✅ Updated `pdfService.js` - Display shipment tracking in invoice HTML

### Controllers
- ✅ Created `app/controllers/invoiceController.js` - User-side invoice operations

### Routes
- ✅ Created `app/routes/invoiceRoutes.js` - User invoice endpoints
- ✅ Updated `app.routes.js` - Integrated invoice routes

### Features Added
- ✅ Admin invoices include Shiprocket tracking details
- ✅ User can view their invoices
- ✅ User can download their invoices
- ✅ User can get tracking info from invoices
- ✅ Invoice PDF displays AWB, courier, tracking URL
- ✅ Access control (users can only see their own invoices)

---

## API Endpoint Summary

### Admin Endpoints (Existing - Enhanced)
```
POST   /api/admin/invoices/generate      # Now includes shipment details
GET    /api/admin/invoices                # View all invoices
GET    /api/admin/invoices/:id            # Invoice details with tracking
```

### User Endpoints (New)
```
GET    /api/app/invoices                  # List user's invoices
GET    /api/app/invoices/:id              # Get invoice details
GET    /api/app/invoices/order/:orderId   # Get by order ID
GET    /api/app/invoices/:id/download     # Download invoice
GET    /api/app/invoices/:id/preview      # Preview invoice
GET    /api/app/invoices/:id/tracking     # Get tracking info
```

---

**Status:** ✅ Complete and Ready to Use

**Updated:** November 14, 2025
