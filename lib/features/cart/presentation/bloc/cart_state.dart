import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;
  final int itemCount;
  final double mrpTotal; // Total MRP value
  final double itemTotal; // Actual item total (with any product discounts)
  final double deliveryFee; // Delivery fee
  final double couponDiscount; // Discount from coupons
  final double loyaltyDiscount; // Discount from loyalty points
  final double savingsTotal; // Total savings amount
  final double toPayTotal; // Final amount to pay

  const CartLoaded({
    required this.cart,
    required this.itemCount,
    this.mrpTotal = 0.0,
    this.itemTotal = 0.0,
    this.deliveryFee = 0.0,
    this.couponDiscount = 0.0,
    this.loyaltyDiscount = 0.0,
    this.savingsTotal = 0.0,
    this.toPayTotal = 0.0,
  });

  @override
  List<Object> get props => [
    cart,
    itemCount,
    mrpTotal,
    itemTotal,
    deliveryFee,
    couponDiscount,
    loyaltyDiscount,
    savingsTotal,
    toPayTotal,
  ];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}

class CartItemAdded extends CartState {
  final String message;

  const CartItemAdded({required this.message});

  @override
  List<Object> get props => [message];
}

class CartItemRemoved extends CartState {
  final String message;

  const CartItemRemoved({required this.message});

  @override
  List<Object> get props => [message];
}

class CartCleared extends CartState {
  final String message;

  const CartCleared({required this.message});

  @override
  List<Object> get props => [message];
}
