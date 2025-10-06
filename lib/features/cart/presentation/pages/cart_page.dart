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
import 'package:one_atta/features/cart/presentation/widgets/estimated_delivery_widget.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';
import 'package:one_atta/features/coupons/presentation/widgets/coupon_input_widget.dart';
import 'package:one_atta/features/coupons/presentation/widgets/enhanced_cart_summary_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  AddressEntity? _selectedAddress;
  CouponEntity? _appliedCoupon;
  final int _loyaltyPointsToRedeem = 0;
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<CartBloc>().add(LoadCart());

    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressesLoaded && addressState.addresses.isNotEmpty) {
      _selectedAddress = addressState.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addressState.addresses.first,
      );

      // Check delivery availability for the selected address
      _onCheckDeliveryAvailability(_selectedAddress!.postalCode);
    }
  }

  void _onAddressSelected(AddressEntity? address) {
    setState(() {
      _selectedAddress = address;
    });
    if (address != null) {
      _onCheckDeliveryAvailability(address.postalCode);
    }
  }

  void _onCheckDeliveryAvailability(String pincode) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      print('Checking delivery for pincode: $pincode');
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
    setState(() {
      _appliedCoupon = coupon;
    });

    if (coupon != null) {
      context.read<CartBloc>().add(
        ApplyCoupon(couponCode: coupon.code, discountAmount: discount),
      );
    } else {
      context.read<CartBloc>().add(RemoveCoupon());
    }
  }

  void _proceedToCheckout() {
    if (_selectedAddress == null) {
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
    final cartState = context.read<CartBloc>().state;
    final authState = context.read<AuthBloc>().state;
    final email = (authState is AuthAuthenticated) ? authState.user.email : '';
    if (cartState is CartLoaded) {
      // Navigate to payment method selection with order data
      final orderData = {
        'items': cartState.cart.items
            .map(
              (item) => {
                'item_type': item.productType == 'Product'
                    ? 'Product'
                    : 'Blend',
                'item': item.productId,
                'quantity': item.quantity,
              },
            )
            .toList(),
        'delivery_address': _selectedAddress!.id,
        'contact_numbers': [_selectedAddress!.primaryPhone],
        'subtotal': cartState.itemTotal,
        'coupon_code': _appliedCoupon?.code,
        'coupon_discount': cartState.couponDiscount,
        'loyalty_discount': cartState.loyaltyDiscount,
        'delivery_fee': cartState.deliveryFee,
        'total_amount': cartState.toPayTotal,
        'phone': _selectedAddress!.primaryPhone,
        'email': email,
      };

      setState(() {
        _isProcessingOrder = false;
      });

      // Navigate to payment method selection
      context.push(
        '/payment/methods',
        extra: {'orderData': orderData, 'amount': cartState.toPayTotal},
      );
    } else {
      setState(() {
        _isProcessingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to process order. Please try again.'),
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
          'Cart',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocListener<DeliveryBloc, DeliveryState>(
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
            context.read<CartBloc>().add(
              const UpdateDeliveryCharges(deliveryCharges: 0.0),
            );
          }
        },
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
                return _buildEmptyCart();
              }
              return _buildCartContent(cartState.cart.items);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

                // Coupon Section
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    double orderAmount = 0.0;

                    if (state is CartLoaded) {
                      orderAmount = state.itemTotal;
                    } else {
                      orderAmount = cartItems.fold(
                        0.0,
                        (total, item) => total + (item.price * item.quantity),
                      );
                    }

                    return CouponInputWidget(
                      orderAmount: orderAmount,
                      itemIds: cartItems.map((item) => item.productId).toList(),
                      onCouponApplied: _onCouponApplied,
                    );
                  },
                ),

                // // Loyalty Points Section
                // LoyaltyPointsRedemptionWidget(
                //   orderAmount: _calculateCartTotal(cartItems),
                //   onPointsRedeemed: _onLoyaltyPointsRedeemed,
                // ),
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
                        appliedCoupon: _appliedCoupon,
                        loyaltyPointsRedeemed: _loyaltyPointsToRedeem,
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
                        appliedCoupon: _appliedCoupon,
                        loyaltyPointsRedeemed: _loyaltyPointsToRedeem,
                      );
                    }
                  },
                ),

                const SizedBox(height: 100), // Space for checkout button
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
                color: Colors.black.withOpacity(0.1),
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
                    onPressed: _isProcessingOrder ? null : _proceedToCheckout,
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
