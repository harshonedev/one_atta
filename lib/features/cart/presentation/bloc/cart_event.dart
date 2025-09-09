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
