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
    required super.subtotal,
    super.couponCode,
    super.couponDiscount,
    super.loyaltyDiscount,
    super.deliveryFee,
    required super.totalAmount,
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
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      couponCode: json['coupon_code'],
      couponDiscount: (json['discount_amount'] ?? 0).toDouble(),
      loyaltyDiscount: (json['loyalty_discount'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
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
            },
          )
          .toList(),
      'delivery_address': deliveryAddress.id,
      'contact_numbers': contactNumbers,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'coupon_code': couponCode,
      'discount_amount': couponDiscount,
      'loyalty_discount': loyaltyDiscount,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
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
    double? subtotal,
    String? couponCode,
    double? couponDiscount,
    double? loyaltyDiscount,
    double? deliveryFee,
    double? totalAmount,
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
      subtotal: subtotal ?? this.subtotal,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
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
