import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_event.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_state.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/loyalty/presentation/widgets/transaction_card.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  LoyaltyTransactionReason? _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    context.read<LoyaltyHistoryBloc>().add(const GetLoyaltyHistoryRequested());
  }

  List<LoyaltyTransactionEntity> _getFilteredTransactions(
    List<LoyaltyTransactionEntity> transactions,
  ) {
    if (_selectedFilter == null) {
      return transactions;
    }
    return transactions
        .where((transaction) => transaction.reason == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: Icon(
              _selectedFilter != null
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: _selectedFilter != null
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
            tooltip: 'Filter Transactions',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _initializeData(),
        child: BlocBuilder<LoyaltyHistoryBloc, LoyaltyHistoryState>(
          builder: (context, state) {
            if (state is LoyaltyHistoryLoading) {
              return _buildLoadingState(context);
            }

            if (state is LoyaltyHistoryError) {
              return _buildErrorState(context, state.message);
            }

            if (state is LoyaltyHistoryLoaded) {
              final filteredTransactions = _getFilteredTransactions(
                state.transactions,
              );

              if (filteredTransactions.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: [
                  // Filter Indicator
                  if (_selectedFilter != null) _buildFilterIndicator(context),

                  // Transaction List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return TransactionCard(transaction: transaction);
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilterIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_alt_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedFilter!.displayName,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = null),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedFilter = null),
            child: Text(
              'Clear Filter',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary skeleton
          Container(
            margin: const EdgeInsets.all(16),
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          // Transaction skeletons
          ...List.generate(
            6,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter != null
                  ? 'No ${_selectedFilter!.displayName} Transactions'
                  : 'No Transactions Yet',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter != null
                  ? 'Try changing the filter or clearing it to see all transactions.'
                  : 'Start earning points by shopping, sharing blends, or reviewing the app!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => setState(() => _selectedFilter = null),
                child: const Text('Clear Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_alt_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter Transactions',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...LoyaltyTransactionReason.values.map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getReasonColor(reason).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTransactionIcon(reason),
                    color: _getReasonColor(reason),
                    size: 20,
                  ),
                ),
                title: Text(
                  reason.displayName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: _selectedFilter == reason
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = _selectedFilter == reason ? null : reason;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _selectedFilter = null);
                  Navigator.of(context).pop();
                },
                child: const Text('Clear Filter'),
              ),
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
    }
  }

  Color _getReasonColor(LoyaltyTransactionReason reason) {
    switch (reason) {
      case LoyaltyTransactionReason.order:
        return Colors.green;
      case LoyaltyTransactionReason.share:
        return Colors.purple;
      case LoyaltyTransactionReason.review:
        return Colors.amber;
      case LoyaltyTransactionReason.redeem:
        return Colors.red;
      case LoyaltyTransactionReason.bonus:
        return Colors.orange;
      case LoyaltyTransactionReason.referral:
        return Colors.blue;
    }
  }
}
