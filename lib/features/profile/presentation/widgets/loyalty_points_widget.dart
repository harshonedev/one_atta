import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/di/injection_container.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';

class LoyaltyPointsWidget extends StatelessWidget {
  const LoyaltyPointsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoyaltyPointsBloc>(),
      child: const _LoyaltyPointsContent(),
    );
  }
}

class _LoyaltyPointsContent extends StatelessWidget {
  const _LoyaltyPointsContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loyalty Points Management',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const _PointsEarningSection(),
            const Divider(height: 32),
            const _PointsRedemptionSection(),
          ],
        ),
      ),
    );
  }
}

class _PointsEarningSection extends StatelessWidget {
  const _PointsEarningSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earn Points',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _EarnPointsButton(
              icon: Icons.shopping_cart,
              label: 'Order',
              subtitle: '5% of order value',
              color: colorScheme.primary,
              onPressed: () => _showEarnFromOrderDialog(context),
            ),
            _EarnPointsButton(
              icon: Icons.share,
              label: 'Share Blend',
              subtitle: '10 points',
              color: colorScheme.secondary,
              onPressed: () => _showEarnFromShareDialog(context),
            ),
            _EarnPointsButton(
              icon: Icons.star,
              label: 'Review',
              subtitle: '5 points',
              color: colorScheme.tertiary,
              onPressed: () => _showEarnFromReviewDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showEarnFromOrderDialog(BuildContext context) {
    final amountController = TextEditingController();
    final orderIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Earn Points from Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Order Amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: orderIdController,
              decoration: const InputDecoration(labelText: 'Order ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final orderId = orderIdController.text.trim();

              if (amount != null && orderId.isNotEmpty) {
                context.read<LoyaltyPointsBloc>().add(
                  EarnPointsFromOrderRequested(
                    amount: amount,
                    orderId: orderId,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Earn Points'),
          ),
        ],
      ),
    );
  }

  void _showEarnFromShareDialog(BuildContext context) {
    final blendIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Earn Points from Sharing'),
        content: TextField(
          controller: blendIdController,
          decoration: const InputDecoration(labelText: 'Blend ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final blendId = blendIdController.text.trim();

              if (blendId.isNotEmpty) {
                context.read<LoyaltyPointsBloc>().add(
                  EarnPointsFromShareRequested(blendId: blendId),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Earn Points'),
          ),
        ],
      ),
    );
  }

  void _showEarnFromReviewDialog(BuildContext context) {
    final reviewIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Earn Points from Review'),
        content: TextField(
          controller: reviewIdController,
          decoration: const InputDecoration(labelText: 'Review ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reviewId = reviewIdController.text.trim();

              if (reviewId.isNotEmpty) {
                context.read<LoyaltyPointsBloc>().add(
                  EarnPointsFromReviewRequested(reviewId: reviewId),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Earn Points'),
          ),
        ],
      ),
    );
  }
}

class _PointsRedemptionSection extends StatelessWidget {
  const _PointsRedemptionSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Points',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _showRedeemPointsDialog(context),
            icon: const Icon(Icons.redeem),
            label: const Text('Redeem Points'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }

  void _showRedeemPointsDialog(BuildContext context) {
    final orderIdController = TextEditingController();
    final pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redeem Loyalty Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: orderIdController,
              decoration: const InputDecoration(labelText: 'Order ID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(labelText: 'Points to Redeem'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final orderId = orderIdController.text.trim();
              final points = int.tryParse(pointsController.text);

              if (orderId.isNotEmpty && points != null && points > 0) {
                context.read<LoyaltyPointsBloc>().add(
                  RedeemPointsRequested(
                    orderId: orderId,
                    pointsToRedeem: points,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Redeem Points'),
          ),
        ],
      ),
    );
  }
}

class _EarnPointsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _EarnPointsButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
