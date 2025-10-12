import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/orders/domain/entities/order_entity.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_bloc.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_event.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_state.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load the specific order
    context.read<OrderBloc>().add(LoadOrder(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text('Order Details'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderError) {
            return _buildErrorView(context, state.message);
          }

          if (state is OrderLoaded) {
            return _buildOrderDetails(context, state.order);
          }

          // Try to find order from OrdersLoaded state
          if (state is OrdersLoaded) {
            try {
              final order = state.orders.firstWhere(
                (o) => o.id == widget.orderId,
              );
              return _buildOrderDetails(context, order);
            } catch (e) {
              // Order not found in the list
              return _buildErrorView(
                context,
                'Order not found. Please try refreshing the orders list.',
              );
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
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
              'Failed to load order',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<OrderBloc>().add(LoadOrder(widget.orderId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(context, order),
          _buildOrderStatus(context, order),
          _buildOrderItems(context, order),
          _buildDeliveryAddress(context, order),
          _buildPriceBreakdown(context, order),
          _buildPaymentInfo(context, order),
          if (order.specialInstructions != null)
            _buildSpecialInstructions(context, order),
          if (order.status != 'delivered' &&
              order.status != 'cancelled' &&
              order.status != 'rejected')
            _buildActionButtons(context, order),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '#${order.id.substring(order.id.length - 8).toUpperCase()}',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: order.id));
                            SnackbarUtils.showSuccess(
                              context,
                              'Order ID copied to clipboard',
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusChip(context, order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMMM yyyy, hh:mm a').format(order.createdAt),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStatusTimeline(context, order),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statuses = _getOrderStatusList(order);

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = status['completed'] as bool;
        final isCurrent = status['current'] as bool;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : status['icon'] as IconData,
                    size: 16,
                    color: isCompleted || isCurrent
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Status info
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status['title'] as String,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: isCurrent || isCompleted
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent || isCompleted
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (status['time'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        status['time'] as String,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (status['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        status['description'] as String,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Map<String, dynamic>> _getOrderStatusList(OrderEntity order) {
    final status = order.status.toLowerCase();
    final statuses = <Map<String, dynamic>>[];

    statuses.add({
      'title': 'Order Placed',
      'icon': Icons.shopping_bag_outlined,
      'completed': true,
      'current': status == 'pending',
      'time': DateFormat('dd MMM, hh:mm a').format(order.createdAt),
      'description': 'Your order has been placed successfully',
    });

    if (status != 'cancelled' && status != 'rejected') {
      statuses.add({
        'title': 'Order Confirmed',
        'icon': Icons.assignment_turned_in_outlined,
        'completed': [
          'accepted',
          'processing',
          'shipped',
          'delivered',
        ].contains(status),
        'current': status == 'accepted',
        'time': order.acceptedAt != null
            ? DateFormat('dd MMM, hh:mm a').format(order.acceptedAt!)
            : null,
        'description': order.acceptedAt != null
            ? 'Order confirmed and being prepared'
            : 'Waiting for confirmation',
      });

      statuses.add({
        'title': 'Processing',
        'icon': Icons.autorenew,
        'completed': ['processing', 'shipped', 'delivered'].contains(status),
        'current': status == 'processing',
        'time': null,
        'description': 'Your order is being prepared',
      });

      statuses.add({
        'title': 'Shipped',
        'icon': Icons.local_shipping_outlined,
        'completed': ['shipped', 'delivered'].contains(status),
        'current': status == 'shipped',
        'time': null,
        'description': 'Your order is on the way',
      });

      statuses.add({
        'title': 'Delivered',
        'icon': Icons.check_circle_outline,
        'completed': status == 'delivered',
        'current': status == 'delivered',
        'time': null,
        'description': 'Order delivered successfully',
      });
    } else {
      statuses.add({
        'title': status == 'cancelled' ? 'Order Cancelled' : 'Order Rejected',
        'icon': Icons.cancel_outlined,
        'completed': true,
        'current': true,
        'time': order.rejectedAt != null
            ? DateFormat('dd MMM, hh:mm a').format(order.rejectedAt!)
            : null,
        'description': order.rejectionReason ?? 'Order was $status',
      });
    }

    return statuses;
  }

  Widget _buildOrderItems(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items.length})',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),

                    child: Icon(
                      item.itemType == 'Blend'
                          ? Icons.blender
                          : Icons.inventory_2_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${item.quantity.toStringAsFixed(0)} Unit(s)',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.weightInKg}Kg × ₹${item.pricePerKg.toStringAsFixed(2)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(2)}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final address = order.deliveryAddress;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            address.recipientName,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '${address.addressLine1}, ${address.addressLine2 ?? ''}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.city}, ${address.state} - ${address.postalCode}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (order.contactNumbers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  order.contactNumbers.first,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(context, 'Subtotal', order.subtotal),
          if (order.couponApplied != null &&
              order.couponApplied!.discountValue > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              'Discount (${order.couponCode ?? 'Applied'})',
              -order.discountAmount,
              isDiscount: true,
            ),
          ],
          if (order.loyaltyDiscountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              'Atta Points (${order.loyaltyPointsUsed} points)',
              -order.loyaltyDiscountAmount,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 12),
          _buildPriceRow(context, 'Delivery Charges', order.deliveryCharges),
          if (order.codCharges > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(context, 'COD Charges', order.codCharges),
          ],
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '${amount < 0 ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(
            color: isDiscount ? Colors.green : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Information',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            'Payment Method',
            order.paymentMethod.toUpperCase(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'Payment Status',
            _getPaymentStatusText(order.paymentStatus),
            valueColor: _getPaymentStatusColor(order.paymentStatus),
          ),
          if (order.razorpayPaymentId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Transaction ID', order.razorpayPaymentId!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions(BuildContext context, OrderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Special Instructions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.specialInstructions!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderEntity order) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          if (order.status == 'pending' || order.status == 'accepted') ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showCancelDialog(context, order),
                label: const Text('Cancel Order'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          // if (order.status == 'shipped') ...[
          //   SizedBox(
          //     width: double.infinity,
          //     child: FilledButton.icon(
          //       onPressed: () {
          //         // TODO: Implement track order functionality
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Tracking feature coming soon!'),
          //           ),
          //         );
          //       },
          //       icon: const Icon(Icons.location_on_outlined),
          //       label: const Text('Track Order'),
          //       style: FilledButton.styleFrom(
          //         backgroundColor: colorScheme.primary,
          //         foregroundColor: colorScheme.onPrimary,
          //         padding: const EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderBloc>().add(CancelOrder(orderId: order.id));
              SnackbarUtils.showSuccess(
                context,
                'Order cancelled successfully',
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'delivered':
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case 'shipped':
        backgroundColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue.shade700;
        icon = Icons.local_shipping_outlined;
        break;
      case 'processing':
        backgroundColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange.shade700;
        icon = Icons.autorenew;
        break;
      case 'accepted':
        backgroundColor = Colors.purple.withValues(alpha: 0.15);
        textColor = Colors.purple.shade700;
        icon = Icons.assignment_turned_in_outlined;
        break;
      case 'pending':
        backgroundColor = Colors.amber.withValues(alpha: 0.15);
        textColor = Colors.amber.shade700;
        icon = Icons.schedule;
        break;
      case 'cancelled':
      case 'rejected':
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'shipped':
        return 'Shipped';
      case 'processing':
        return 'Processing';
      case 'accepted':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
        return Colors.red.shade700;
      case 'refunded':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
