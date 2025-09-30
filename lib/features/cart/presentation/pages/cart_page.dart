import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_state.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
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
  int _loyaltyPointsToRedeem = 0;
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
    }
  }

  void _onAddressSelected(AddressEntity? address) {
    setState(() {
      _selectedAddress = address;
    });
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

  void _onLoyaltyPointsRedeemed(int points, double discount) {
    setState(() {
      _loyaltyPointsToRedeem = points;
    });

    if (points > 0) {
      context.read<CartBloc>().add(
        ApplyLoyaltyPoints(points: points, discountAmount: discount),
      );
    } else {
      context.read<CartBloc>().add(RemoveLoyaltyPoints());
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

    // TODO: Implement order placement
    setState(() {
      _isProcessingOrder = true;
    });

    // Simulate order processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessingOrder = false;
        });

        // Navigate to order confirmation page
        context.push('/order/confirmation');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
      body: BlocBuilder<CartBloc, CartState>(
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
