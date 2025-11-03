import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';

abstract class LoyaltyHistoryState extends Equatable {
  const LoyaltyHistoryState();

  @override
  List<Object?> get props => [];
}

// Initial State
class LoyaltyHistoryInitial extends LoyaltyHistoryState {
  const LoyaltyHistoryInitial();
}

// Loading States
class LoyaltyHistoryLoading extends LoyaltyHistoryState {
  const LoyaltyHistoryLoading();
}

class LoyaltyHistoryRefreshing extends LoyaltyHistoryState {
  final List<LoyaltyTransactionEntity> currentTransactions;

  const LoyaltyHistoryRefreshing({required this.currentTransactions});

  @override
  List<Object?> get props => [currentTransactions];
}

// Success States
class LoyaltyHistoryLoaded extends LoyaltyHistoryState {
  final List<LoyaltyTransactionEntity> transactions;
  final List<LoyaltyTransactionEntity> filteredTransactions;
  final String? appliedFilter;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const LoyaltyHistoryLoaded({
    required this.transactions,
    required this.filteredTransactions,
    this.appliedFilter,
    this.filterStartDate,
    this.filterEndDate,
  });

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    appliedFilter,
    filterStartDate,
    filterEndDate,
  ];

  /// Get total points earned from all transactions
  int get totalPointsEarned {
    return transactions
        .where((transaction) => transaction.isEarned)
        .fold(0, (sum, transaction) => sum + transaction.absolutePoints);
  }

  /// Get total points redeemed from all transactions
  int get totalPointsRedeemed {
    return transactions
        .where((transaction) => transaction.isRedeemed)
        .fold(0, (sum, transaction) => sum + transaction.absolutePoints);
  }

  /// Get net points balance from history
  int get netPointsBalance => totalPointsEarned - totalPointsRedeemed;

  /// Get transactions grouped by reason
  Map<LoyaltyTransactionReason, List<LoyaltyTransactionEntity>>
  get transactionsByReason {
    final Map<LoyaltyTransactionReason, List<LoyaltyTransactionEntity>>
    grouped = {};

    for (final transaction in filteredTransactions) {
      grouped.putIfAbsent(transaction.reason, () => []).add(transaction);
    }

    return grouped;
  }

  /// Check if any filters are applied
  bool get hasFiltersApplied =>
      appliedFilter != null || filterStartDate != null || filterEndDate != null;
}

// Error States
class LoyaltyHistoryError extends LoyaltyHistoryState {
  final String message;
  final String? errorType;
  final Failure? failure;

  const LoyaltyHistoryError({
    required this.message,
    this.errorType,
    this.failure,
  });

  @override
  List<Object?> get props => [message, errorType, failure];

  /// Check if error is due to authentication issues
  bool get isAuthError => errorType == 'unauthorized';

  /// Check if error is due to network issues
  bool get isNetworkError => errorType == 'network';
}
