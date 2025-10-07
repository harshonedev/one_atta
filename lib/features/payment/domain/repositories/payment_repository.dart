import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentRepository {
  /// Get available payment methods
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  /// Create order with payment (follows /api/app/payments/create-order)
  /// Returns order details and razorpay information (if applicable)
  Future<Either<Failure, Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  });

  /// Verify Razorpay payment (follows /api/app/payments/verify)
  Future<Either<Failure, Map<String, dynamic>>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Confirm COD order (follows /api/app/payments/confirm-cod/:orderId)
  Future<Either<Failure, Map<String, dynamic>>> confirmCODOrder({
    required String orderId,
  });

  /// Handle payment failure (follows /api/app/payments/failure)
  Future<Either<Failure, Map<String, dynamic>>> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  });
}
