import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_state.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final Map<String, dynamic>? orderData;

  const PaymentMethodSelectionPage({
    super.key,
    required this.orderId,
    required this.amount,
    this.orderData,
  });

  @override
  State<PaymentMethodSelectionPage> createState() =>
      _PaymentMethodSelectionPageState();
}

class _PaymentMethodSelectionPageState
    extends State<PaymentMethodSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadPaymentMethods());
  }

  void _onPaymentMethodSelected(PaymentMethodEntity paymentMethod) {
    context.read<PaymentBloc>().add(SelectPaymentMethod(paymentMethod));
  }

  void _proceedToPayment() {
    final state = context.read<PaymentBloc>().state;
    if (state is PaymentMethodsLoaded && state.selectedPaymentMethod != null) {
      final selectedMethod = state.selectedPaymentMethod!;
      final orderData = widget.orderData;

      if (orderData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order data is missing'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get delivery charges from delivery bloc
      final deliveryState = context.read<DeliveryBloc>().state;
      double deliveryCharges = 0.0;
      double codCharges = 0.0;

      if (deliveryState is DeliveryLoaded) {
        deliveryCharges = deliveryState.deliveryCharges;
        if (selectedMethod.type == 'COD' && deliveryState.codAvailable) {
          codCharges = deliveryState.codCharges;
        }
      }

      // Extract items from orderData
      final items = (orderData['items'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      final deliveryAddress = orderData['delivery_address'] as String;
      final contactNumbers = (orderData['contact_numbers'] as List)
          .map((e) => e.toString())
          .toList();
      final couponCode = orderData['coupon_code'] as String?;

      // Create order via API
      context.read<PaymentBloc>().add(
        CreateOrder(
          items: items,
          deliveryAddress: deliveryAddress,
          contactNumbers: contactNumbers,
          paymentMethod: selectedMethod.type,
          couponCode: couponCode,
          loyaltyPointsUsed: null, // Can be added later
          deliveryCharges: deliveryCharges,
          codCharges: codCharges,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            // Order created successfully
            final order = state.order;
            final razorpay = state.razorpay;

            if (razorpay != null) {
              // For online payments, navigate to Razorpay payment page
              context.push(
                '/payment/process',
                extra: {'order': order, 'razorpay': razorpay},
              );
            } else {
              // For COD, confirm the order
              context.read<PaymentBloc>().add(
                ConfirmCODOrder(orderId: order.id),
              );
            }
          } else if (state is PaymentCompleted) {
            // Payment completed successfully
            final order = state.order;

            // Navigate to order confirmation
            context.go(
              '/order/confirmation',
              extra: {'orderId': order.id, 'order': order},
            );
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PaymentFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError) {
            return Center(
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
                    'Failed to load payment methods',
                    style: Theme.of(context).textTheme.titleMedium,
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
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(LoadPaymentMethods());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentMethodsLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Address
                        _buildDeliveryAddress(),
                        const SizedBox(height: 16),

                        // Payment Methods
                        Text(
                          'Select Payment Method',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        ...state.paymentMethods.map(
                          (method) => _buildPaymentMethodTile(
                            method: method,
                            isSelected:
                                state.selectedPaymentMethod?.id == method.id,
                          ),
                        ),

                        // Order Summary
                        const SizedBox(height: 24),
                        _buildOrderSummary(state.selectedPaymentMethod),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                _buildContinueButton(state.selectedPaymentMethod),
              ],
            );
          }

          return const Center(child: Text('Select a payment method'));
        },
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    final orderData = widget.orderData;
    if (orderData == null) return const SizedBox.shrink();

    // Extract address details from orderData if available
    final addressData = orderData['address_details'] as Map<String, dynamic>?;
    if (addressData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Deliver to ${addressData['recipient_name']}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addressData['full_address'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (addressData['primary_phone'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Contact No. ${addressData['primary_phone']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PaymentMethodEntity? selectedPaymentMethod) {
    final orderData = widget.orderData;
    if (orderData == null) return const SizedBox.shrink();

    // Extract order details
    final items = orderData['items'] as List? ?? [];
    final subtotal = (orderData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final couponDiscount =
        (orderData['coupon_discount'] as num?)?.toDouble() ?? 0.0;
    final loyaltyDiscount =
        (orderData['loyalty_discount'] as num?)?.toDouble() ?? 0.0;
    final totalDiscount = couponDiscount + loyaltyDiscount;

    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, deliveryState) {
        double deliveryCharges = 0.0;
        double codCharges = 0.0;

        if (deliveryState is DeliveryLoaded) {
          deliveryCharges = deliveryState.deliveryCharges;
          // Add COD charges only if COD payment method is selected
          if (selectedPaymentMethod?.type == 'COD' &&
              deliveryState.codAvailable) {
            codCharges = deliveryState.codCharges;
          }
        }

        final totalAmount =
            subtotal - totalDiscount + deliveryCharges + codCharges;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Total Items
              _buildSummaryRow(
                'Total Items (${items.length})',
                '₹${subtotal.toStringAsFixed(2)}',
                isRegular: true,
              ),

              // Discount if applicable
              if (totalDiscount > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Discount',
                  '- ₹${totalDiscount.toStringAsFixed(2)}',
                  isRegular: true,
                  valueColor: Colors.green,
                ),
              ],

              // Delivery Charges
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Delivery Charges',
                deliveryCharges > 0
                    ? '₹${deliveryCharges.toStringAsFixed(2)}'
                    : 'FREE',
                isRegular: true,
                valueColor: deliveryCharges == 0 ? Colors.green : null,
              ),

              // COD Charges (only if COD is selected)
              if (codCharges > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'COD Charges',
                  '₹${codCharges.toStringAsFixed(2)}',
                  isRegular: true,
                ),
              ],

              const Divider(height: 24),

              // Amount to Pay
              _buildSummaryRow(
                'Amount to Pay',
                '₹${totalAmount.toStringAsFixed(2)}',
                isRegular: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    required bool isRegular,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isRegular
              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: isRegular
              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                )
              : Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethodEntity method,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: method.isEnabled ? () => _onPaymentMethodSelected(method) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildPaymentMethodIcon(method.type),
        title: Text(
          method.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: method.isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: method.description != null
            ? Text(
                method.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Radio<String>(
          value: method.id,
          groupValue: isSelected ? method.id : null,
          onChanged: method.isEnabled
              ? (_) => _onPaymentMethodSelected(method)
              : null,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        enabled: method.isEnabled,
      ),
    );
  }

  Widget _buildPaymentMethodIcon(String type) {
    IconData iconData;
    Color? iconColor;

    switch (type.toLowerCase()) {
      case 'cod':
        iconData = Icons.money;
        iconColor = Colors.green;
        break;
      case 'upi':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.purple;
        break;
      case 'card':
        iconData = Icons.credit_card;
        iconColor = Colors.blue;
        break;
      case 'wallet':
        iconData = Icons.wallet;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildContinueButton(PaymentMethodEntity? selectedMethod) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: selectedMethod != null ? _proceedToPayment : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              selectedMethod?.type == 'COD'
                  ? 'Place Order'
                  : 'Continue to Payment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
