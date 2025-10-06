import 'package:equatable/equatable.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentEvent {}

class SelectPaymentMethod extends PaymentEvent {
  final PaymentMethodEntity paymentMethod;

  const SelectPaymentMethod(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class InitiatePayment extends PaymentEvent {
  final String orderId;
  final double amount;
  final Map<String, dynamic>? metadata;

  const InitiatePayment({
    required this.orderId,
    required this.amount,
    this.metadata,
  });

  @override
  List<Object?> get props => [orderId, amount, metadata];
}

class ProcessRazorpayPayment extends PaymentEvent {
  final String paymentId;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  const ProcessRazorpayPayment({
    required this.paymentId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  @override
  List<Object> get props => [
    paymentId,
    razorpayPaymentId,
    razorpayOrderId,
    razorpaySignature,
  ];
}

class HandlePaymentFailure extends PaymentEvent {
  final String paymentId;
  final String failureReason;

  const HandlePaymentFailure({
    required this.paymentId,
    required this.failureReason,
  });

  @override
  List<Object> get props => [paymentId, failureReason];
}

class ResetPaymentState extends PaymentEvent {}
