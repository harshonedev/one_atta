import 'package:equatable/equatable.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';
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

/// Create order with payment (POST /api/app/payments/create-order)
class CreateOrder extends PaymentEvent {
  final List<OrderItem> items;
  final String deliveryAddress;
  final List<String> contactNumbers;
  final String paymentMethod;
  final String? couponCode;
  final int? loyaltyPointsUsed;
  final double deliveryCharges;
  final double codCharges;

  const CreateOrder({
    required this.items,
    required this.deliveryAddress,
    required this.contactNumbers,
    required this.paymentMethod,
    this.couponCode,
    this.loyaltyPointsUsed,
    required this.deliveryCharges,
    required this.codCharges,
  });

  @override
  List<Object?> get props => [
    items,
    deliveryAddress,
    contactNumbers,
    paymentMethod,
    couponCode,
    loyaltyPointsUsed,
    deliveryCharges,
    codCharges,
  ];
}

/// Verify Razorpay payment (POST /api/app/payments/verify)
class VerifyRazorpayPayment extends PaymentEvent {
  final String orderId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyRazorpayPayment({
    required this.orderId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object> get props => [
    orderId,
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature,
  ];
}

/// Confirm COD order (POST /api/app/payments/confirm-cod/:orderId)
class ConfirmCODOrder extends PaymentEvent {
  final String orderId;

  const ConfirmCODOrder({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

/// Handle payment failure (POST /api/app/payments/failure)
class HandlePaymentFailure extends PaymentEvent {
  final String orderId;
  final String razorpayPaymentId;
  final Map<String, dynamic> error;

  const HandlePaymentFailure({
    required this.orderId,
    required this.razorpayPaymentId,
    required this.error,
  });

  @override
  List<Object> get props => [orderId, razorpayPaymentId, error];
}

class ResetPaymentState extends PaymentEvent {}
