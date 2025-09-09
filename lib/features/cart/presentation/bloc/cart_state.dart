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

  const CartLoaded({required this.cart, required this.itemCount});

  @override
  List<Object> get props => [cart, itemCount];
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
