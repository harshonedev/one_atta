import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, Unit>> addItemToCart(CartItemEntity item);
  Future<Either<Failure, Unit>> removeItemFromCart(String productId);
  Future<Either<Failure, Unit>> updateItemQuantity(
    String productId,
    int quantity,
  );
  Future<Either<Failure, Unit>> clearCart();
  Future<Either<Failure, int>> getCartItemCount();
}
