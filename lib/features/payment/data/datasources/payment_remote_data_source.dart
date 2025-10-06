import 'package:one_atta/features/payment/data/models/payment_method_model.dart';
import 'package:one_atta/features/payment/data/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();

  Future<PaymentModel> createPayment({
    required String orderId,
    required String paymentMethodId,
    required double amount,
    Map<String, dynamic>? metadata,
  });

  Future<PaymentModel> processRazorpayPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });

  Future<PaymentModel> getPaymentById(String paymentId);

  Future<PaymentModel> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? failureReason,
  });
}
