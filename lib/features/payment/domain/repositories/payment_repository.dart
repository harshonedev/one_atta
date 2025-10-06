import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/payment/domain/entities/payment_entity.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  Future<Either<Failure, PaymentEntity>> createPayment({
    required String orderId,
    required String paymentMethodId,
    required double amount,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, PaymentEntity>> processRazorpayPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });

  Future<Either<Failure, PaymentEntity>> getPaymentById(String paymentId);

  Future<Either<Failure, PaymentEntity>> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? failureReason,
  });
}
