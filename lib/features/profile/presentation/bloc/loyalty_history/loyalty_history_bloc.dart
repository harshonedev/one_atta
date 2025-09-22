import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_event.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_state.dart';

class LoyaltyHistoryBloc
    extends Bloc<LoyaltyHistoryEvent, LoyaltyHistoryState> {
  final ProfileRepository profileRepository;
  final Logger logger = Logger();

  LoyaltyHistoryBloc({required this.profileRepository})
    : super(const LoyaltyHistoryInitial()) {
    on<GetLoyaltyHistoryRequested>(_onGetLoyaltyHistoryRequested);
    on<RefreshLoyaltyHistoryRequested>(_onRefreshLoyaltyHistoryRequested);
    on<ClearLoyaltyHistoryCacheRequested>(_onClearLoyaltyHistoryCacheRequested);
    on<FilterLoyaltyHistoryRequested>(_onFilterLoyaltyHistoryRequested);
  }

  Future<void> _onGetLoyaltyHistoryRequested(
    GetLoyaltyHistoryRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) async {
    emit(const LoyaltyHistoryLoading());
    logger.i('Getting loyalty transaction history');

    final result = await profileRepository.getLoyaltyTransactionHistory();
    result.fold(
      (failure) {
        logger.e('Failed to get loyalty history: ${failure.message}');
        emit(
          LoyaltyHistoryError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (transactions) {
        logger.i('Loyalty history loaded: ${transactions.length} transactions');
        emit(
          LoyaltyHistoryLoaded(
            transactions: transactions,
            filteredTransactions: transactions,
            isFromCache: true, // Assume cache-first strategy
          ),
        );
      },
    );
  }

  Future<void> _onRefreshLoyaltyHistoryRequested(
    RefreshLoyaltyHistoryRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) async {
    // Show refreshing state with current data if available
    if (state is LoyaltyHistoryLoaded) {
      final currentState = state as LoyaltyHistoryLoaded;
      emit(
        LoyaltyHistoryRefreshing(
          currentTransactions: currentState.transactions,
        ),
      );
    } else {
      emit(const LoyaltyHistoryLoading());
    }

    logger.i('Refreshing loyalty transaction history (bypassing cache)');

    // Clear cache first to force fresh data
    await profileRepository.clearCachedLoyaltyHistory();

    final result = await profileRepository.getLoyaltyTransactionHistory();
    result.fold(
      (failure) {
        logger.e('Failed to refresh loyalty history: ${failure.message}');
        emit(
          LoyaltyHistoryError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (transactions) {
        logger.i(
          'Loyalty history refreshed: ${transactions.length} transactions',
        );
        emit(
          LoyaltyHistoryLoaded(
            transactions: transactions,
            filteredTransactions: transactions,
            isFromCache: false,
          ),
        );
      },
    );
  }

  Future<void> _onClearLoyaltyHistoryCacheRequested(
    ClearLoyaltyHistoryCacheRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) async {
    logger.i('Clearing loyalty history cache');

    final result = await profileRepository.clearCachedLoyaltyHistory();
    result.fold(
      (failure) {
        logger.e('Failed to clear loyalty history cache: ${failure.message}');
        emit(
          LoyaltyHistoryError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (_) {
        logger.i('Loyalty history cache cleared successfully');
        emit(const LoyaltyHistoryCacheCleared());
      },
    );
  }

  Future<void> _onFilterLoyaltyHistoryRequested(
    FilterLoyaltyHistoryRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) async {
    if (state is! LoyaltyHistoryLoaded) {
      logger.w('Cannot filter loyalty history: no data loaded');
      return;
    }

    final currentState = state as LoyaltyHistoryLoaded;
    logger.i(
      'Filtering loyalty history with: ${event.filterType}, ${event.startDate}, ${event.endDate}',
    );

    final filteredTransactions = _applyFilters(
      transactions: currentState.transactions,
      filterType: event.filterType,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    emit(
      LoyaltyHistoryLoaded(
        transactions: currentState.transactions,
        filteredTransactions: filteredTransactions,
        isFromCache: currentState.isFromCache,
        appliedFilter: event.filterType,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ),
    );
  }

  List<LoyaltyTransactionEntity> _applyFilters({
    required List<LoyaltyTransactionEntity> transactions,
    String? filterType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = transactions;

    // Filter by transaction type
    if (filterType != null) {
      switch (filterType.toLowerCase()) {
        case 'earning':
          filtered = filtered.where((t) => t.isEarned).toList();
          break;
        case 'redemption':
          filtered = filtered.where((t) => t.isRedeemed).toList();
          break;
      }
    }

    // Filter by date range
    if (startDate != null) {
      filtered = filtered
          .where(
            (t) => t.transactionDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    if (endDate != null) {
      filtered = filtered
          .where(
            (t) => t.transactionDate.isBefore(
              endDate.add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    // Sort by transaction date (newest first)
    filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return filtered;
  }

  String _getErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) return 'unauthorized';
    if (failure is NetworkFailure) return 'network';
    if (failure is ValidationFailure) return 'validation';
    if (failure is CacheFailure) return 'cache';
    return 'server';
  }
}
