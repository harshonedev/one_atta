import 'package:one_atta/features/payment/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    super.actualPaymentMethod,
    required super.paymentVerified,
    super.razorpayOrderId,
    super.razorpayPaymentId,
    required super.subtotal,
    required super.discountAmount,
    required super.loyaltyDiscountAmount,
    required super.deliveryCharges,
    required super.codCharges,
    required super.totalAmount,
    required super.deliveryAddressId,
    required super.contactNumbers,
    super.couponCode,
    required super.loyaltyPointsUsed,
    super.paymentCompletedAt,
    super.paymentFailureReason,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      userId: json['user_id'] is String
          ? json['user_id'] as String
          : (json['user_id'] as Map<String, dynamic>)['_id'] as String,
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String,
      actualPaymentMethod: json['actual_payment_method'] as String?,
      paymentVerified: json['payment_verified'] as bool? ?? false,
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      loyaltyDiscountAmount:
          (json['loyalty_discount_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharges: (json['delivery_charges'] as num?)?.toDouble() ?? 0.0,
      codCharges: (json['cod_charges'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddressId: json['delivery_address'] is String
          ? json['delivery_address'] as String
          : (json['delivery_address'] as Map<String, dynamic>)['_id'] as String,
      contactNumbers: (json['contact_numbers'] as List)
          .map((e) => e.toString())
          .toList(),
      couponCode: json['coupon_code'] as String?,
      loyaltyPointsUsed: json['loyalty_points_used'] as int? ?? 0,
      paymentCompletedAt: json['payment_completed_at'] != null
          ? DateTime.parse(json['payment_completed_at'] as String)
          : null,
      paymentFailureReason: json['payment_failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'actual_payment_method': actualPaymentMethod,
      'payment_verified': paymentVerified,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'loyalty_discount_amount': loyaltyDiscountAmount,
      'delivery_charges': deliveryCharges,
      'cod_charges': codCharges,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddressId,
      'contact_numbers': contactNumbers,
      'coupon_code': couponCode,
      'loyalty_points_used': loyaltyPointsUsed,
      'payment_completed_at': paymentCompletedAt?.toIso8601String(),
      'payment_failure_reason': paymentFailureReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      status: status,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      actualPaymentMethod: actualPaymentMethod,
      paymentVerified: paymentVerified,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      subtotal: subtotal,
      discountAmount: discountAmount,
      loyaltyDiscountAmount: loyaltyDiscountAmount,
      deliveryCharges: deliveryCharges,
      codCharges: codCharges,
      totalAmount: totalAmount,
      deliveryAddressId: deliveryAddressId,
      contactNumbers: contactNumbers,
      couponCode: couponCode,
      loyaltyPointsUsed: loyaltyPointsUsed,
      paymentCompletedAt: paymentCompletedAt,
      paymentFailureReason: paymentFailureReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
