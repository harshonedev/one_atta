import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:one_atta/features/cart/presentation/widgets/empty_cart_widget.dart';
import 'package:one_atta/features/cart/presentation/widgets/cart_summary_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded) {
            if (state.cart.isEmpty) {
              return const EmptyCartWidget();
            }

            return Column(
              children: [
                _buildDeliveryEstimate(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.cart.items.length,
                        itemBuilder: (context, index) {
                          final item = state.cart.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CartItemWidget(
                              item: item,
                              onQuantityChanged: (quantity) {
                                context.read<CartBloc>().add(
                                  UpdateItemQuantity(
                                    productId: item.productId,
                                    quantity: quantity,
                                  ),
                                );
                              },
                              onRemove: () {
                                context.read<CartBloc>().add(
                                  RemoveItemFromCart(productId: item.productId),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      _buildOrderInfo(context),
                    ],
                  ),
                ),
                CartSummaryWidget(cart: state.cart),

                // Basic
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem(context, Icons.lock, 'Secure Payment'),
                    _buildInfoItem(context, Icons.sync, 'Free Returns'),
                    _buildInfoItem(
                      context,
                      Icons.info_outline,
                      'COD\nAvailable',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          return const EmptyCartWidget();
        },
      ),
    );
  }

  Widget _buildDeliveryEstimate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_rounded, size: 20),
          const SizedBox(width: 8),
          Text(
            'Get it by Tuesday, 14 Sept',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'This order will earn you 90 Atta Points',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
