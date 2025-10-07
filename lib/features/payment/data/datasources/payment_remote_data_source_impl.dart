import 'package:dio/dio.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:one_atta/features/payment/data/models/payment_method_model.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      // For development - return hardcoded payment methods
      // In production, this should fetch from the API
      final List<Map<String, dynamic>> mockMethods = [
        {
          '_id': 'cod_001',
          'name': 'Cash on Delivery',
          'type': 'COD',
          'is_enabled': true,
          'description': 'Pay when your order is delivered',
        },
        {
          '_id': 'upi_001',
          'name': 'UPI Payment',
          'type': 'UPI',
          'is_enabled': true,
          'description': 'Pay using UPI apps like GPay, PhonePe, Paytm',
        },
        {
          '_id': 'card_001',
          'name': 'Credit/Debit Card',
          'type': 'Card',
          'is_enabled': true,
          'description': 'Pay using your credit or debit card',
        },
        {
          '_id': 'wallet_001',
          'name': 'Wallet',
          'type': 'Wallet',
          'is_enabled': true,
          'description': 'Pay using digital wallet',
        },
      ];

      return mockMethods
          .map((method) => PaymentMethodModel.fromJson(method))
          .toList();

      // Commented out the actual API call for development
      /*
      final response = await dio.get('/api/app/payment/methods');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> methodsJson = data['data'];
          return methodsJson
              .map((method) => PaymentMethodModel.fromJson(method))
              .toList();
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch payment methods',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch payment methods',
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
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  }) async {
    try {
      final requestData = {
        'items': items,
        'delivery_address': deliveryAddress,
        'contact_numbers': contactNumbers,
        'payment_method': paymentMethod,
        'delivery_charges': deliveryCharges,
        'cod_charges': codCharges,
      };

      // Add optional fields if provided
      if (couponCode != null && couponCode.isNotEmpty) {
        requestData['coupon_code'] = couponCode;
      }
      if (loyaltyPointsUsed != null && loyaltyPointsUsed > 0) {
        requestData['loyalty_points_used'] = loyaltyPointsUsed;
      }

      final response = await dio.post(
        '/api/app/payments/create-order',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
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
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await dio.post(
        '/api/app/payments/verify',
        data: {
          'order_id': orderId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to verify payment',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to verify payment',
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
        message: 'Unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> confirmCODOrder({
    required String orderId,
  }) async {
    try {
      final response = await dio.post('/api/app/payments/confirm-cod/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to confirm COD order',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to confirm COD order',
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
        message: 'Unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  }) async {
    try {
      final response = await dio.post(
        '/api/app/payments/failure',
        data: {
          'order_id': orderId,
          'razorpay_payment_id': razorpayPaymentId,
          'error': error,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to record payment failure',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to record payment failure',
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
        message: 'Unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
