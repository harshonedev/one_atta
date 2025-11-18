import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/orders/domain/repositories/order_repository.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_event.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_state.dart';
import 'package:one_atta/features/refunds/domain/repositories/refund_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final RefundRepository refundRepository;

  OrderBloc({required this.orderRepository, required this.refundRepository})
    : super(OrderInitial()) {
    on<LoadOrder>(_onLoadOrder);
    on<LoadUserOrders>(_onLoadUserOrders);
    on<CancelOrder>(_onCancelOrder);
    on<ReorderOrder>(_onReorderOrder);
    on<TrackOrder>(_onTrackOrder);
  }

  Future<void> _onLoadOrder(LoadOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    final result = await orderRepository.getOrderById(event.orderId);

    await result.fold(
      (failure) async => emit(OrderError(failure.message, failure: failure)),
      (order) async {
        // Load refund data if order is cancelled or rejected and not COD
        if ((order.status == 'cancelled' || order.status == 'rejected') &&
            order.paymentMethod != 'COD') {
          final refundResult = await refundRepository.getRefundByOrderId(
            event.orderId,
          );

          refundResult.fold(
            (failure) =>
                emit(OrderLoaded(order)), // Emit without refund on error
            (refund) => emit(OrderLoaded(order, refund: refund)),
          );
        } else {
          emit(OrderLoaded(order));
        }
      },
    );
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await orderRepository.getUserOrders(
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(OrdersError(failure.message, failure: failure)),
      (orders) => emit(
        OrdersLoaded(
          orders: orders,
          totalCount: orders.length,
          currentPage: event.page,
          hasNextPage: orders.length >= event.limit,
        ),
      ),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrderState> emit,
  ) async {
    if (state is! OrderLoaded) {
      return;
    }

    final currentState = state as OrderLoaded;

    emit(OrderLoading());

    final result = await orderRepository.cancelOrder(
      event.orderId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(OrderError(failure.message, failure: failure)),
      (isCancelled) {
        if (isCancelled) {
          final updatedOrder = currentState.order.copyWith(status: 'cancelled');
          emit(OrderCancelled(updatedOrder));
        } else {
          emit(OrderError('Failed to cancel the order'));
        }
      },
    );

    add(LoadOrder(event.orderId));
  }

  Future<void> _onReorderOrder(
    ReorderOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await orderRepository.reorder(
      event.originalOrderId,
      deliveryAddressId: event.deliveryAddressId,
      paymentMethod: event.paymentMethod,
      modifyItems: event.modifyItems,
    );

    result.fold(
      (failure) => emit(OrderError(failure.message, failure: failure)),
      (order) => emit(OrderReordered(order)),
    );
  }

  Future<void> _onTrackOrder(TrackOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    final result = await orderRepository.trackOrder(event.orderId);

    result.fold(
      (failure) => emit(OrderError(failure.message, failure: failure)),
      (trackingData) => emit(OrderTrackingLoaded(trackingData)),
    );
  }
}
