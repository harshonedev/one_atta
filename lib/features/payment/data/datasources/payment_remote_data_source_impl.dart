import 'package:dio/dio.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:one_atta/features/payment/data/models/payment_method_model.dart';
import 'package:one_atta/features/payment/data/models/payment_model.dart';

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
  Future<PaymentModel> createPayment({
    required String orderId,
    required String paymentMethodId,
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // For development - return mock payment
      final mockPayment = {
        '_id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'order_id': orderId,
        'payment_method_id': paymentMethodId,
        'payment_method_type': _getPaymentMethodType(paymentMethodId),
        'amount': amount,
        'status': paymentMethodId == 'cod_001' ? 'completed' : 'pending',
        'razorpay_order_id': paymentMethodId != 'cod_001'
            ? 'rzp_order_${DateTime.now().millisecondsSinceEpoch}'
            : null,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      };

      return PaymentModel.fromJson(mockPayment);

      // Commented out the actual API call for development
      /*
      final response = await dio.post(
        '/api/app/payment/create',
        data: {
          'order_id': orderId,
          'payment_method_id': paymentMethodId,
          'amount': amount,
          'metadata': metadata,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to create payment',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to create payment',
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

  String _getPaymentMethodType(String paymentMethodId) {
    switch (paymentMethodId) {
      case 'cod_001':
        return 'COD';
      case 'upi_001':
        return 'UPI';
      case 'card_001':
        return 'Card';
      case 'wallet_001':
        return 'Wallet';
      default:
        return 'Unknown';
    }
  }

  @override
  Future<PaymentModel> processRazorpayPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await dio.post(
        '/api/app/payment/razorpay/verify',
        data: {
          'payment_id': paymentId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
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
        message: 'Unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await dio.get('/api/app/payment/$paymentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Payment not found',
            statusCode: response.statusCode ?? 404,
          );
        }
      } else {
        throw ServerException(
          message: 'Payment not found',
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
  Future<PaymentModel> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? failureReason,
  }) async {
    try {
      final response = await dio.patch(
        '/api/app/payment/$paymentId/status',
        data: {'status': status, 'failure_reason': failureReason},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to update payment status',
            statusCode: response.statusCode ?? 500,
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to update payment status',
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
