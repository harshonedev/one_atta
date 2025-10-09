import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class ReloadCart extends CartEvent {}

class AddItemToCart extends CartEvent {
  final CartItemEntity item;

  const AddItemToCart({required this.item});

  @override
  List<Object> get props => [item];
}

class RemoveItemFromCart extends CartEvent {
  final String productId;

  const RemoveItemFromCart({required this.productId});

  @override
  List<Object> get props => [productId];
}

class UpdateItemQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateItemQuantity({required this.productId, required this.quantity});

  @override
  List<Object> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}

class LoadCartItemCount extends CartEvent {}

class ApplyCoupon extends CartEvent {
  final String couponCode;
  final double discountAmount;
  final CouponEntity? coupon; // CouponEntity

  const ApplyCoupon({
    required this.couponCode,
    required this.discountAmount,
    this.coupon,
  });

  @override
  List<Object> get props => [couponCode, discountAmount, ?coupon];
}

class RemoveCoupon extends CartEvent {}

class ApplyLoyaltyPoints extends CartEvent {
  final int points;
  final double discountAmount;

  const ApplyLoyaltyPoints({
    required this.points,
    required this.discountAmount,
  });

  @override
  List<Object> get props => [points, discountAmount];
}

class RemoveLoyaltyPoints extends CartEvent {}

class UpdateDeliveryCharges extends CartEvent {
  final double? deliveryCharges;
  final bool? isDeliveryFree;
  final double? deliveryThreshold;

  const UpdateDeliveryCharges({
    this.deliveryCharges,
    this.isDeliveryFree,
    this.deliveryThreshold,
  });

  @override
  List<Object> get props => [
    ?deliveryCharges,
    ?isDeliveryFree,
    ?deliveryThreshold,
  ];
}

class UpdateItemWeight extends CartEvent {
  final String productId;
  final int weightInKg;

  const UpdateItemWeight({required this.productId, required this.weightInKg});

  @override
  List<Object> get props => [productId, weightInKg];
}

class SelectAddress extends CartEvent {
  final dynamic address; // Can be AddressEntity

  const SelectAddress({required this.address});

  @override
  List<Object> get props => [address];
}

class ClearSelectedAddress extends CartEvent {}
