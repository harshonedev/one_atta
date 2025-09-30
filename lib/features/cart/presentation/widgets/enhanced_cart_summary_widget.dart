import 'package:flutter/material.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

class EnhancedCartSummaryWidget extends StatelessWidget {
  final CartEntity cart;
  final CouponEntity? appliedCoupon;
  final double couponDiscount;
  final int redeemedPoints;
  final double pointsDiscount;
  final double deliveryCharges;
  final VoidCallback onCheckout;

  const EnhancedCartSummaryWidget({
    super.key,
    required this.cart,
    this.appliedCoupon,
    this.couponDiscount = 0.0,
    this.redeemedPoints = 0,
    this.pointsDiscount = 0.0,
    this.deliveryCharges = 0.0,
    required this.onCheckout,
  });

  double get subtotal => cart.totalPrice;

  double get totalDiscount => couponDiscount + pointsDiscount;

  double get finalTotal =>
      (subtotal + deliveryCharges - totalDiscount).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryDetails(context),
              const SizedBox(height: 16),
              _buildCheckoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'Subtotal (${cart.totalItems} items)',
            '₹${subtotal.toInt()}',
          ),

          if (deliveryCharges > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Delivery charges',
              '₹${deliveryCharges.toInt()}',
            ),
          ],

          if (couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Coupon discount (${appliedCoupon?.code})',
              '-₹${couponDiscount.toInt()}',
              isDiscount: true,
            ),
          ],

          if (pointsDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Points discount ($redeemedPoints points)',
              '-₹${pointsDiscount.toInt()}',
              isDiscount: true,
            ),
          ],

          if (totalDiscount > 0) ...[
            const Divider(),
            _buildSummaryRow(
              context,
              'Total savings',
              '₹${totalDiscount.toInt()}',
              isHighlight: true,
              color: Colors.green,
            ),
          ],

          const Divider(),
          _buildSummaryRow(
            context,
            'Total Amount',
            '₹${finalTotal.toInt()}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
    bool isHighlight = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color:
                color ??
                (isTotal
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isTotal || isHighlight
                ? FontWeight.bold
                : FontWeight.w600,
            color:
                color ??
                (isDiscount
                    ? Colors.green
                    : isTotal
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: cart.isEmpty ? null : onCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Checkout',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹${finalTotal.toInt()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
