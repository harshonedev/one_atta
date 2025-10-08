import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + (item.totalPrice * item.weightInKg));

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  CartItemEntity? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  CartEntity copyWith({List<CartItemEntity>? items}) {
    return CartEntity(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
