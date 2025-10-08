import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:one_atta/features/orders/data/models/order_model.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiRequest apiRequest;

  OrderRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<OrderModel> createOrder({
    required String token,
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
    // For development - return mock order
    final mockOrder = {
      '_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': 'user_123',
      'items': items
          .map(
            (item) => {
              'item_type': item.productType == 'Product' ? 'Product' : 'Blend',
              'item': {
                '_id': item.productId,
                'name': item.productName,
                'sku': 'SKU_${item.productId}',
              },
              'quantity': item.quantity,
              'price_per_kg': item.price,
              'total_price': item.price * item.quantity,
            },
          )
          .toList(),
      'status': 'pending',
      'delivery_address': {
        '_id': deliveryAddressId,
        'recipient_name': 'John Doe',
        'address_line1': '123 Main Street',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'postal_code': '400001',
        'country': 'India',
        'primary_phone': contactNumbers.isNotEmpty ? contactNumbers.first : '',
      },
      'contact_numbers': contactNumbers,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'coupon_code': couponCode,
      'discount_amount': couponDiscount,
      'loyalty_discount': loyaltyDiscount,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
      'special_instructions': specialInstructions,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return OrderModel.fromJson(mockOrder);

    // Uncomment below for actual API call
    /*
    final requestData = {
      'items': items.map((item) => {
        'item_type': item.productType == 'Product' ? 'Product' : 'Blend',
        'item': item.productId,
        'quantity': item.quantity,
      }).toList(),
      'delivery_address': deliveryAddressId,
      'contact_numbers': contactNumbers,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'coupon_code': couponCode,
      'discount_amount': couponDiscount,
      'loyalty_discount': loyaltyDiscount,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
      'special_instructions': specialInstructions,
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '${ApiEndpoints.orders}',
      token: token,
      data: requestData,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'])
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to create order',
              ),
      ApiError() => throw ServerException(
          message: response.failure.message,
        ),
    };
    */
  }

  @override
  Future<OrderModel> getOrderById(String token, String orderId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.orders}/$orderId',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'])
            : throw ServerException(
                message: response.data['message'] ?? 'Order not found',
              ),
      ApiError() => throw ServerException(message: response.failure.message),
    };
  }

  @override
  Future<List<OrderModel>> getUserOrders(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.orders}/my-orders',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List)
                  .map((order) => OrderModel.fromJson(order))
                  .toList()
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to fetch orders',
              ),
      ApiError() => throw ServerException(message: response.failure.message),
    };
  }

  @override
  Future<OrderModel> cancelOrder(
    String token,
    String orderId, {
    String? reason,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.delete,
      url: '${ApiEndpoints.orders}/$orderId',
      token: token,
      data: {'reason': reason},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'])
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to cancel order',
              ),
      ApiError() => throw ServerException(message: response.failure.message),
    };
  }

  @override
  Future<Map<String, dynamic>> trackOrder(String token, String orderId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.orders}/$orderId/track',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? response.data['data'] as Map<String, dynamic>
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to track order',
              ),
      ApiError() => throw ServerException(message: response.failure.message),
    };
  }

  @override
  Future<OrderModel> reorderOrder(
    String token,
    String originalOrderId, {
    String? deliveryAddressId,
    String? paymentMethod,
    List<CartItemEntity>? modifyItems,
  }) async {
    final requestData = {
      "delivery_address": deliveryAddressId,
      "payment_method": paymentMethod,
      "modify_items": modifyItems
          ?.map(
            (item) => {
              "item_type": item.productType == "Product" ? "Product" : "Blend",
              "item": item.productId,
              "quantity": item.quantity,
            },
          )
          .toList(),
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '${ApiEndpoints.orders}/$originalOrderId/reorder',
      token: token,
      data: requestData,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'])
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to reorder',
              ),
      ApiError() => throw ServerException(message: response.failure.message),
    };
  }
}
