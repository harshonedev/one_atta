import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_state.dart';

class TransactionCard extends StatelessWidget {
  final LoyaltyTransactionEntity transaction;
  const TransactionCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEarned = transaction.isEarned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isEarned ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTransactionIcon(transaction.reason),
                    color: isEarned ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.reason.displayName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isEarned ? '+' : '-'}${transaction.absolutePoints}',
                      style: textTheme.titleMedium?.copyWith(
                        color: isEarned ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    BlocBuilder<LoyaltyBloc, LoyaltyState>(
                      builder: (context, state) {
                        if (state is LoyaltySettingsLoaded) {
                          final value =
                              (transaction.absolutePoints *
                                      state.loyaltySettingsEntity.pointValue)
                                  .toStringAsFixed(2);
                          return Text(
                            '₹$value',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(transaction.transactionDate),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                if (transaction.referenceId.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: ${transaction.referenceId.length > 8 ? '${transaction.referenceId.substring(0, 8)}...' : transaction.referenceId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(LoyaltyTransactionReason reason) {
    switch (reason) {
      case LoyaltyTransactionReason.order:
        return Icons.shopping_cart_rounded;
      case LoyaltyTransactionReason.share:
        return Icons.share_rounded;
      case LoyaltyTransactionReason.review:
        return Icons.star_rate_rounded;
      case LoyaltyTransactionReason.redeem:
        return Icons.redeem_rounded;
      case LoyaltyTransactionReason.bonus:
        return Icons.card_giftcard_rounded;
      case LoyaltyTransactionReason.referral:
        return Icons.people_rounded;
      case LoyaltyTransactionReason.refund:
        return Icons.money_rounded;
    }
  }
}
