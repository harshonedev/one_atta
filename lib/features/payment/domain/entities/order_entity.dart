import 'package:equatable/equatable.dart';

/// Entity representing an order from the payment system
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String
  status; // 'pending', 'accepted', 'processing', 'shipped', 'delivered', 'cancelled', 'rejected'
  final String paymentStatus; // 'pending', 'completed', 'failed', 'refunded'
  final String paymentMethod; // 'Razorpay', 'COD', 'UPI', 'Card', 'Wallet'
  final String? actualPaymentMethod; // Actual method used (e.g., 'UPI', 'Card')
  final bool paymentVerified;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final double subtotal;
  final double discountAmount;
  final double loyaltyDiscountAmount;
  final double deliveryCharges;
  final double codCharges;
  final double totalAmount;
  final String deliveryAddressId;
  final List<String> contactNumbers;
  final String? couponCode;
  final int loyaltyPointsUsed;
  final DateTime? paymentCompletedAt;
  final String? paymentFailureReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.actualPaymentMethod,
    required this.paymentVerified,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.subtotal,
    required this.discountAmount,
    required this.loyaltyDiscountAmount,
    required this.deliveryCharges,
    required this.codCharges,
    required this.totalAmount,
    required this.deliveryAddressId,
    required this.contactNumbers,
    this.couponCode,
    required this.loyaltyPointsUsed,
    this.paymentCompletedAt,
    this.paymentFailureReason,
    required this.createdAt,
    this.updatedAt,
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'actualPaymentMethod': actualPaymentMethod,
      'paymentVerified': paymentVerified,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'loyaltyDiscountAmount': loyaltyDiscountAmount,
      'deliveryCharges': deliveryCharges,
      'codCharges': codCharges,
      'totalAmount': totalAmount,
      'deliveryAddressId': deliveryAddressId,
      'contactNumbers': contactNumbers,
      'couponCode': couponCode,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'paymentCompletedAt': paymentCompletedAt?.toIso8601String(),
      'paymentFailureReason': paymentFailureReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    paymentStatus,
    paymentMethod,
    actualPaymentMethod,
    paymentVerified,
    razorpayOrderId,
    razorpayPaymentId,
    subtotal,
    discountAmount,
    loyaltyDiscountAmount,
    deliveryCharges,
    codCharges,
    totalAmount,
    deliveryAddressId,
    contactNumbers,
    couponCode,
    loyaltyPointsUsed,
    paymentCompletedAt,
    paymentFailureReason,
    createdAt,
    updatedAt,
  ];
}

class OrderItem extends Equatable {
  final String id;
  final String type;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.type,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['item'] as String,
      type: json['item_type'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item': id, 'item_type': type, 'quantity': quantity};
  }

  @override
  List<Object> get props => [id, type, quantity];
}
