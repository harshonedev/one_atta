# App Shipping API Documentation

## Overview
The App Shipping API provides secure shipping services for mobile applications with enhanced security and user experience. This API follows a controlled workflow where users can check shipping rates and track their shipments, but cannot create shipments directly. Shipment creation is an admin-only function that occurs automatically when orders are accepted.

### Security Model Changes
- ❌ **Removed**: Direct shipment creation by users
- ✅ **Enhanced**: Comprehensive shipment tracking with real-time updates
- ✅ **Maintained**: Shipping rate calculation and serviceability checks
- 🔒 **New Workflow**: Order Placement → Admin Review → Auto Shipment Creation → User Tracking

### Key Features
- **Rate Calculation**: Get shipping costs from multiple couriers
- **Serviceability Check**: Verify delivery availability to any pincode
- **Real-time Tracking**: Live shipment status updates
- **Order Integration**: Seamless tracking of order-based shipments
- **Multi-Courier Support**: Support for various courier partners

## Base URL
```
/api/app/shipping
```

## Authentication
All endpoints require user authentication:
- **JWT Token**: `Authorization: Bearer <token>`
- **API Key**: `x-api-key: <mobile_api_key>` (for mobile apps)

## Table of Contents
1. [Utility Endpoints](#utility-endpoints)
2. [Tracking Endpoints](#tracking-endpoints)
3. [Order & Shipping Flow](#new-order--shipping-flow)
4. [Error Handling](#error-codes)
5. [Migration Guide](#migration-notes)

---

## Utility Endpoints

### 1. Check Serviceability
**GET** `/api/app/shipping/check-serviceability`

Check if delivery is available to a specific pincode.

**Query Parameters:**
```
deliveryPincode (string, required): Target delivery pincode
weight (number, required): Package weight in kg
```

**Example Request:**
```bash
GET /api/app/shipping/check-serviceability?deliveryPincode=400001&weight=1.5
```

**Success Response:**
```json
{
  "success": true,
  "message": "Serviceability check completed",
  "data": {
    "available_couriers": [
      {
        "courier_company_id": 38,
        "courier_name": "Delhivery",
        "freight_charge": 45.0,
        "cod_charges": 15.0,
        "is_surface": true,
        "pickup_performance": 4.5,
        "delivery_performance": 4.2,
        "rating": 4.3,
        "eta": "2024-01-25"
      }
    ],
    "pickup_postcode": "110001",
    "delivery_postcode": "400001",
    "weight": 1.5,
    "mock_data": false
  }
}
```

**Error Response (Invalid Parameters):**
```json
{
  "success": false,
  "message": "Delivery pincode and weight are required",
  "code": "MISSING_PARAMETERS"
}
```

**Error Response (Service Unavailable):**
```json
{
  "success": false,
  "message": "Service not available for this pincode",
  "code": "SERVICE_UNAVAILABLE",
  "data": {
    "pincode": "123456",
    "available_alternatives": [
      {
        "pincode": "123457",
        "distance": "5 km"
      }
    ]
  }
}
```

### 2. Get Shipping Rates
**GET** `/api/app/shipping/shipping-rates`

Get detailed shipping rates from multiple couriers.

**Query Parameters:**
```
deliveryPincode (string, required): Target delivery pincode
weight (number, required): Package weight in kg
cod (boolean, optional): Whether COD is required (default: false)
```

**Example Request:**
```bash
GET /api/app/shipping/shipping-rates?deliveryPincode=400001&weight=1.5&cod=true
```

**Success Response:**
```json
{
  "success": true,
  "message": "Shipping rates retrieved",
  "data": {
    "rates": [
      {
        "courier_company_id": 38,
        "courier_name": "Delhivery",
        "freight_charge": 45.0,
        "cod_charges": 15.0,
        "total_charge": 60.0,
        "estimated_delivery_days": "2-3",
        "pickup_cutoff_time": "17:00",
        "is_surface": true,
        "rating": 4.3
      },
      {
        "courier_company_id": 29,
        "courier_name": "Blue Dart",
        "freight_charge": 65.0,
        "cod_charges": 18.0,
        "total_charge": 83.0,
        "estimated_delivery_days": "1-2",
        "pickup_cutoff_time": "16:00",
        "is_surface": false,
        "rating": 4.5
      }
    ],
    "pickup_postcode": "110001",
    "delivery_postcode": "400001",
    "weight": 1.5,
    "cod": true
  }
}
```

---

## Tracking Endpoints

### 3. Get User Shipments
**GET** `/api/app/shipping/my-shipments`

Retrieve all shipments for the authenticated user with optional filtering.

**Query Parameters (all optional):**
```
status (string): Filter by shipment status
startDate (string): Start date filter (YYYY-MM-DD)
endDate (string): End date filter (YYYY-MM-DD)
limit (number): Maximum number of results
```

**Example Request:**
```bash
GET /api/app/shipping/my-shipments?status=IN_TRANSIT&limit=10
```

**Success Response:**
```json
{
  "success": true,
  "message": "User shipments retrieved successfully",
  "data": {
    "shipments": [
      {
        "_id": "60f7b3b4c45a8b001c8e4567",
        "order_id": {
          "_id": "60f7b3a1c45a8b001c8e4566",
          "items": [...],
          "status": "processing",
          "created_at": "2024-01-20T10:00:00.000Z"
        },
        "awb_number": "DELHIVERY123456789",
        "courier_name": "Delhivery",
        "current_status": "IN_TRANSIT",
        "expected_delivery_date": "2024-01-25T00:00:00.000Z",
        "tracking_url": "https://www.delhivery.com/track/...",
        "created_at": "2024-01-20T12:00:00.000Z",
        "updated_at": "2024-01-23T09:30:00.000Z"
      }
    ],
    "count": 1
  }
}
```

### 4. Get Shipment by Order
**GET** `/api/app/shipping/order/:orderId`

Get shipment details for a specific order.

**Path Parameters:**
```
orderId (string, required): Order ID
```

**Example Request:**
```bash
GET /api/app/shipping/order/60f7b3a1c45a8b001c8e4566
```

**Success Response:**
```json
{
  "success": true,
  "message": "Shipment details retrieved successfully",
  "data": {
    "_id": "60f7b3b4c45a8b001c8e4567",
    "order_id": {
      "_id": "60f7b3a1c45a8b001c8e4566",
      "items": [...],
      "status": "processing"
    },
    "shiprocket_order_id": "SR123456789",
    "shiprocket_shipment_id": "SRS987654321",
    "awb_number": "DELHIVERY123456789",
    "courier_company_id": 38,
    "courier_name": "Delhivery",
    "current_status": "PICKED_UP",
    "tracking_url": "https://www.delhivery.com/track/...",
    "expected_delivery_date": "2024-01-25T00:00:00.000Z",
    "dimensions": {
      "length": 10,
      "breadth": 8,
      "height": 6,
      "weight": 1.5
    },
    "status_history": [
      {
        "status": "NEW",
        "status_datetime": "2024-01-20T12:00:00.000Z",
        "remarks": "Shipment created"
      },
      {
        "status": "PICKED_UP",
        "status_datetime": "2024-01-21T09:30:00.000Z",
        "location": "Mumbai",
        "remarks": "Package picked up from seller"
      }
    ],
    "last_sync_date": "2024-01-23T09:30:00.000Z"
  }
}
```

**Error Response (No Shipment):**
```json
{
  "success": false,
  "message": "No shipment found for this order. Order may not be accepted yet."
}
```

### 5. Track Shipment
**GET** `/api/app/shipping/track/:shipmentId`

Get real-time tracking data with live updates from courier.

**Path Parameters:**
```
shipmentId (string, required): Shipment ID
```

**Example Request:**
```bash
GET /api/app/shipping/track/60f7b3b4c45a8b001c8e4567
```

**Success Response:**
```json
{
  "success": true,
  "message": "Shipment tracking data retrieved successfully",
  "data": {
    "shipment_id": "60f7b3b4c45a8b001c8e4567",
    "order_id": "60f7b3a1c45a8b001c8e4566",
    "awb_number": "DELHIVERY123456789",
    "courier_name": "Delhivery",
    "current_status": "OUT_FOR_DELIVERY",
    "tracking_url": "https://www.delhivery.com/track/...",
    "expected_delivery_date": "2024-01-25T00:00:00.000Z",
    "actual_delivery_date": null,
    "status_history": [
      {
        "status": "NEW",
        "status_datetime": "2024-01-20T12:00:00.000Z",
        "remarks": "Shipment created"
      },
      {
        "status": "OUT_FOR_DELIVERY",
        "status_datetime": "2024-01-25T08:00:00.000Z",
        "location": "Mumbai - Delivery Hub",
        "remarks": "Out for delivery - expected by 6 PM"
      }
    ],
    "live_tracking": [
      {
        "date": "2024-01-25T08:00:00.000Z",
        "location": "Mumbai - Delivery Hub",
        "message": "Out for delivery",
        "activity": "Package is loaded in delivery vehicle"
      }
    ],
    "last_updated": "2024-01-25T08:00:00.000Z"
  }
}
```

**Response (AWB Not Assigned):**
```json
{
  "success": true,
  "message": "Shipment tracking data retrieved successfully",
  "data": {
    "shipment_id": "60f7b3b4c45a8b001c8e4567",
    "order_id": "60f7b3a1c45a8b001c8e4566",
    "current_status": "NEW",
    "status_history": [...],
    "message": "Shipment created but AWB not yet assigned"
  }
}
```

---

## Shipment Status Reference

| Status | Description |
|--------|-------------|
| `NEW` | Shipment created, awaiting AWB assignment |
| `AWB_ASSIGNED` | AWB number assigned by courier |
| `PICKUP_SCHEDULED` | Pickup scheduled with courier |
| `PICKED_UP` | Package picked up by courier |
| `IN_TRANSIT` | Package in transit to destination |
| `OUT_FOR_DELIVERY` | Package out for final delivery |
| `DELIVERED` | Package delivered successfully |
| `RTO_INITIATED` | Return to origin initiated |
| `RTO_DELIVERED` | Package returned to sender |
| `CANCELLED` | Shipment cancelled |
| `LOST` | Package lost in transit |
| `DAMAGED` | Package damaged during transit |

---

## Error Codes

| HTTP Code | Description |
|-----------|-------------|
| `200` | Success |
| `400` | Bad Request - Missing required parameters |
| `401` | Unauthorized - Invalid or missing authentication |
| `403` | Forbidden - Access denied to resource |
| `404` | Not Found - Order/Shipment not found |
| `500` | Internal Server Error |

---

## Development Mode

When `NODE_ENV=development` and ShipRocket credentials are not configured:
- Mock data is returned for rates and serviceability
- Real tracking data may not be available
- Responses include `mock_data: true` flag

---

## Migration Notes

### For Mobile Apps:
1. **Remove shipment creation functionality**
2. **Update order flow UI** to show pending → accepted → processing states
3. **Add tracking features** using new endpoints
4. **Keep existing** rate checking functionality

### Backward Compatibility:
- All tracking-related endpoints are new (no breaking changes)
- Rate and serviceability endpoints remain unchanged
- Only shipment creation endpoints removed

---

## New Order & Shipping Flow

### Before (Insecure):
```
User places order → User creates shipment immediately → ShipRocket integration
```

### After (Secure):
```
User places order (status: pending)
    ↓
Admin reviews order
    ↓
Admin accepts order → Automatic shipment creation → ShipRocket integration
    ↓                      ↓
Order status: accepted → processing → shipped → delivered
```

### User Experience:
1. **Place Order**: User places order (gets `pending` status)
2. **Wait for Approval**: Order shows "awaiting approval" 
3. **Admin Accepts**: Order status changes to `accepted`, then `processing`
4. **Track Shipment**: User can now track the shipment using tracking APIs
5. **Delivery**: Normal delivery process continues

This ensures better security, cost control, and quality assurance while maintaining full tracking capabilities for users.