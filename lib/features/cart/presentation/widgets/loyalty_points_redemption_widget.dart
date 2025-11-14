import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';

class LoyaltyPointsRedemptionWidget extends StatefulWidget {
  final double orderAmount;
  final Function(int, double) onPointsRedeemed;
  final bool isDisabled;

  const LoyaltyPointsRedemptionWidget({
    super.key,
    required this.orderAmount,
    required this.onPointsRedeemed,
    this.isDisabled = false,
  });

  @override
  State<LoyaltyPointsRedemptionWidget> createState() =>
      _LoyaltyPointsRedemptionWidgetState();
}

class _LoyaltyPointsRedemptionWidgetState
    extends State<LoyaltyPointsRedemptionWidget> {
  bool _isPointsApplied = false;
  int _availablePoints = 0;

  @override
  void initState() {
    super.initState();
    context.read<LoyaltyBloc>().add(FetchLoyaltySettings());
  }

  int _getMaxRedeemablePoints(int availablePoints) {
    final maxByOrder = widget.orderAmount.toInt();
    final maxByAvailable = availablePoints;
    return maxByOrder < maxByAvailable ? maxByOrder : maxByAvailable;
  }

  double _getRedeemableAmount(int points) {
    final loyaltyState = context.read<LoyaltyBloc>().state;
    if (loyaltyState is! LoyaltySettingsLoaded) {
      return points * 1.0; // 1 point = ₹1
    }
    return points * loyaltyState.loyaltySettingsEntity.pointValue;
  }

  void _togglePoints(bool value) {
    final cartState = context.read<CartBloc>().state;
    int availablePoints = _availablePoints;

    if (cartState is CartLoaded) {
      // Calculate remaining available points after current redemption
      availablePoints = _availablePoints - cartState.loyaltyPointsRedeemed;
    }

    final maxRedeemable = _getMaxRedeemablePoints(availablePoints);

    setState(() {
      _isPointsApplied = value;
    });

    if (value) {
      // Apply maximum redeemable points
      widget.onPointsRedeemed(
        maxRedeemable,
        _getRedeemableAmount(maxRedeemable),
      );
    } else {
      // Remove all points
      widget.onPointsRedeemed(0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        // Get redeemed points from cart state
        final redeemedPointsFromCart = cartState is CartLoaded
            ? cartState.loyaltyPointsRedeemed
            : 0;

        final isRedeemed = redeemedPointsFromCart > 0;

        return BlocBuilder<LoyaltyBloc, LoyaltyState>(
          builder: (context, loyaltyState) {
            if (loyaltyState is! LoyaltySettingsLoaded) {
              return const SizedBox.shrink();
            }
            return BlocBuilder<UserProfileBloc, UserProfileState>(
              builder: (context, profileState) {
                if (profileState is UserProfileLoaded) {
                  _availablePoints = profileState.profile.loyaltyPoints;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              color: widget.isDisabled
                                  ? Colors.grey
                                  : Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Atta Points',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDisabled
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${_getMaxRedeemablePoints(_availablePoints)}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Switch(
                              value: _isPointsApplied,
                              onChanged:
                                  widget.isDisabled || _availablePoints <= 0
                                  ? null
                                  : _togglePoints,
                              inactiveThumbColor: Colors.amber.shade400,
                              inactiveTrackColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.8),
                              activeThumbColor: Colors.amber.shade700,
                              activeTrackColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.8),
                              trackOutlineColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_availablePoints <= 0 && !isRedeemed) ...[
                          _buildNoPointsMessage(),
                        ],
                        if (isRedeemed && _isPointsApplied)
                          _buildPointsMessage(
                            maxRedeemablePoints: _getMaxRedeemablePoints(
                              _availablePoints,
                            ),
                            isRedeemed: isRedeemed,
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
      },
    );
  }

  Widget _buildNoPointsMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You don\'t have any Atta Points yet. Start shopping to earn points!',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsMessage({
    required int maxRedeemablePoints,
    required bool isRedeemed,
  }) {
    final redeemableAmount = _getRedeemableAmount(maxRedeemablePoints);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isPointsApplied && isRedeemed
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isPointsApplied && isRedeemed
              ? Colors.green.shade200
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Saved ₹${redeemableAmount.toStringAsFixed(0)} on this order',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _isPointsApplied
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
