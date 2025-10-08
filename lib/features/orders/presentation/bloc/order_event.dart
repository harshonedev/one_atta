import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrder extends OrderEvent {
  final List<CartItemEntity> items;
  final String deliveryAddressId;
  final List<String> contactNumbers;
  final String paymentMethod;
  final double subtotal;
  final String? couponCode;
  final double couponDiscount;
  final double loyaltyDiscount;
  final double deliveryFee;
  final double totalAmount;
  final String? specialInstructions;

  const CreateOrder({
    required this.items,
    required this.deliveryAddressId,
    required this.contactNumbers,
    required this.paymentMethod,
    required this.subtotal,
    this.couponCode,
    this.couponDiscount = 0.0,
    this.loyaltyDiscount = 0.0,
    this.deliveryFee = 0.0,
    required this.totalAmount,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
    items,
    deliveryAddressId,
    contactNumbers,
    paymentMethod,
    subtotal,
    couponCode,
    couponDiscount,
    loyaltyDiscount,
    deliveryFee,
    totalAmount,
    specialInstructions,
  ];
}

class LoadOrder extends OrderEvent {
  final String orderId;

  const LoadOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class LoadUserOrders extends OrderEvent {
  final int page;
  final int limit;

  const LoadUserOrders({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class CancelOrder extends OrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrder({required this.orderId, this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class ReorderOrder extends OrderEvent {
  final String originalOrderId;
  final String? deliveryAddressId;
  final String? paymentMethod;
  final List<CartItemEntity>? modifyItems;

  const ReorderOrder({
    required this.originalOrderId,
    this.deliveryAddressId,
    this.paymentMethod,
    this.modifyItems,
  });

  @override
  List<Object?> get props => [
    originalOrderId,
    deliveryAddressId,
    paymentMethod,
    modifyItems,
  ];
}

class TrackOrder extends OrderEvent {
  final String orderId;

  const TrackOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}
