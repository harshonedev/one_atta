import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
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
  });

  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, OrderEntity>> cancelOrder(
    String orderId, {
    String? reason,
  });

  Future<Either<Failure, OrderEntity>> reorder(
    String originalOrderId, {
    String? deliveryAddressId,
    String? paymentMethod,
    List<CartItemEntity>? modifyItems,
  });
}
