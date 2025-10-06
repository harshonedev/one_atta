import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/core/network/network_info.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';
import 'package:one_atta/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<CartItemEntity> items,
    required String deliveryAddressId,
    required List<String> contactNumbers,
    required String paymentMethod,
    required double subtotal,
    String? couponCode,
    double couponDiscount = 0.0,
    double loyaltyDiscount = 0.0,
    double deliveryFee = 0.0,
    required double totalAmount,
    String? specialInstructions,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.createOrder(
          items: items,
          deliveryAddressId: deliveryAddressId,
          contactNumbers: contactNumbers,
          paymentMethod: paymentMethod,
          subtotal: subtotal,
          couponCode: couponCode,
          couponDiscount: couponDiscount,
          loyaltyDiscount: loyaltyDiscount,
          deliveryFee: deliveryFee,
          totalAmount: totalAmount,
          specialInstructions: specialInstructions,
        );
        return Right(orderModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.getOrderById(orderId);
        return Right(orderModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModels = await remoteDataSource.getUserOrders(
          status: status,
          startDate: startDate,
          endDate: endDate,
          page: page,
          limit: limit,
        );
        return Right(orderModels);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(
    String orderId, {
    String? reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.cancelOrder(
          orderId,
          reason: reason,
        );
        return Right(orderModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> reorder(
    String originalOrderId, {
    String? deliveryAddressId,
    String? paymentMethod,
    List<CartItemEntity>? modifyItems,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.reorderOrder(
          originalOrderId,
          deliveryAddressId: deliveryAddressId,
          paymentMethod: paymentMethod,
          modifyItems: modifyItems,
        );
        return Right(orderModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
