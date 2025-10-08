import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';
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
  String? _selectedPaymentType; // 'COD' or 'Razorpay'

  @override
  void initState() {
    super.initState();
    // No need to load payment methods from API
  }

  void _onPaymentMethodSelected(String paymentType) {
    setState(() {
      _selectedPaymentType = paymentType;
    });
  }

  void _proceedToPayment() {
    if (_selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      if (_selectedPaymentType == 'COD' && deliveryState.codAvailable) {
        codCharges = deliveryState.codCharges;
      }
    }

    // Extract items from orderData
    final items = (orderData['items'] as List)
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final deliveryAddress = orderData['delivery_address'] as String;
    final contactNumbers = (orderData['contact_numbers'] as List)
        .map((e) => e.toString())
        .toList();
    final couponCode = orderData['coupon_code'] as String?;

    // Create order via API
    // _selectedPaymentType is either 'COD' or 'Razorpay'
    context.read<PaymentBloc>().add(
      CreateOrder(
        items: items,
        deliveryAddress: deliveryAddress,
        contactNumbers: contactNumbers,
        paymentMethod: _selectedPaymentType!, // 'COD' or 'Razorpay'
        couponCode: couponCode,
        loyaltyPointsUsed: null, // Can be added later
        deliveryCharges: deliveryCharges,
        codCharges: codCharges,
      ),
    );
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
              extra: {'orderId': order.id, 'order': order.toJson()},
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

                      // COD Option
                      _buildSimplePaymentMethodTile(
                        type: 'COD',
                        name: 'Cash on Delivery',
                        description: 'Pay with cash when your order arrives',
                        icon: Icons.money,
                        iconColor: Colors.green,
                        isSelected: _selectedPaymentType == 'COD',
                      ),

                      const SizedBox(height: 12),

                      // Prepaid Option (Razorpay)
                      _buildSimplePaymentMethodTile(
                        type: 'Razorpay',
                        name: 'Prepaid',
                        description: 'Pay online via UPI, Card or Wallet',
                        icon: Icons.account_balance_wallet,
                        iconColor: Colors.purple,
                        isSelected: _selectedPaymentType == 'Razorpay',
                      ),

                      // Order Summary
                      const SizedBox(height: 24),
                      _buildOrderSummary(),
                    ],
                  ),
                ),
              ),

              // Continue Button
              _buildContinueButton(),
            ],
          );
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

  Widget _buildOrderSummary() {
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
          if (_selectedPaymentType == 'COD' && deliveryState.codAvailable) {
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

  Widget _buildContinueButton() {
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
            onPressed: _selectedPaymentType != null ? _proceedToPayment : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              _selectedPaymentType == 'COD'
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

  Widget _buildSimplePaymentMethodTile({
    required String type,
    required String name,
    required String description,
    required IconData icon,
    required Color iconColor,
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
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => _onPaymentMethodSelected(type),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Radio<String>(
          value: type,
          groupValue: isSelected ? type : null,
          onChanged: (_) => _onPaymentMethodSelected(type),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
