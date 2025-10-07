import 'package:equatable/equatable.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> paymentMethods;
  final PaymentMethodEntity? selectedPaymentMethod;

  const PaymentMethodsLoaded({
    required this.paymentMethods,
    this.selectedPaymentMethod,
  });

  PaymentMethodsLoaded copyWith({
    List<PaymentMethodEntity>? paymentMethods,
    PaymentMethodEntity? selectedPaymentMethod,
  }) {
    return PaymentMethodsLoaded(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [paymentMethods, selectedPaymentMethod];
}

/// Order created successfully (with Razorpay details if online payment)
class OrderCreated extends PaymentState {
  final Map<String, dynamic> order;
  final Map<String, dynamic>? razorpay; // null for COD

  const OrderCreated({required this.order, this.razorpay});

  @override
  List<Object?> get props => [order, razorpay];
}

/// Payment is being processed (Razorpay)
class PaymentProcessing extends PaymentState {
  final String orderId;

  const PaymentProcessing(this.orderId);

  @override
  List<Object> get props => [orderId];
}

/// Payment/Order completed successfully
class PaymentCompleted extends PaymentState {
  final Map<String, dynamic> order;

  const PaymentCompleted(this.order);

  @override
  List<Object> get props => [order];
}

/// Payment failed
class PaymentFailed extends PaymentState {
  final String message;
  final Map<String, dynamic>? order;

  const PaymentFailed({required this.message, this.order});

  @override
  List<Object?> get props => [message, order];
}

/// General payment error
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
