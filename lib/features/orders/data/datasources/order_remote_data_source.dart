import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/orders/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
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

  Future<OrderModel> getOrderById(String orderId);

  Future<List<OrderModel>> getUserOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<OrderModel> cancelOrder(String orderId, {String? reason});

  Future<OrderModel> reorderOrder(
    String originalOrderId, {
    String? deliveryAddressId,
    String? paymentMethod,
    List<CartItemEntity>? modifyItems,
  });
}
