import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';

class AddToCartButton extends StatelessWidget {
  final String productId;
  final String productName;
  final String productType; // 'recipe' or 'blend'
  final double price;
  final String? imageUrl;
  final double pricePerKg;
  final int quantity;
  final int weightInKg;
  final VoidCallback? onPressed;

  const AddToCartButton({
    super.key,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.price,
    required this.pricePerKg,
    required this.weightInKg,
    this.imageUrl,
    this.quantity = 1,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final cartItem = CartItemEntity(
            productId: productId,
            productName: productName,
            productType: productType,
            quantity: quantity,
            price: price,
            mrp: price,
            imageUrl: imageUrl,
            pricePerKg: pricePerKg,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            weightInKg: weightInKg,
          );

          context.read<CartBloc>().add(AddItemToCart(item: cartItem));

          if (onPressed != null) {
            onPressed!();
          }
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(
          'Add to Cart - ₹${(price * quantity).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

class CompactAddToCartButton extends StatelessWidget {
  final String productId;
  final String productName;
  final String productType;
  final double price;
  final double pricePerKg;
  final String? imageUrl;
  final int quantity;
  final int weightInKg;
  final VoidCallback? onPressed;

  const CompactAddToCartButton({
    super.key,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.price,
    required this.weightInKg,
    required this.pricePerKg,
    this.imageUrl,
    this.quantity = 1,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () {
        final cartItem = CartItemEntity(
          productId: productId,
          productName: productName,
          productType: productType,
          quantity: quantity,
          price: price,
          mrp: price,
          weightInKg: weightInKg,
          pricePerKg: pricePerKg,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<CartBloc>().add(AddItemToCart(item: cartItem));

        if (onPressed != null) {
          onPressed!();
        }
      },
      icon: const Icon(Icons.add_shopping_cart, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
