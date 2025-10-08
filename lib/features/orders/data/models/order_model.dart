import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/orders/data/models/order_item_model.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';
import 'package:one_atta/features/orders/domain/entities/order_item_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.status,
    required super.deliveryAddress,
    required super.contactNumbers,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.paymentVerified,
    super.paymentCompletedAt,
    super.razorpayOrderId,
    super.razorpayPaymentId,
    required super.subtotal,
    super.couponApplied,
    super.couponCode,
    super.discountAmount,
    super.loyaltyPointsUsed,
    super.loyaltyDiscountAmount,
    super.deliveryCharges,
    super.codCharges,
    required super.totalAmount,
    super.actualPaymentMethod,
    super.specialInstructions,
    super.rejectionReason,
    super.acceptedBy,
    super.acceptedAt,
    super.rejectedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] is Map
          ? json['user_id']['_id'] ?? ''
          : json['user_id'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      status: json['status'] ?? '',
      deliveryAddress: AddressModel.fromJson(json['delivery_address'] ?? {}),
      contactNumbers: List<String>.from(json['contact_numbers'] ?? []),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentVerified: json['payment_verified'] ?? false,
      paymentCompletedAt: json['payment_completed_at'] != null
          ? DateTime.parse(json['payment_completed_at'])
          : null,
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      couponApplied: json['coupon_applied'] != null
          ? CouponApplied(
              id: json['coupon_applied']['_id'] ?? '',
              code: json['coupon_applied']['code'] ?? '',
              name: json['coupon_applied']['name'] ?? '',
              discountType: json['coupon_applied']['discount_type'] ?? '',
              discountValue: (json['coupon_applied']['discount_value'] ?? 0)
                  .toDouble(),
            )
          : null,
      couponCode: json['coupon_code'],
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      loyaltyPointsUsed: (json['loyalty_points_used'] ?? 0).toInt(),
      loyaltyDiscountAmount: (json['loyalty_discount_amount'] ?? 0).toDouble(),
      deliveryCharges: (json['delivery_charges'] ?? 0).toDouble(),
      codCharges: (json['cod_charges'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      actualPaymentMethod: json['actual_payment_method'],
      specialInstructions: json['special_instructions'],
      rejectionReason: json['rejection_reason'],
      acceptedBy: json['accepted_by'],
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items
          .map(
            (item) => {
              'item_type': item.itemType,
              'item': item.itemId,
              'quantity': item.quantity,
              'price_per_kg': item.pricePerKg,
              'total_price': item.totalPrice,
            },
          )
          .toList(),
      'delivery_address': deliveryAddress.id,
      'contact_numbers': contactNumbers,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_verified': paymentVerified,
      'payment_completed_at': paymentCompletedAt?.toIso8601String(),
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'subtotal': subtotal,
      'coupon_applied': couponApplied != null
          ? {
              '_id': couponApplied!.id,
              'code': couponApplied!.code,
              'name': couponApplied!.name,
              'discount_type': couponApplied!.discountType,
              'discount_value': couponApplied!.discountValue,
            }
          : null,
      'coupon_code': couponCode,
      'discount_amount': discountAmount,
      'loyalty_points_used': loyaltyPointsUsed,
      'loyalty_discount_amount': loyaltyDiscountAmount,
      'delivery_charges': deliveryCharges,
      'cod_charges': codCharges,
      'total_amount': totalAmount,
      'actual_payment_method': actualPaymentMethod,
      'special_instructions': specialInstructions,
    };
  }

  @override
  OrderModel copyWith({
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
    return OrderModel(
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
}
