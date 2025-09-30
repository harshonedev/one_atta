import 'package:flutter/material.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

class EnhancedCartSummaryWidget extends StatelessWidget {
  final List<CartItemEntity> cartItems;
  final CouponEntity? appliedCoupon;
  final int loyaltyPointsRedeemed;

  // New price parameters
  final double? mrpTotal;
  final double? itemTotal;
  final double? deliveryFee;
  final double? couponDiscount;
  final double? loyaltyDiscount;
  final double? savingsTotal;
  final double? toPayTotal;

  const EnhancedCartSummaryWidget({
    super.key,
    required this.cartItems,
    this.appliedCoupon,
    this.loyaltyPointsRedeemed = 0,
    this.mrpTotal,
    this.itemTotal,
    this.deliveryFee,
    this.couponDiscount,
    this.loyaltyDiscount,
    this.savingsTotal,
    this.toPayTotal,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided values or calculate if not provided
    final subtotal = itemTotal ?? _calculateSubtotal();
    final delFee = deliveryFee ?? _calculateDeliveryFee(subtotal);
    final coupDiscount = couponDiscount ?? _calculateCouponDiscount(subtotal);
    final loyalDiscount = loyaltyDiscount ?? loyaltyPointsRedeemed.toDouble();
    final total =
        toPayTotal ??
        _calculateTotal(subtotal, delFee, coupDiscount, loyalDiscount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Subtotal
            _buildSummaryRow(
              context,
              'Subtotal',
              '₹${subtotal.toStringAsFixed(2)}',
            ),

            // Delivery Fee
            _buildSummaryRow(
              context,
              'Delivery Fee',
              delFee == 0 ? 'FREE' : '₹${delFee.toStringAsFixed(2)}',
              isDeliveryFree: deliveryFee == 0,
            ),

            // Coupon Discount
            if (appliedCoupon != null && coupDiscount > 0) ...[
              _buildSummaryRow(
                context,
                'Coupon Discount (${appliedCoupon!.code})',
                '-₹${coupDiscount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            ],

            // Loyalty Points Discount
            if (loyaltyPointsRedeemed > 0) ...[
              _buildSummaryRow(
                context,
                'Loyalty Points ($loyaltyPointsRedeemed points)',
                '-₹${loyalDiscount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            ],

            const Divider(height: 24),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'To Pay',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Savings summary
            if (coupDiscount > 0 || loyalDiscount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'You saved ₹${(coupDiscount + loyalDiscount).toStringAsFixed(2)} on this order!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    bool isDeliveryFree = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : isDeliveryFree
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
  }

  double _calculateDeliveryFee(double subtotal) {
    // Free delivery for orders above ₹299
    return subtotal >= 299 ? 0.0 : 49.0;
  }

  double _calculateCouponDiscount(double subtotal) {
    if (appliedCoupon == null) return 0.0;
    return appliedCoupon!.getDiscountAmount(subtotal);
  }

  double _calculateTotal(
    double subtotal,
    double deliveryFee,
    double couponDiscount,
    double loyaltyDiscount,
  ) {
    final total = subtotal + deliveryFee - couponDiscount - loyaltyDiscount;
    return total < 0 ? 0 : total;
  }
}
