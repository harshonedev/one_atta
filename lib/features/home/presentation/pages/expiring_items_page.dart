import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/home/domain/entities/expiring_item_entity.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_event.dart';
import 'package:one_atta/features/home/presentation/bloc/home_state.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/features/home/presentation/bloc/item_cubit.dart';

class ExpiringItemsPage extends StatefulWidget {
  const ExpiringItemsPage({super.key});

  @override
  State<ExpiringItemsPage> createState() => _ExpiringItemsPageState();
}

class _ExpiringItemsPageState extends State<ExpiringItemsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ItemCubit>(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Expiring Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocListener<ItemCubit, ItemState>(
          listener: (context, state) {
            if (state is ItemLoaded) {
              _reorderItem(context, state.item);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              List<ExpiringItemEntity> expiringItems = [];

              if (state is HomeLoaded) {
                expiringItems = state.expiringItems;
              } else if (state is HomeError) {
                expiringItems = state.expiringItems;
              } else if (state is HomePartialLoading) {
                expiringItems = state.expiringItems;
              }

              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeError && expiringItems.isEmpty) {
                return ErrorPage(
                  message: state.message,
                  failure: state.failure,
                  onRetry: () {
                    // Reload home data to refresh expiring items
                    context.read<HomeBloc>().add(const LoadHomeData());
                  },
                );
              }

              return Column(
                children: [
                  // Items list
                  Expanded(
                    child: expiringItems.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: expiringItems.length,
                            itemBuilder: (context, index) {
                              return _buildExpiringItemCard(
                                context,
                                expiringItems[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringItemCard(BuildContext context, ExpiringItemEntity item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color urgencyColor = _getUrgencyColor(item.urgency);
    final IconData urgencyIcon = _getUrgencyIcon(item.urgency);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with urgency indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(urgencyIcon, color: urgencyColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.itemType,
                              style: textTheme.bodySmall?.copyWith(
                                color: urgencyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.daysUntilExpiry} days',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Details row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        icon: Icons.shopping_bag_outlined,
                        label: 'Quantity',
                        value: '${item.quantity} x ${item.weightInKg} kg',
                      ),
                    ),

                    Expanded(
                      child: _buildDetailItem(
                        context,
                        icon: Icons.event_outlined,
                        label: 'Expires on',
                        value: DateFormat(
                          'dd MMM yyyy',
                        ).format(item.expiryDate),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Freshness',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(item.getProgressValue() * 100).toInt()}%',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: urgencyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.getProgressValue(),
                        backgroundColor: urgencyColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/order-details/${item.orderId}');
                        },
                        icon: const Icon(Icons.receipt_long_outlined, size: 18),
                        label: const Text('View Order'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          // Check if item is already in cart
                          final bool isInCart =
                              cartState is CartLoaded &&
                              cartState.cart.containsProduct(item.orderItemId);

                          return BlocBuilder<ItemCubit, ItemState>(
                            builder: (context, itemState) {
                              final bool isLoading = itemState is ItemLoading;

                              // If item is in cart, show "Go to Cart" button
                              if (isInCart) {
                                return ElevatedButton.icon(
                                  onPressed: () => context.push('/cart'),
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    size: 18,
                                  ),
                                  label: const Text('Go to Cart'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                );
                              }

                              // Otherwise show "Reorder" button
                              return ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => _fetchItemDetails(context, item),
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 18,
                                      ),
                                label: const Text('Reorder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 8,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _fetchItemDetails(BuildContext context, ExpiringItemEntity item) {
    context.read<ItemCubit>().loadItem(
      item.orderItemId, // The actual product/blend ID
      item.itemType, // 'Product' or 'Blend'
      item.weightInKg,
    );
  }

  void _reorderItem(BuildContext context, CartItemEntity cartItem) {
    // Add the item to cart
    context.read<CartBloc>().add(AddItemToCart(item: cartItem));

    // navigate to cart page
    context.push('/cart');
  }

  Color _getUrgencyColor(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Colors.red;
      case ExpiryUrgency.warning:
        return Colors.orange;
      case ExpiryUrgency.normal:
        return Colors.green;
    }
  }

  IconData _getUrgencyIcon(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Icons.schedule_rounded;
      case ExpiryUrgency.warning:
        return Icons.schedule_rounded;
      case ExpiryUrgency.normal:
        return Icons.info_outline_rounded;
    }
  }
}
