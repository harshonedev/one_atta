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
  final double subtotal;
  final String? couponCode;
  final double couponDiscount;
  final double loyaltyDiscount;
  final double deliveryFee;
  final double totalAmount;
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
    required this.subtotal,
    this.couponCode,
    this.couponDiscount = 0.0,
    this.loyaltyDiscount = 0.0,
    this.deliveryFee = 0.0,
    required this.totalAmount,
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
    return OrderEntity(
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

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    status,
    deliveryAddress,
    contactNumbers,
    paymentMethod,
    subtotal,
    couponCode,
    couponDiscount,
    loyaltyDiscount,
    deliveryFee,
    totalAmount,
    specialInstructions,
    rejectionReason,
    acceptedBy,
    acceptedAt,
    rejectedAt,
    createdAt,
    updatedAt,
  ];
}
