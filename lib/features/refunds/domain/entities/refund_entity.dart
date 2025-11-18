class RefundEntity {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String status;
  final String refundMethod;
  final String? originalPaymentMethod;
  final String? razorpayPaymentId;
  final String? razorpayRefundId;
  final String? cancellationReason;
  final String? adminNotes;
  final String? processedBy;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? transactionReference;
  final int? loyaltyPointsReversed;
  final int? loyaltyPointsRedeemedRefunded;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RefundEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.refundMethod,
    this.originalPaymentMethod,
    this.razorpayPaymentId,
    this.razorpayRefundId,
    this.cancellationReason,
    this.adminNotes,
    this.processedBy,
    this.processedAt,
    this.completedAt,
    this.failureReason,
    this.transactionReference,
    this.loyaltyPointsReversed,
    this.loyaltyPointsRedeemedRefunded,
    required this.createdAt,
    required this.updatedAt,
  });
}
