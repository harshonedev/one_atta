import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/orders/domain/entities/order_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final String
  status; // 'pending', 'accepted', 'rejected', 'processing', 'shipped', 'delivered', 'cancelled'
  final AddressEntity deliveryAddress;
  final List<String> contactNumbers;
  final String paymentMethod;
  final String paymentStatus; // 'pending', 'completed', 'failed', 'refunded'
  final bool paymentVerified;
  final DateTime? paymentCompletedAt;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final double subtotal;
  final CouponApplied? couponApplied;
  final String? couponCode;
  final double discountAmount;
  final int loyaltyPointsUsed;
  final double loyaltyDiscountAmount;
  final double deliveryCharges;
  final double codCharges;
  final double totalAmount;
  final String? actualPaymentMethod;
  final String? specialInstructions;
  final String? rejectionReason;
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.deliveryAddress,
    required this.contactNumbers,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentVerified,
    this.paymentCompletedAt,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.subtotal,
    this.couponApplied,
    this.couponCode,
    this.discountAmount = 0.0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyDiscountAmount = 0.0,
    this.deliveryCharges = 0.0,
    this.codCharges = 0.0,
    required this.totalAmount,
    this.actualPaymentMethod,
    this.specialInstructions,
    this.rejectionReason,
    this.acceptedBy,
    this.acceptedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    List<OrderItemEntity>? items,
    String? status,
    AddressEntity? deliveryAddress,
    List<String>? contactNumbers,
    String? paymentMethod,
    String? paymentStatus,
    bool? paymentVerified,
    DateTime? paymentCompletedAt,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    double? subtotal,
    CouponApplied? couponApplied,
    String? couponCode,
    double? discountAmount,
    int? loyaltyPointsUsed,
    double? loyaltyDiscountAmount,
    double? deliveryCharges,
    double? codCharges,
    double? totalAmount,
    String? actualPaymentMethod,
    String? specialInstructions,
    String? rejectionReason,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactNumbers: contactNumbers ?? this.contactNumbers,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      paymentCompletedAt: paymentCompletedAt ?? this.paymentCompletedAt,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      subtotal: subtotal ?? this.subtotal,
      couponApplied: couponApplied ?? this.couponApplied,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyDiscountAmount:
          loyaltyDiscountAmount ?? this.loyaltyDiscountAmount,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      codCharges: codCharges ?? this.codCharges,
      totalAmount: totalAmount ?? this.totalAmount,
      actualPaymentMethod: actualPaymentMethod ?? this.actualPaymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    status,
    deliveryAddress,
    contactNumbers,
    paymentMethod,
    paymentStatus,
    paymentVerified,
    paymentCompletedAt,
    razorpayOrderId,
    razorpayPaymentId,
    subtotal,
    couponApplied,
    couponCode,
    discountAmount,
    loyaltyPointsUsed,
    loyaltyDiscountAmount,
    deliveryCharges,
    codCharges,
    totalAmount,
    actualPaymentMethod,
    specialInstructions,
    rejectionReason,
    acceptedBy,
    acceptedAt,
    rejectedAt,
    createdAt,
    updatedAt,
  ];
}

class CouponApplied extends Equatable {
  final String id;
  final String code;
  final String name;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;

  const CouponApplied({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
  });

  @override
  List<Object?> get props => [id, code, name, discountType, discountValue];
}
