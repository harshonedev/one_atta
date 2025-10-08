import 'package:one_atta/features/payment/domain/entities/razorpay_details_entity.dart';

class RazorpayDetailsModel extends RazorpayDetailsEntity {
  const RazorpayDetailsModel({
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.keyId,
  });

  factory RazorpayDetailsModel.fromJson(Map<String, dynamic> json) {
    return RazorpayDetailsModel(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(), // Handle both int and double
      currency: json['currency'] as String,
      keyId: json['key_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'key_id': keyId,
    };
  }

  RazorpayDetailsEntity toEntity() {
    return RazorpayDetailsEntity(
      orderId: orderId,
      amount: amount,
      currency: currency,
      keyId: keyId,
    );
  }
}
