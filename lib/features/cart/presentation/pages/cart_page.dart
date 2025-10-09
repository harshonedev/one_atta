import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_state.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';
import 'package:one_atta/features/cart/presentation/widgets/cart_address_selection_widget.dart';
import 'package:one_atta/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:one_atta/features/cart/presentation/widgets/empty_cart_widget.dart';
import 'package:one_atta/features/cart/presentation/widgets/estimated_delivery_widget.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';
import 'package:one_atta/features/coupons/presentation/widgets/coupon_input_widget.dart';
import 'package:one_atta/features/coupons/presentation/widgets/enhanced_cart_summary_widget.dart';
import 'package:one_atta/features/coupons/presentation/widgets/loyalty_points_redemption_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isProcessingOrder = false;
  bool _addressNotDeliverable = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<CartBloc>().add(LoadCart());

    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressesLoaded && addressState.addresses.isNotEmpty) {
      final defaultAddress = addressState.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addressState.addresses.first,
      );
      // Select the default address in cart state
      context.read<CartBloc>().add(SelectAddress(address: defaultAddress));
      // Check delivery availability for the selected address
      _onCheckDeliveryAvailability(defaultAddress.postalCode);
    }
  }

  void _onAddressSelected(AddressEntity? address) {
    if (address != null) {
      context.read<CartBloc>().add(SelectAddress(address: address));
      _onCheckDeliveryAvailability(address.postalCode);
    } else {
      context.read<CartBloc>().add(ClearSelectedAddress());
    }
  }

  void _onCheckDeliveryAvailability(String pincode) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      context.read<DeliveryBloc>().add(
        CheckDeliveryAvailability(
          pincode: pincode,
          orderValue:
              cartState.itemTotal, // Use itemTotal for delivery calculation
          isExpress: false, // Ignoring express delivery for now
        ),
      );
    }
  }

  void _onCouponApplied(CouponEntity? coupon, double discount) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;

    // Don't allow coupon if loyalty points are applied
    if (coupon != null && cartState.loyaltyPointsRedeemed > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remove Atta Points to apply coupon'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (coupon != null) {
      context.read<CartBloc>().add(
        ApplyCoupon(
          couponCode: coupon.code,
          discountAmount: discount,
          coupon: coupon,
        ),
      );
    } else {
      context.read<CartBloc>().add(RemoveCoupon());
    }

    // Recalculate delivery with updated cart total
    if (cartState.selectedAddress != null) {
      _onCheckDeliveryAvailability(cartState.selectedAddress!.postalCode);
    }
  }

  void _onLoyaltyPointsRedeemed(int points, double discountAmount) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;

    // Don't allow loyalty points if coupon is applied
    if (points > 0 && cartState.appliedCoupon != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remove coupon to use Atta Points'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Apply loyalty discount to cart
    if (points > 0) {
      context.read<CartBloc>().add(
        ApplyLoyaltyPoints(points: points, discountAmount: discountAmount),
      );
    } else {
      context.read<CartBloc>().add(RemoveLoyaltyPoints());
    }

    // Recalculate delivery with updated cart total (after loyalty discount)
    if (cartState.selectedAddress != null) {
      // Use amount after loyalty discount for delivery calculation
      final amountForDelivery = cartState.itemTotal - discountAmount;
      context.read<DeliveryBloc>().add(
        CheckDeliveryAvailability(
          pincode: cartState.selectedAddress!.postalCode,
          orderValue: amountForDelivery,
          isExpress: false,
        ),
      );
    }
  }

  void _proceedToCheckout() {
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;

    if (_addressNotDeliverable) return;

    if (cartState.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    // Create order first
    final authState = context.read<AuthBloc>().state;
    final email = (authState is AuthAuthenticated) ? authState.user.email : '';
    final selectedAddress = cartState.selectedAddress!;

    // Navigate to payment method selection with order data
    final orderData = {
      'items': cartState.cart.items
          .map(
            (item) => {
              'item_type': item.productType.toLowerCase() == 'product'
                  ? 'Product'
                  : 'Blend',
              'item': item.productId,
              'quantity': item.quantity,
              'weight_in_kg': item.weightInKg,
            },
          )
          .toList(),
      'delivery_address': selectedAddress.id,
      'contact_numbers': [selectedAddress.primaryPhone],
      'subtotal': cartState.itemTotal,
      'coupon_code': cartState.appliedCoupon?.code,
      'coupon_discount': cartState.couponDiscount,
      'loyalty_discount': cartState.loyaltyDiscount,
      'delivery_fee': cartState.deliveryFee,
      'total_amount': cartState.toPayTotal,
      'phone': selectedAddress.primaryPhone,
      'email': email,
      'address_details': {
        'recipient_name': selectedAddress.recipientName,
        'full_address': selectedAddress.fullAddress,
        'primary_phone': selectedAddress.primaryPhone,
        'city': selectedAddress.city,
        'state': selectedAddress.state,
        'postal_code': selectedAddress.postalCode,
      },
    };

    setState(() {
      _isProcessingOrder = false;
    });

    // Navigate to payment method selection
    context.push(
      '/payment/methods',
      extra: {'orderData': orderData, 'amount': cartState.toPayTotal},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DeliveryBloc, DeliveryState>(
            listener: (context, deliveryState) {
              // Update cart bloc when delivery charges change
              if (deliveryState is DeliveryLoaded) {
                context.read<CartBloc>().add(
                  UpdateDeliveryCharges(
                    deliveryCharges: deliveryState.deliveryCharges,
                  ),
                );
              } else if (deliveryState is DeliveryNotAvailable ||
                  deliveryState is DeliveryError) {
                // Set delivery charges to 0 if delivery not available or error
                setState(() {
                  _addressNotDeliverable = true;
                });

                // show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      deliveryState is DeliveryNotAvailable
                          ? 'Delivery not available to the selected address'
                          : 'Error checking delivery availability',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                context.read<CartBloc>().add(
                  const UpdateDeliveryCharges(deliveryCharges: 0.0),
                );
              }
            },
          ),
          BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartLoaded) {
                // check orderamout with delivery threshold
                final deliverState = context.read<DeliveryBloc>().state;
                if (deliverState is DeliveryLoaded) {
                  final itemTotal = state.discountType == DiscountType.loyalty
                      ? state.itemTotal - state.loyaltyDiscount
                      : state.itemTotal;
                  final threshold = deliverState.freeDeliveryThreshold;
                  final isFree =
                      deliverState.isFreeDelivery || itemTotal >= threshold;

                  if (isFree && deliverState.deliveryCharges != 0.0) {
                    // Update delivery charges to 0 in cart
                    context.read<CartBloc>().add(
                      const UpdateDeliveryCharges(deliveryCharges: 0.0),
                    );
                  } else {
                    context.read<CartBloc>().add(
                      UpdateDeliveryCharges(
                        deliveryCharges: deliverState.deliveryCharges,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cartState is CartError) {
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
                      'Failed to load cart',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cartState.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(LoadCart());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (cartState is CartLoaded) {
              if (cartState.cart.items.isEmpty) {
                return EmptyCartWidget();
              }
              return _buildCartContent(cartState.cart.items);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCartContent(List<CartItemEntity> cartItems) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ETA Section
                EstimatedDeliveryWidget(),

                // Cart Items Section
                _buildCartItemsSection(cartItems),

                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),

                // Delivery Fee Info
                _buildDeliveryFeeInfo(),

                // Loyalty Points Section (Atta Points)
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    double orderAmount = 0.0;
                    bool isDisabled = false;

                    if (state is CartLoaded) {
                      orderAmount = state.itemTotal;
                      isDisabled = state.appliedCoupon != null;
                    } else {
                      orderAmount = cartItems.fold(
                        0.0,
                        (total, item) => total + (item.price * item.quantity),
                      );
                    }

                    return LoyaltyPointsRedemptionWidget(
                      orderAmount: orderAmount,
                      onPointsRedeemed: _onLoyaltyPointsRedeemed,
                      isDisabled: isDisabled,
                    );
                  },
                ),

                // Show message if loyalty points are applied
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoaded &&
                        state.loyaltyPointsRedeemed > 0) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Atta Points applied. You cannot use a coupon.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Coupon Section
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    double orderAmount = 0.0;
                    bool isDisabled = false;

                    if (state is CartLoaded) {
                      orderAmount = state.itemTotal;
                      isDisabled = state.loyaltyPointsRedeemed > 0;
                    } else {
                      orderAmount = cartItems.fold(
                        0.0,
                        (total, item) => total + (item.price * item.quantity),
                      );
                    }

                    return CouponInputWidget(
                      orderAmount: orderAmount,
                      items: cartItems
                          .map(
                            (item) => CouponItem(
                              itemId: item.productId,
                              itemType: item.productType,
                              quantity: item.quantity,
                              pricePerKg: item.price,
                              totalPrice: item.totalPrice,
                            ),
                          )
                          .toList(),
                      onCouponApplied: _onCouponApplied,
                      isDisabled: isDisabled,
                    );
                  },
                ),

                // Show message if coupon is applied
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoaded && state.appliedCoupon != null) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Coupon applied. You cannot use Atta Points.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),

                // Cart Summary
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoaded) {
                      return EnhancedCartSummaryWidget(
                        cartItems: cartItems,
                        appliedCoupon: state.appliedCoupon,
                        loyaltyPointsRedeemed: state.loyaltyPointsRedeemed,
                        mrpTotal: state.mrpTotal,
                        itemTotal: state.itemTotal,
                        deliveryFee: state.deliveryFee,
                        couponDiscount: state.couponDiscount,
                        loyaltyDiscount: state.loyaltyDiscount,
                        savingsTotal: state.savingsTotal,
                        toPayTotal: state.toPayTotal,
                      );
                    } else {
                      // Fallback to using the EnhancedCartSummaryWidget's own calculations
                      return EnhancedCartSummaryWidget(
                        cartItems: cartItems,
                        appliedCoupon: null,
                        loyaltyPointsRedeemed: 0,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // Checkout Button
        _buildCheckoutButton(cartItems),
      ],
    );
  }

  Widget _buildCartItemsSection(List<CartItemEntity> cartItems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Items (${cartItems.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return CartItemCard(item: cartItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryFeeInfo() {
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      buildWhen: (previous, current) => current is DeliveryLoaded,
      builder: (context, deliveryState) {
        if (deliveryState is! DeliveryLoaded) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<CartBloc, CartState>(
          buildWhen: (previous, current) => current is CartLoaded,
          builder: (context, cartState) {
            if (cartState is! CartLoaded) {
              return const SizedBox.shrink();
            }
            final itemTotal = cartState.discountType == DiscountType.loyalty
                ? cartState.itemTotal - cartState.loyaltyDiscount
                : cartState.itemTotal;
            final threshold = deliveryState.freeDeliveryThreshold;
            final isFree =
                deliveryState.isFreeDelivery || itemTotal >= threshold;
            final deliveryFee = deliveryState.deliveryCharges;

            // If already free delivery
            if (isFree) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Yay! You got FREE delivery',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // If close to free delivery
            if (threshold > 0 && itemTotal < threshold) {
              final amountNeeded = threshold - itemTotal;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.orange.shade700),
                          children: [
                            const TextSpan(text: 'Add items worth '),
                            TextSpan(
                              text: '₹${amountNeeded.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' more for FREE delivery'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show current delivery fee
            if (deliveryFee > 0) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delivery fee: ₹${deliveryFee.toInt()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildCheckoutButton(List<CartItemEntity> cartItems) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        double total = 0.0;

        if (state is CartLoaded) {
          total = state.toPayTotal;
        }

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Address Selection
                CartAddressSelectionWidget(
                  onAddressSelected: _onAddressSelected,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isProcessingOrder || _addressNotDeliverable
                        ? null
                        : _proceedToCheckout,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _isProcessingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pay ₹${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
