import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/payment/data/models/create_order_response.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentRepository {
  /// Get available payment methods
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  /// Create order with payment (follows /api/app/payments/create-order)
  /// Returns order details and razorpay information (if applicable)
  /// NEW: All calculations done on frontend, backend validates
  Future<Either<Failure, CreateOrderResponse>> createOrder({
    required List<OrderItem> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    required double subtotal, // NEW: Pre-calculated
    required double discountAmount, // NEW: Pre-calculated
    required double deliveryCharges,
    required double codCharges,
    required double totalAmount, // NEW: Pre-calculated
    bool isDiscountAvailed = false, // NEW
    String? discountType, // NEW: "loyalty" or "coupon" or null
    String? couponCode,
    int loyaltyPointsUsed = 0,
  });

  /// Verify Razorpay payment (follows /api/app/payments/verify)
  Future<Either<Failure, OrderEntity>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Confirm COD order (follows /api/app/payments/confirm-cod/:orderId)
  Future<Either<Failure, OrderEntity>> confirmCODOrder({
    required String orderId,
  });

  /// Handle payment failure (follows /api/app/payments/failure)
  Future<Either<Failure, OrderEntity>> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  });
}
