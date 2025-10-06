import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/payment/domain/repositories/payment_repository.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<InitiatePayment>(_onInitiatePayment);
    on<ProcessRazorpayPayment>(_onProcessRazorpayPayment);
    on<HandlePaymentFailure>(_onHandlePaymentFailure);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    final result = await paymentRepository.getPaymentMethods();
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (paymentMethods) =>
          emit(PaymentMethodsLoaded(paymentMethods: paymentMethods)),
    );
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<PaymentState> emit,
  ) {
    if (state is PaymentMethodsLoaded) {
      final currentState = state as PaymentMethodsLoaded;
      emit(currentState.copyWith(selectedPaymentMethod: event.paymentMethod));
    }
  }

  Future<void> _onInitiatePayment(
    InitiatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    if (state is PaymentMethodsLoaded) {
      final currentState = state as PaymentMethodsLoaded;
      final selectedMethod = currentState.selectedPaymentMethod;

      if (selectedMethod == null) {
        emit(const PaymentError('Please select a payment method'));
        return;
      }

      emit(PaymentLoading());

      final result = await paymentRepository.createPayment(
        orderId: event.orderId,
        paymentMethodId: selectedMethod.id,
        amount: event.amount,
        metadata: event.metadata,
      );

      result.fold((failure) => emit(PaymentError(failure.message)), (payment) {
        if (selectedMethod.type == 'COD') {
          // For COD, payment is completed immediately
          emit(PaymentCompleted(payment));
        } else {
          // For online payments, create payment and wait for processing
          emit(PaymentCreated(payment));
        }
      });
    }
  }

  Future<void> _onProcessRazorpayPayment(
    ProcessRazorpayPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      PaymentProcessing(
        state is PaymentCreated
            ? (state as PaymentCreated).payment
            : state is PaymentProcessing
            ? (state as PaymentProcessing).payment
            :
              // Fallback if state doesn't have payment
              throw StateError('Invalid state for processing payment'),
      ),
    );

    final result = await paymentRepository.processRazorpayPayment(
      paymentId: event.paymentId,
      razorpayPaymentId: event.razorpayPaymentId,
      razorpayOrderId: event.razorpayOrderId,
      razorpaySignature: event.razorpaySignature,
    );

    result.fold(
      (failure) => emit(PaymentFailed(message: failure.message)),
      (payment) => emit(PaymentCompleted(payment)),
    );
  }

  Future<void> _onHandlePaymentFailure(
    HandlePaymentFailure event,
    Emitter<PaymentState> emit,
  ) async {
    final result = await paymentRepository.updatePaymentStatus(
      paymentId: event.paymentId,
      status: 'failed',
      failureReason: event.failureReason,
    );

    result.fold(
      (failure) => emit(PaymentFailed(message: failure.message)),
      (payment) =>
          emit(PaymentFailed(message: event.failureReason, payment: payment)),
    );
  }

  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<PaymentState> emit,
  ) {
    emit(PaymentInitial());
  }
}
