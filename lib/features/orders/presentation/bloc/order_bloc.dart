import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/orders/domain/repositories/order_repository.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_event.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<LoadOrder>(_onLoadOrder);
    on<LoadUserOrders>(_onLoadUserOrders);
    on<CancelOrder>(_onCancelOrder);
    on<ReorderOrder>(_onReorderOrder);
    on<TrackOrder>(_onTrackOrder);
  }

  Future<void> _onLoadOrder(LoadOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    final result = await orderRepository.getOrderById(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderLoaded(order)),
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
      (failure) => emit(OrderError(failure.message)),
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
    emit(OrderLoading());

    final result = await orderRepository.cancelOrder(
      event.orderId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCancelled(order)),
    );
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
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderReordered(order)),
    );
  }

  Future<void> _onTrackOrder(TrackOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    final result = await orderRepository.trackOrder(event.orderId);

    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (trackingData) => emit(OrderTrackingLoaded(trackingData)),
    );
  }
}
