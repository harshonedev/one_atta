import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:one_atta/features/payment/data/models/create_order_response.dart';
import 'package:one_atta/features/payment/data/models/order_model.dart';
import 'package:one_atta/features/payment/data/models/payment_method_model.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/payments';

  PaymentRemoteDataSourceImpl({required this.apiRequest});

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

      // TODO: Uncomment for production API call
      /*
      final response = await apiRequest.callRequest(
        method: HttpMethod.get,
        url: '$baseUrl/methods',
      );

      return switch (response) {
        ApiSuccess() => response.data['success'] == true
            ? (response.data['data'] as List<dynamic>)
                .map((method) => PaymentMethodModel.fromJson(method))
                .toList()
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to fetch payment methods',
                statusCode: 500,
              ),
        ApiError() => throw ServerException(
            message: response.failure.message,
            statusCode: 500,
          ),
      };
      */
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CreateOrderResponse> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  }) async {
    final requestData = {
      'items': items,
      'delivery_address': deliveryAddress,
      'contact_numbers': contactNumbers,
      'payment_method': paymentMethod,
      'delivery_charges': deliveryCharges,
      'cod_charges': codCharges,
      if (couponCode != null && couponCode.isNotEmpty)
        'coupon_code': couponCode,
      if (loyaltyPointsUsed != null && loyaltyPointsUsed > 0)
        'loyalty_points_used': loyaltyPointsUsed,
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/create-order',
      data: requestData,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? CreateOrderResponse.fromJson(
                response.data['data'] as Map<String, dynamic>,
              )
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to create order',
                statusCode: 500,
              ),
      ApiError() => throw ServerException(
        message: response.failure.message,
        statusCode: 500,
      ),
    };
  }

  @override
  Future<OrderModel> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/verify',
      data: {
        'order_id': orderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'] as Map<String, dynamic>)
            : throw ServerException(
                message: response.data['message'] ?? 'Failed to verify payment',
                statusCode: 500,
              ),
      ApiError() => throw ServerException(
        message: response.failure.message,
        statusCode: 500,
      ),
    };
  }

  @override
  Future<OrderModel> confirmCODOrder({required String orderId}) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/confirm-cod/$orderId',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'] as Map<String, dynamic>)
            : throw ServerException(
                message:
                    response.data['message'] ?? 'Failed to confirm COD order',
                statusCode: 500,
              ),
      ApiError() => throw ServerException(
        message: response.failure.message,
        statusCode: 500,
      ),
    };
  }

  @override
  Future<OrderModel> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/failure',
      data: {
        'order_id': orderId,
        'razorpay_payment_id': razorpayPaymentId,
        'error': error,
      },
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OrderModel.fromJson(response.data['data'] as Map<String, dynamic>)
            : throw ServerException(
                message:
                    response.data['message'] ??
                    'Failed to record payment failure',
                statusCode: 500,
              ),
      ApiError() => throw ServerException(
        message: response.failure.message,
        statusCode: 500,
      ),
    };
  }
}
