import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_bloc.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_event.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_state.dart';
import 'package:one_atta/features/orders/presentation/widgets/order_card.dart';

class OrdersList extends StatelessWidget {
  final String? filterStatus;

  const OrdersList({super.key, this.filterStatus});

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    if (filterStatus == null) {
      return orders;
    }

    if (filterStatus == 'active') {
      return orders
          .where(
            (order) =>
                order.status == 'pending' ||
                order.status == 'accepted' ||
                order.status == 'processing' ||
                order.status == 'shipped',
          )
          .toList();
    }

    if (filterStatus == 'delivered') {
      return orders.where((order) => order.status == 'delivered').toList();
    }

    if (filterStatus == 'cancelled') {
      return orders
          .where(
            (order) =>
                order.status == 'cancelled' || order.status == 'rejected',
          )
          .toList();
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) {
        return current is OrdersLoading ||
            current is OrdersLoaded ||
            current is OrderError;
      },
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load orders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OrderBloc>().add(LoadUserOrders());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OrdersLoaded) {
          final filteredOrders = _filterOrders(state.orders);

          if (filteredOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getEmptyMessage(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getEmptySubMessage(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<OrderBloc>().add(LoadUserOrders());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderCard(
                  order: order, // TODO: Get actual total count from API
                  onTap: () {
                    context.push('/order-details/${order.id}');
                  },
                );
              },
            ),
          );
        }

        // Initial state - show loading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _getEmptyMessage() {
    switch (filterStatus) {
      case 'active':
        return 'No active orders';
      case 'delivered':
        return 'No completed orders';
      case 'cancelled':
        return 'No cancelled orders';
      default:
        return 'No orders yet';
    }
  }

  String _getEmptySubMessage() {
    switch (filterStatus) {
      case 'active':
        return 'Your active orders will appear here';
      case 'delivered':
        return 'Your completed orders will appear here';
      case 'cancelled':
        return 'Your cancelled orders will appear here';
      default:
        return 'Start shopping to see your orders';
    }
  }
}
