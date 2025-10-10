import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';
import 'package:one_atta/features/payment/domain/entities/order_data.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_state.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final OrderData? orderData;

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
    double codCharges = 0.0;
    if (deliveryState is DeliveryLoaded) {
      if (_selectedPaymentType == 'COD' && deliveryState.codAvailable) {
        codCharges = deliveryState.codCharges;
      }
    }

    // Extract items from orderData
    final items = orderData.items;
    final deliveryAddress = orderData.address.id;
    final contactNumbers = [
      orderData.address.primaryPhone,
      if (orderData.address.secondaryPhone != null)
        orderData.address.secondaryPhone!,
    ];
    final couponCode = orderData.couponCode;

    // Create order via API
    // _selectedPaymentType is either 'COD' or 'Razorpay'
    context.read<PaymentBloc>().add(
      CreateOrder(
        items: items,
        deliveryAddress: deliveryAddress,
        contactNumbers: contactNumbers,
        paymentMethod: _selectedPaymentType!, // 'COD' or 'Razorpay'
        couponCode: couponCode,
        loyaltyPointsUsed: orderData.loyaltyPointsUsed, // Can be added later
        deliveryCharges: orderData.deliveryCharges,
        codCharges: codCharges,
        subtotal: orderData.itemTotal,
        discountAmount:
            orderData.couponDiscount + orderData.loyaltyDiscountAmount,
        totalAmount: orderData.totalAmount + codCharges,
        isDiscountAvailed:
            (orderData.couponDiscount + orderData.loyaltyDiscountAmount) > 0,
        discountType: orderData.loyaltyPointsUsed > 0
            ? 'loyalty'
            : (couponCode != null && couponCode.isNotEmpty)
            ? 'coupon'
            : null,
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
              _buildContinueButton(isLoading: state is PaymentLoading),
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
    final addressData = orderData.address;

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
                'Deliver to ${addressData.recipientName}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addressData.fullAddress,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          ...[
            const SizedBox(height: 4),
            Text(
              'Contact No. ${addressData.primaryPhone}',
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
    final items = orderData.items;
    final subtotal = orderData.itemTotal;
    final couponDiscount = orderData.couponDiscount;
    final loyaltyDiscount = orderData.loyaltyDiscountAmount;
    final totalDiscount = couponDiscount + loyaltyDiscount;

    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, deliveryState) {
        double deliveryCharges = 0.0;
        double codCharges = 0.0;

        if (deliveryState is DeliveryLoaded) {
          deliveryCharges = orderData.deliveryCharges;
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

  Widget _buildContinueButton({bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _selectedPaymentType != null && !isLoading
                ? _proceedToPayment
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
            color: iconColor.withValues(alpha:  0.1),
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
