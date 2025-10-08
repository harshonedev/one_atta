import 'package:equatable/equatable.dart';

/// Entity representing Razorpay payment details
class RazorpayDetailsEntity extends Equatable {
  final String orderId; // Razorpay order ID
  final int amount; // Amount in paise
  final String currency; // e.g., 'INR'
  final String keyId; // Razorpay key ID

  const RazorpayDetailsEntity({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  @override
  List<Object> get props => [orderId, amount, currency, keyId];
}
