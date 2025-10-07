import 'package:one_atta/features/payment/data/models/payment_method_model.dart';

abstract class PaymentRemoteDataSource {
  /// Get available payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods();

  /// Create order with payment (POST /api/app/payments/create-order)
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  });

  /// Verify Razorpay payment (POST /api/app/payments/verify)
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Confirm COD order (POST /api/app/payments/confirm-cod/:orderId)
  Future<Map<String, dynamic>> confirmCODOrder({required String orderId});

  /// Handle payment failure (POST /api/app/payments/failure)
  Future<Map<String, dynamic>> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  });
}
