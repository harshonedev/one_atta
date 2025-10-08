import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/payment/domain/repositories/payment_repository.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<CreateOrder>(_onCreateOrder);
    on<VerifyRazorpayPayment>(_onVerifyRazorpayPayment);
    on<ConfirmCODOrder>(_onConfirmCODOrder);
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

  /// Create order with payment (POST /api/app/payments/create-order)
  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    final result = await paymentRepository.createOrder(
      items: event.items,
      deliveryAddress: event.deliveryAddress,
      contactNumbers: event.contactNumbers,
      paymentMethod: event.paymentMethod,
      couponCode: event.couponCode,
      loyaltyPointsUsed: event.loyaltyPointsUsed,
      deliveryCharges: event.deliveryCharges,
      codCharges: event.codCharges,
    );

    result.fold((failure) => emit(PaymentError(failure.message)), (response) {
      emit(OrderCreated(order: response.order, razorpay: response.razorpay));
    });
  }

  /// Verify Razorpay payment (POST /api/app/payments/verify)
  Future<void> _onVerifyRazorpayPayment(
    VerifyRazorpayPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentProcessing(event.orderId));

    final result = await paymentRepository.verifyPayment(
      orderId: event.orderId,
      razorpayOrderId: event.razorpayOrderId,
      razorpayPaymentId: event.razorpayPaymentId,
      razorpaySignature: event.razorpaySignature,
    );

    result.fold(
      (failure) => emit(PaymentFailed(message: failure.message)),
      (order) => emit(PaymentCompleted(order)),
    );
  }

  /// Confirm COD order (POST /api/app/payments/confirm-cod/:orderId)
  Future<void> _onConfirmCODOrder(
    ConfirmCODOrder event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentProcessing(event.orderId));

    final result = await paymentRepository.confirmCODOrder(
      orderId: event.orderId,
    );

    result.fold(
      (failure) => emit(PaymentFailed(message: failure.message)),
      (order) => emit(PaymentCompleted(order)),
    );
  }

  /// Handle payment failure (POST /api/app/payments/failure)
  Future<void> _onHandlePaymentFailure(
    HandlePaymentFailure event,
    Emitter<PaymentState> emit,
  ) async {
    final result = await paymentRepository.handlePaymentFailure(
      orderId: event.orderId,
      razorpayPaymentId: event.razorpayPaymentId,
      error: event.error,
    );

    result.fold(
      (failure) => emit(PaymentFailed(message: failure.message)),
      (order) => emit(PaymentFailed(message: 'Payment failed', order: order)),
    );
  }

  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<PaymentState> emit,
  ) {
    emit(PaymentInitial());
  }
}
