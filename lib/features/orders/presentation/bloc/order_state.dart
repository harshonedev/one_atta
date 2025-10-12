import 'package:equatable/equatable.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoading extends OrderState {}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object> get props => [order];
}

class OrderLoaded extends OrderState {
  final OrderEntity order;

  const OrderLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;

  const OrdersLoaded({
    required this.orders,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
  });

  @override
  List<Object> get props => [orders, totalCount, currentPage, hasNextPage];
}

class OrderCancelled extends OrderState {
  final OrderEntity order;

  const OrderCancelled(this.order);

  @override
  List<Object> get props => [order];
}

class OrderReordered extends OrderState {
  final OrderEntity newOrder;

  const OrderReordered(this.newOrder);

  @override
  List<Object> get props => [newOrder];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderTrackingLoaded extends OrderState {
  final Map<String, dynamic> trackingData;

  const OrderTrackingLoaded(this.trackingData);

  @override
  List<Object> get props => [trackingData];
}
