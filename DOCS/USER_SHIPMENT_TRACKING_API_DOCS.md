# User Shipment Tracking API Documentation

## Overview
The User Shipment Tracking API provides comprehensive tracking capabilities for customers to monitor their shipments throughout the delivery process. This API is designed with a security-first approach where users can only access shipments for their own orders, and all shipment creation is handled through the admin workflow.

### Key Features
- **Order-Based Tracking**: Track shipments linked to user orders
- **Real-Time Updates**: Live status updates from courier partners
- **Historical Tracking**: Complete shipment journey with timestamps
- **Multi-Format Support**: Support for web and mobile applications
- **Security First**: Users can only access their own shipments

### Security Model
- **User Isolation**: Users can only track shipments for their own orders
- **No Direct Creation**: Shipments are created only through admin approval workflow
- **Read-Only Access**: All user tracking endpoints are read-only
- **JWT Protection**: All endpoints require valid user authentication

## Base URL
```
/api/app/shipping
```

## Authentication
All endpoints require user authentication:
```
Authorization: Bearer <jwt_token>
```

For mobile applications:
```
x-api-key: <mobile_api_key>
```

## Table of Contents
1. [Utility Functions](#1-check-serviceability)
2. [Shipment Tracking](#3-get-user-shipments)
3. [Status Reference](#shipment-status-values)
4. [Error Handling](#error-handling)
5. [Usage Guidelines](#usage-notes)

## Endpoints

### 1. Check Serviceability
**GET** `/api/app/shipping/check-serviceability`

Check if delivery is available to a specific pincode.

**Query Parameters:**
- `deliveryPincode` (string, required): Destination pincode
- `weight` (number, required): Package weight in kg

**Response:**
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
        "rating": 4.3,
        "eta": "2024-01-25"
      }
    ],
    "pickup_postcode": "110001",
    "delivery_postcode": "400001",
    "weight": 1.0
  }
}
```

### 2. Get Shipping Rates
**GET** `/api/app/shipping/shipping-rates`

Get shipping rates for different courier services.

**Query Parameters:**
- `deliveryPincode` (string, required): Destination pincode
- `weight` (number, required): Package weight in kg
- `cod` (boolean, optional): Whether COD is required

**Response:**
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
      }
    ],
    "pickup_postcode": "110001",
    "delivery_postcode": "400001",
    "weight": 1.0,
    "cod": true
  }
}
```

### 3. Get User Shipments
**GET** `/api/app/shipping/my-shipments`

Get all shipments for the authenticated user with comprehensive filtering options.

**Query Parameters (all optional):**
- `status` (string): Filter by shipment status
- `startDate` (string): Filter from date (YYYY-MM-DD)
- `endDate` (string): Filter to date (YYYY-MM-DD)
- `limit` (number): Maximum number of results (default: 20, max: 100)
- `page` (number): Page number for pagination (default: 1)
- `sortBy` (string): Sort by field (`created_at`, `updated_at`, `expected_delivery_date`)
- `sortOrder` (string): Sort direction (`asc`, `desc`, default: `desc`)

**Example Request:**
```bash
GET /api/app/shipping/my-shipments?status=IN_TRANSIT&limit=10&page=1&sortBy=created_at&sortOrder=desc
```

**Response:**
```json
{
  "success": true,
  "message": "User shipments retrieved successfully",
  "data": {
    "shipments": [
      {
        "_id": "shipment_id",
        "order_id": {
          "_id": "order_id",
          "items": [
            {
              "item_type": "Product",
              "item": {
                "name": "Organic Wheat Flour",
                "sku": "OWF001"
              },
              "quantity": 2,
              "total_price": 90
            }
          ],
          "status": "processing",
          "total_amount": 135.50,
          "created_at": "2024-01-20T10:00:00Z"
        },
        "awb_number": "AWB123456789",
        "courier_name": "Delhivery",
        "current_status": "IN_TRANSIT",
        "expected_delivery_date": "2024-01-25T00:00:00Z",
        "tracking_url": "https://www.delhivery.com/track/...",
        "created_at": "2024-01-20T12:00:00Z",
        "updated_at": "2024-01-23T09:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_count": 25,
      "has_next": true,
      "has_prev": false,
      "per_page": 10
    },
    "summary": {
      "total_shipments": 25,
      "in_transit": 5,
      "delivered": 18,
      "pending": 2
    }
  }
}
```

**Empty Response:**
```json
{
  "success": true,
  "message": "No shipments found",
  "data": {
    "shipments": [],
    "pagination": {
      "current_page": 1,
      "total_pages": 0,
      "total_count": 0,
      "has_next": false,
      "has_prev": false,
      "per_page": 10
    }
  }
}
```
      {
        "_id": "shipment_id",
        "order_id": {
          "_id": "order_id",
          "items": [...],
          "status": "processing",
          "created_at": "2024-01-20T10:00:00Z"
        },
        "awb_number": "AWB123456789",
        "courier_name": "Delhivery",
        "current_status": "IN_TRANSIT",
        "expected_delivery_date": "2024-01-25T00:00:00Z",
        "created_at": "2024-01-20T12:00:00Z"
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
- `orderId` (string, required): Order ID

**Response:**
```json
{
  "success": true,
  "message": "Shipment details retrieved successfully",
  "data": {
    "_id": "shipment_id",
    "order_id": {
      "_id": "order_id",
      "items": [...],
      "status": "processing"
    },
    "awb_number": "AWB123456789",
    "courier_name": "Delhivery",
    "current_status": "PICKED_UP",
    "tracking_url": "https://www.delhivery.com/track/...",
    "expected_delivery_date": "2024-01-25T00:00:00Z",
    "status_history": [
      {
        "status": "NEW",
        "status_datetime": "2024-01-20T12:00:00Z",
        "remarks": "Shipment created"
      },
      {
        "status": "PICKED_UP",
        "status_datetime": "2024-01-21T09:30:00Z",
        "location": "Mumbai",
        "remarks": "Package picked up from seller"
      }
    ]
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

Get real-time tracking data for a specific shipment.

**Path Parameters:**
- `shipmentId` (string, required): Shipment ID

**Response:**
```json
{
  "success": true,
  "message": "Shipment tracking data retrieved successfully",
  "data": {
    "shipment_id": "shipment_id",
    "order_id": "order_id",
    "awb_number": "AWB123456789",
    "courier_name": "Delhivery",
    "current_status": "OUT_FOR_DELIVERY",
    "tracking_url": "https://www.delhivery.com/track/...",
    "expected_delivery_date": "2024-01-25T00:00:00Z",
    "actual_delivery_date": null,
    "status_history": [
      {
        "status": "NEW",
        "status_datetime": "2024-01-20T12:00:00Z",
        "remarks": "Shipment created"
      },
      {
        "status": "OUT_FOR_DELIVERY",
        "status_datetime": "2024-01-25T08:00:00Z",
        "location": "Mumbai",
        "remarks": "Out for delivery"
      }
    ],
    "live_tracking": [
      {
        "date": "2024-01-25T08:00:00Z",
        "location": "Mumbai",
        "message": "Out for delivery",
        "activity": "Package is out for delivery"
      }
    ],
    "last_updated": "2024-01-25T08:00:00Z"
  }
}
```

## Shipment Status Values

- `NEW` - Shipment created but AWB not assigned
- `AWB_ASSIGNED` - AWB number assigned
- `PICKUP_SCHEDULED` - Pickup scheduled with courier
- `PICKED_UP` - Package picked up by courier
- `IN_TRANSIT` - Package in transit
- `OUT_FOR_DELIVERY` - Package out for delivery
- `DELIVERED` - Package delivered successfully
- `RTO_INITIATED` - Return to origin initiated
- `RTO_DELIVERED` - Returned to origin
- `CANCELLED` - Shipment cancelled
- `LOST` - Package lost
- `DAMAGED` - Package damaged

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200` - Success
- `400` - Bad request (missing parameters)
- `401` - Unauthorized (not logged in)
- `403` - Forbidden (access denied)
- `404` - Not found (order/shipment not found)
- `500` - Internal server error

## Usage Notes

1. **Order Flow**: Users place orders → Admin accepts → Shipment automatically created
2. **Access Control**: Users can only access their own shipments
3. **Tracking Updates**: Tracking data is updated in real-time when accessed
4. **Development Mode**: Mock data is returned when ShipRocket credentials are not configured
5. **No Shipment Creation**: Users cannot create shipments - this is admin-only functionality

## Authentication

All endpoints require authentication via JWT token:
```
Authorization: Bearer <jwt_token>
```

Or via API key for mobile apps:
```
x-api-key: <mobile_api_key>
```