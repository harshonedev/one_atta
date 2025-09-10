import 'package:flutter/material.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';

class CartSummaryWidget extends StatelessWidget {
  final CartEntity cart;

  const CartSummaryWidget({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.totalPrice;
    const shipping = 0.0; // Free shipping as per design
    final total = subtotal + shipping;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              context,
              'Subtotal',
              '₹${subtotal.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Shipping',
              shipping == 0.0 ? 'Free' : '₹${shipping.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Total',
              '₹${total.toStringAsFixed(0)}',
              isTotal: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  // TODO: Implement checkout logic
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
