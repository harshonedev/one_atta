import 'package:one_atta/features/payment/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.orderId,
    required super.paymentMethodId,
    required super.paymentMethodType,
    required super.amount,
    required super.status,
    super.razorpayPaymentId,
    super.razorpayOrderId,
    super.razorpaySignature,
    super.metadata,
    required super.createdAt,
    super.updatedAt,
    super.failureReason,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      paymentMethodId: json['payment_method_id'] ?? '',
      paymentMethodType: json['payment_method_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpaySignature: json['razorpay_signature'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      failureReason: json['failure_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method_id': paymentMethodId,
      'payment_method_type': paymentMethodType,
      'amount': amount,
      'status': status,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'failure_reason': failureReason,
    };
  }

  @override
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? paymentMethodId,
    String? paymentMethodType,
    double? amount,
    String? status,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? failureReason,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
