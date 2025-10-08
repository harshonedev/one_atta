import 'package:one_atta/features/payment/data/models/create_order_response.dart';
import 'package:one_atta/features/payment/data/models/order_model.dart';
import 'package:one_atta/features/payment/data/models/payment_method_model.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';

abstract class PaymentRemoteDataSource {
  /// Get available payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods();

  /// Create order with payment (POST /api/app/payments/create-order)
  Future<CreateOrderResponse> createOrder({
    required String token,
    required List<OrderItem> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  });

  /// Verify Razorpay payment (POST /api/app/payments/verify)
  Future<OrderModel> verifyPayment({
    required String token,
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Confirm COD order (POST /api/app/payments/confirm-cod/:orderId)
  Future<OrderModel> confirmCODOrder({
    required String token,
    required String orderId,
  });

  /// Handle payment failure (POST /api/app/payments/failure)
  Future<OrderModel> handlePaymentFailure({
    required String token,
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  });
}
