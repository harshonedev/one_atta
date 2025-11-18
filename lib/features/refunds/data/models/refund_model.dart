import 'package:one_atta/features/refunds/domain/entities/refund_entity.dart';

class RefundModel extends RefundEntity {
  const RefundModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.amount,
    required super.status,
    required super.refundMethod,
    super.originalPaymentMethod,
    super.razorpayPaymentId,
    super.razorpayRefundId,
    super.cancellationReason,
    super.adminNotes,
    super.processedBy,
    super.processedAt,
    super.completedAt,
    super.failureReason,
    super.transactionReference,
    super.loyaltyPointsReversed,
    super.loyaltyPointsRedeemedRefunded,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['_id'] as String,
      orderId: json['order_id'] is String
          ? json['order_id'] as String
          : (json['order_id'] as Map<String, dynamic>)['_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      refundMethod: json['refund_method'] as String,
      originalPaymentMethod: json['original_payment_method'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      razorpayRefundId: json['razorpay_refund_id'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      processedBy: json['processed_by'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      failureReason: json['failure_reason'] as String?,
      transactionReference: json['transaction_reference'] as String?,
      loyaltyPointsReversed: json['loyalty_points_reversed'] as int?,
      loyaltyPointsRedeemedRefunded:
          json['loyalty_points_redeemed_refunded'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'status': status,
      'refund_method': refundMethod,
      'original_payment_method': originalPaymentMethod,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_refund_id': razorpayRefundId,
      'cancellation_reason': cancellationReason,
      'admin_notes': adminNotes,
      'processed_by': processedBy,
      'processed_at': processedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'failure_reason': failureReason,
      'transaction_reference': transactionReference,
      'loyalty_points_reversed': loyaltyPointsReversed,
      'loyalty_points_redeemed_refunded': loyaltyPointsRedeemedRefunded,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
