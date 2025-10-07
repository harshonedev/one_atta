import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_state.dart';

class CouponInputWidget extends StatefulWidget {
  final double orderAmount;
  final List<CouponItem> items;
  final Function(CouponEntity?, double) onCouponApplied;

  const CouponInputWidget({
    super.key,
    required this.orderAmount,
    required this.items,
    required this.onCouponApplied,
  });

  @override
  State<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends State<CouponInputWidget> {
  final _couponController = TextEditingController();
  CouponEntity? _appliedCoupon;
  double _discountAmount = 0.0;
  bool _isRevalidating = false;

  @override
  void didUpdateWidget(CouponInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If order amount or items changed and we have an applied coupon, revalidate
    if (_appliedCoupon != null &&
        (oldWidget.orderAmount != widget.orderAmount ||
            oldWidget.items != widget.items)) {
      _revalidateCoupon();
    }
  }

  void _revalidateCoupon() {
    if (_appliedCoupon == null) return;

    setState(() {
      _isRevalidating = true;
    });

    context.read<CouponBloc>().add(
      RevalidateCoupon(
        couponCode: _appliedCoupon!.code,
        orderAmount: widget.orderAmount,
        items: widget.items,
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(String couponCode) {
    if (couponCode.trim().isEmpty) return;

    context.read<CouponBloc>().add(
      ApplyCoupon(
        couponCode: couponCode.trim(),
        orderAmount: widget.orderAmount,
        items: widget.items,
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discountAmount = 0.0;
      _couponController.clear();
    });
    context.read<CouponBloc>().add(const RemoveCoupon());
    widget.onCouponApplied(null, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CouponBloc, CouponState>(
      listener: (context, state) {
        if (state is CouponApplied) {
          final wasRevalidating = _isRevalidating;

          setState(() {
            _appliedCoupon = state.appliedCoupon;
            _discountAmount = state.application.discountAmount;
            _isRevalidating = false;
          });
          widget.onCouponApplied(_appliedCoupon, _discountAmount);

          // Only show snackbar for initial application, not revalidation
          if (!wasRevalidating) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (state is CouponRemoved) {
          // Handle coupon removal (auto-removal due to validation failure)
          if (_appliedCoupon != null) {
            setState(() {
              _appliedCoupon = null;
              _discountAmount = 0.0;
              _couponController.clear();
              _isRevalidating = false;
            });
            widget.onCouponApplied(null, 0.0);
          }
        } else if (state is CouponError) {
          setState(() {
            _isRevalidating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userFriendlyMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Apply Coupon',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_appliedCoupon != null) ...[
              _buildAppliedCouponCard(),
            ] else ...[
              _buildCouponInput(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCouponInput() {
    return BlocBuilder<CouponBloc, CouponState>(
      builder: (context, state) {
        final isLoading = state is CouponLoading;

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                enabled: !isLoading,
                onSubmitted: _applyCoupon,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () => _applyCoupon(_couponController.text),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppliedCouponCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _appliedCoupon!.code,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _appliedCoupon!.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'You saved ₹${_discountAmount.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removeCoupon,
            icon: Icon(Icons.close, color: Colors.green.shade600, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
