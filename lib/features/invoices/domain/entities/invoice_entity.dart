import 'package:equatable/equatable.dart';

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String orderId;
  final double totalAmount;
  final String status; // draft, issued, paid, cancelled, refunded
  final String paymentStatus; // pending, completed, failed, refunded
  final String? pdfUrl;
  final ShipmentDetails? shipmentDetails;
  final DateTime? pdfGeneratedAt;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.orderId,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.pdfUrl,
    this.shipmentDetails,
    this.pdfGeneratedAt,
  });

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    invoiceDate,
    orderId,
    totalAmount,
    status,
    paymentStatus,
    pdfUrl,
    shipmentDetails,
    pdfGeneratedAt,
  ];
}

class ShipmentDetails extends Equatable {
  final String? shiprocketOrderId;
  final String? shiprocketShipmentId;
  final String? awbNumber;
  final String? courierName;
  final int? courierCompanyId;
  final String? trackingUrl;
  final String? currentStatus;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final DateTime? pickupScheduledDate;
  final String? pickupTokenNumber;

  const ShipmentDetails({
    this.shiprocketOrderId,
    this.shiprocketShipmentId,
    this.awbNumber,
    this.courierName,
    this.courierCompanyId,
    this.trackingUrl,
    this.currentStatus,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.pickupScheduledDate,
    this.pickupTokenNumber,
  });

  @override
  List<Object?> get props => [
    shiprocketOrderId,
    shiprocketShipmentId,
    awbNumber,
    courierName,
    courierCompanyId,
    trackingUrl,
    currentStatus,
    expectedDeliveryDate,
    actualDeliveryDate,
    pickupScheduledDate,
    pickupTokenNumber,
  ];
}
