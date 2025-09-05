import 'package:flutter/material.dart';

class TotalProgressCard extends StatelessWidget {
  final double totalPercentage;
  final bool isMaxReached;

  const TotalProgressCard({
    super.key,
    required this.totalPercentage,
    required this.isMaxReached,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: Theme.of(context).colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                totalPercentage > 1.0
                    ? 'Blend Over Capacity!'
                    : 'Total Blend Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(totalPercentage * 100).toStringAsFixed(0)}%${totalPercentage > 1.0 ? '' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalPercentage.clamp(0.0, 1.0),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.tertiary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          if (isMaxReached) ...[
            const SizedBox(height: 8),
            Text(
              totalPercentage > 1.0
                  ? 'Blend exceeds 100% capacity (${(totalPercentage * 100).toStringAsFixed(0)}%). Remove ingredients to balance the blend.'
                  : 'Blend is at maximum capacity. Remove ingredients to add more.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
