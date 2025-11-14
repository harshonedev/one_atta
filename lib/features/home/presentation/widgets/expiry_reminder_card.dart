import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/home/domain/entities/expiring_item_entity.dart';

class ExpiryReminderCard extends StatelessWidget {
  final ExpiringItemEntity expiringItem;

  const ExpiryReminderCard({super.key, required this.expiringItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine color based on urgency
    final Color progressColor = _getProgressColor(expiringItem.urgency);
    final Color backgroundColor = progressColor.withValues(alpha: 0.1);
    final IconData icon = _getIcon(expiringItem.urgency);

    return GestureDetector(
      onTap: () {
        // Navigate to expiring items page to see all items
        context.push('/expiring-items');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: progressColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUrgencyTitle(expiringItem.urgency),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expiringItem.itemName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${expiringItem.daysUntilExpiry} days left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      '${expiringItem.weightInKg} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: expiringItem.getProgressValue(),
                    backgroundColor: progressColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer with action hint
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  expiringItem.daysUntilExpiry == 0
                      ? "Expiring today"
                      : expiringItem.daysUntilExpiry == 1
                      ? "Expiring tomorrow"
                      : expiringItem.daysUntilExpiry < 0
                      ? "Already expired"
                      : 'Expiring within ${expiringItem.daysUntilExpiry} days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'View all items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Colors.red;
      case ExpiryUrgency.warning:
        return Colors.orange;
      case ExpiryUrgency.normal:
        return Colors.green;
    }
  }

  IconData _getIcon(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return Icons.schedule_rounded;
      case ExpiryUrgency.warning:
        return Icons.schedule_rounded;
      case ExpiryUrgency.normal:
        return Icons.info_outline_rounded;
    }
  }

  String _getUrgencyTitle(ExpiryUrgency urgency) {
    switch (urgency) {
      case ExpiryUrgency.critical:
        return 'Expiring Soon!';
      case ExpiryUrgency.warning:
        return 'Expiring This Week';
      case ExpiryUrgency.normal:
        return 'Expiry Reminder';
    }
  }
}
