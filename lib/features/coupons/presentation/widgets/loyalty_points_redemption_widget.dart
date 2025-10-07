import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  int _pointsToRedeem = 0;
  int _availablePoints = 0;
  bool _isRedeemed = false;
  final _pointsController = TextEditingController();

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  double get _redeemableAmount => _pointsToRedeem * 1.0; // 1 point = ₹1

  int get _maxRedeemablePoints {
    final maxByOrder = widget.orderAmount.toInt();
    final maxByAvailable = _availablePoints;
    return maxByOrder < maxByAvailable ? maxByOrder : maxByAvailable;
  }

  void _applyPoints() {
    if (_pointsToRedeem <= 0 || _pointsToRedeem > _maxRedeemablePoints) return;

    setState(() {
      _isRedeemed = true;
    });
    widget.onPointsRedeemed(_pointsToRedeem, _redeemableAmount);
  }

  void _removePoints() {
    setState(() {
      _isRedeemed = false;
      _pointsToRedeem = 0;
      _pointsController.clear();
    });
    widget.onPointsRedeemed(0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
          _availablePoints = state.profile.loyaltyPoints;

          // Always show the widget, even with 0 points
          final isEffectivelyDisabled =
              widget.isDisabled || _availablePoints <= 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDisabled
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: widget.isDisabled ? Colors.grey : Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Atta Points',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isDisabled
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_availablePoints available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_availablePoints <= 0) ...[
                  _buildNoPointsMessage(),
                ] else if (_isRedeemed) ...[
                  _buildRedeemedPointsCard(),
                ] else ...[
                  _buildPointsInput(isDisabled: isEffectivelyDisabled),
                ],
              ],
            ),
          );
        }

        return const SizedBox.shrink();
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

  Widget _buildPointsInput({bool isDisabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem up to $_maxRedeemablePoints points (₹$_maxRedeemablePoints)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                enabled: !isDisabled,
                decoration: InputDecoration(
                  hintText: 'Enter points to redeem',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _pointsToRedeem = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed:
                  (!isDisabled &&
                      _pointsToRedeem > 0 &&
                      _pointsToRedeem <= _maxRedeemablePoints)
                  ? _applyPoints
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text('Redeem'),
            ),
          ],
        ),
        if (_pointsToRedeem > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(
                  'Use $_maxRedeemablePoints points',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.amber.withOpacity(0.1),
                side: BorderSide(color: Colors.amber),
                onDeleted: () {
                  setState(() {
                    _pointsToRedeem = _maxRedeemablePoints;
                    _pointsController.text = _maxRedeemablePoints.toString();
                  });
                },
                deleteIcon: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ],
        if (_pointsToRedeem > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'You will save ₹${_redeemableAmount.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRedeemedPointsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_pointsToRedeem points redeemed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
                Text(
                  'Saved ₹${_redeemableAmount.toInt()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.amber.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removePoints,
            icon: Icon(Icons.close, color: Colors.amber.shade600, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
