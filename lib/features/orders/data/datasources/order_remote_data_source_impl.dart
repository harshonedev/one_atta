import 'package:dio/dio.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:one_atta/features/orders/data/models/order_model.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
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
  }) async {
    try {
      // For development - return mock order
      final mockOrder = {
        '_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': 'user_123',
        'items': items
            .map(
              (item) => {
                'item_type': item.productType == 'Product'
                    ? 'Product'
                    : 'Blend',
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
          'primary_phone': contactNumbers.isNotEmpty
              ? contactNumbers.first
              : '',
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

      // Commented out the actual API call for development
      /*
      final response = await dio.post(
        '/api/app/orders',
        data: {
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
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to create order',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to create order',
          statusCode: response.statusCode ?? 500,
        );
      }
      */
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dio.get('/api/app/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Order not found',
            statusCode: response.statusCode ?? 404,
          );
        }
      } else {
        throw ServerException(
          message: 'Order not found',
          statusCode: response.statusCode ?? 404,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/api/app/orders/user/user_123', // TODO: Get actual user ID
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final ordersData = data['data']['orders'] as List;
          return ordersData.map((order) => OrderModel.fromJson(order)).toList();
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch orders',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch orders',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  @override
  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await dio.delete(
        '/api/app/orders/$orderId',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to cancel order',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to cancel order',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  @override
  Future<OrderModel> reorderOrder(
    String originalOrderId, {
    String? deliveryAddressId,
    String? paymentMethod,
    List<CartItemEntity>? modifyItems,
  }) async {
    try {
      final response = await dio.post(
        '/api/app/orders/$originalOrderId/reorder',
        data: {
          'delivery_address': deliveryAddressId,
          'payment_method': paymentMethod,
          'modify_items': modifyItems
              ?.map(
                (item) => {
                  'item_type': item.productType == 'Product'
                      ? 'Product'
                      : 'Blend',
                  'item': item.productId,
                  'quantity': item.quantity,
                },
              )
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to reorder',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to reorder',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }
}
