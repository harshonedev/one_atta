import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

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

  const ApplyCoupon({required this.couponCode, required this.discountAmount});

  @override
  List<Object> get props => [couponCode, discountAmount];
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

class UpdateCartPricing extends CartEvent {
  final double? couponDiscount;
  final double? loyaltyDiscount;

  const UpdateCartPricing({this.couponDiscount, this.loyaltyDiscount});

  @override
  List<Object> get props => [couponDiscount ?? 0.0, loyaltyDiscount ?? 0.0];
}
