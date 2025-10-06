import 'package:equatable/equatable.dart';
import 'package:one_atta/features/payment/domain/entities/payment_entity.dart';
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

class PaymentCreated extends PaymentState {
  final PaymentEntity payment;

  const PaymentCreated(this.payment);

  @override
  List<Object> get props => [payment];
}

class PaymentProcessing extends PaymentState {
  final PaymentEntity payment;

  const PaymentProcessing(this.payment);

  @override
  List<Object> get props => [payment];
}

class PaymentCompleted extends PaymentState {
  final PaymentEntity payment;

  const PaymentCompleted(this.payment);

  @override
  List<Object> get props => [payment];
}

class PaymentFailed extends PaymentState {
  final String message;
  final PaymentEntity? payment;

  const PaymentFailed({required this.message, this.payment});

  @override
  List<Object?> get props => [message, payment];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
