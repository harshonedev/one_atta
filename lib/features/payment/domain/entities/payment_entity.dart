import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String orderId;
  final String paymentMethodId;
  final String paymentMethodType;
  final double amount;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? failureReason;

  const PaymentEntity({
    required this.id,
    required this.orderId,
    required this.paymentMethodId,
    required this.paymentMethodType,
    required this.amount,
    required this.status,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.failureReason,
  });

  PaymentEntity copyWith({
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
    return PaymentEntity(
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

  @override
  List<Object?> get props => [
    id,
    orderId,
    paymentMethodId,
    paymentMethodType,
    amount,
    status,
    razorpayPaymentId,
    razorpayOrderId,
    razorpaySignature,
    metadata,
    createdAt,
    updatedAt,
    failureReason,
  ];
}
