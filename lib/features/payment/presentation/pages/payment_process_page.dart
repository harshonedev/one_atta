import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_state.dart';

class PaymentProcessPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final PaymentMethodEntity paymentMethod;
  final Map<String, dynamic>? orderData;

  const PaymentProcessPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.orderData,
  });

  @override
  State<PaymentProcessPage> createState() => _PaymentProcessPageState();
}

class _PaymentProcessPageState extends State<PaymentProcessPage> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _currentPaymentId;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _initiatePayment();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _initiatePayment() {
    setState(() {
      _isProcessing = true;
    });

    // First create payment in backend
    context.read<PaymentBloc>().add(
      InitiatePayment(
        orderId: widget.orderId,
        amount: widget.amount,
        metadata: widget.orderData,
      ),
    );
  }

  void _openRazorpayCheckout(String razorpayOrderId) {
    final options = {
      'key': 'rzp_test_1234567890', // Replace with your Razorpay key
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'One Atta',
      'description': 'Order Payment',
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': widget.orderData?['phone'] ?? '',
        'email': widget.orderData?['email'] ?? '',
      },
      'theme': {
        'color': Theme.of(context).colorScheme.primary.value.toRadixString(16),
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open Razorpay: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_currentPaymentId != null) {
      context.read<PaymentBloc>().add(
        ProcessRazorpayPayment(
          paymentId: _currentPaymentId!,
          razorpayPaymentId: response.paymentId ?? '',
          razorpayOrderId: response.orderId ?? '',
          razorpaySignature: response.signature ?? '',
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_currentPaymentId != null) {
      context.read<PaymentBloc>().add(
        HandlePaymentFailure(
          paymentId: _currentPaymentId!,
          failureReason: response.message ?? 'Payment failed',
        ),
      );
    } else {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Payment failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Payment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isProcessing ? null : () => context.pop(),
        ),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentCreated) {
            setState(() {
              _currentPaymentId = state.payment.id;
            });

            // Open Razorpay checkout with the received order ID
            if (state.payment.razorpayOrderId != null) {
              _openRazorpayCheckout(state.payment.razorpayOrderId!);
            }
          } else if (state is PaymentCompleted) {
            // Navigate to order confirmation
            context.go(
              '/order/confirmation',
              extra: {
                'orderId': widget.orderId,
                'paymentId': state.payment.id,
                'amount': widget.amount,
              },
            );
          } else if (state is PaymentFailed) {
            setState(() {
              _isProcessing = false;
            });

            _showErrorDialog(state.message);
          } else if (state is PaymentError) {
            setState(() {
              _isProcessing = false;
            });

            _showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Payment Method Info
                _buildPaymentMethodInfo(),
                const SizedBox(height: 32),

                // Processing Indicator
                if (_isProcessing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _getProcessingMessage(state),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we process your payment...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Retry Button
                  ElevatedButton.icon(
                    onPressed: _initiatePayment,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Payment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Security Info
                _buildSecurityInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.paymentMethod.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Amount: ₹${widget.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order ID: #${widget.orderId.substring(widget.orderId.length - 8).toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment is secured by Razorpay with 256-bit SSL encryption',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProcessingMessage(PaymentState state) {
    if (state is PaymentLoading) {
      return 'Initializing Payment...';
    } else if (state is PaymentCreated) {
      return 'Opening Payment Gateway...';
    } else if (state is PaymentProcessing) {
      return 'Verifying Payment...';
    }
    return 'Processing Payment...';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to payment method selection
            },
            child: const Text('Change Payment Method'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initiatePayment();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
