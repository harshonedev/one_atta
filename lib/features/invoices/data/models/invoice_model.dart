import 'package:one_atta/features/invoices/domain/entities/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.invoiceDate,
    required super.orderId,
    required super.totalAmount,
    required super.status,
    required super.paymentStatus,
    super.pdfUrl,
    super.shipmentDetails,
    super.pdfGeneratedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: json['invoice_date'] != null
          ? DateTime.parse(json['invoice_date'] as String)
          : DateTime.now(),
      orderId: json['order_id'] ?? '',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'draft',
      paymentStatus: json['payment_status'] ?? 'pending',
      pdfUrl: json['pdf_url'],
      shipmentDetails: json['shipment_details'] != null
          ? ShipmentDetailsModel.fromJson(
              json['shipment_details'] as Map<String, dynamic>,
            )
          : null,
      pdfGeneratedAt: json['pdf_generated_at'] != null
          ? DateTime.parse(json['pdf_generated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'order_id': orderId,
      'total_amount': totalAmount,
      'status': status,
      'payment_status': paymentStatus,
      'pdf_url': pdfUrl,
      'shipment_details': shipmentDetails != null
          ? (shipmentDetails! as ShipmentDetailsModel).toJson()
          : null,
      'pdf_generated_at': pdfGeneratedAt?.toIso8601String(),
    };
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      orderId: orderId,
      totalAmount: totalAmount,
      status: status,
      paymentStatus: paymentStatus,
      pdfUrl: pdfUrl,
      shipmentDetails: shipmentDetails,
      pdfGeneratedAt: pdfGeneratedAt,
    );
  }
}

class ShipmentDetailsModel extends ShipmentDetails {
  const ShipmentDetailsModel({
    super.shiprocketOrderId,
    super.shiprocketShipmentId,
    super.awbNumber,
    super.courierName,
    super.courierCompanyId,
    super.trackingUrl,
    super.currentStatus,
    super.expectedDeliveryDate,
    super.actualDeliveryDate,
    super.pickupScheduledDate,
    super.pickupTokenNumber,
  });

  factory ShipmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShipmentDetailsModel(
      shiprocketOrderId: json['shiprocket_order_id'],
      shiprocketShipmentId: json['shiprocket_shipment_id'],
      awbNumber: json['awb_number'],
      courierName: json['courier_name'],
      courierCompanyId: json['courier_company_id'],
      trackingUrl: json['tracking_url'],
      currentStatus: json['current_status'],
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'] as String)
          : null,
      pickupScheduledDate: json['pickup_scheduled_date'] != null
          ? DateTime.parse(json['pickup_scheduled_date'] as String)
          : null,
      pickupTokenNumber: json['pickup_token_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiprocket_order_id': shiprocketOrderId,
      'shiprocket_shipment_id': shiprocketShipmentId,
      'awb_number': awbNumber,
      'courier_name': courierName,
      'courier_company_id': courierCompanyId,
      'tracking_url': trackingUrl,
      'current_status': currentStatus,
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'pickup_scheduled_date': pickupScheduledDate?.toIso8601String(),
      'pickup_token_number': pickupTokenNumber,
    };
  }
}
