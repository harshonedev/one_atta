import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:one_atta/features/cart/data/models/cart_item_model.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cartItems = await localDataSource.getCartItems();
      return Right(CartEntity(items: cartItems));
    } catch (e) {
      return Left(CacheFailure('Failed to get cart items: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addItemToCart(CartItemEntity item) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(item);
      await localDataSource.insertCartItem(cartItemModel);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to add item to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeItemFromCart(String productId) async {
    try {
      await localDataSource.deleteCartItem(productId);
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to remove item from cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateItemQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        await localDataSource.deleteCartItem(productId);
      } else {
        final existingItem = await localDataSource.getCartItemByProductId(
          productId,
        );
        if (existingItem != null) {
          final updatedItem = existingItem.copyWith(
            quantity: quantity,
            updatedAt: DateTime.now(),
          );
          await localDataSource.updateCartItem(updatedItem);
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to update item quantity: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateItemWeight(
    String productId,
    int weightInKg,
  ) async {
    try {
      final existingItem = await localDataSource.getCartItemByProductId(
        productId,
      );
      if (existingItem != null) {
        // Calculate new price and MRP based on weight
        final pricePerKg = existingItem.price / existingItem.weightInKg;
        final mrpPerKg = existingItem.mrp / existingItem.weightInKg;

        final updatedItem = existingItem.copyWith(
          weightInKg: weightInKg,
          price: pricePerKg * weightInKg,
          mrp: mrpPerKg * weightInKg,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateCartItem(updatedItem);
      }
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to update item weight: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemCount() async {
    try {
      final count = await localDataSource.getCartItemCount();
      return Right(count);
    } catch (e) {
      return Left(
        CacheFailure('Failed to get cart item count: ${e.toString()}'),
      );
    }
  }
}
