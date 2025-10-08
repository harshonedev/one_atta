import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_event.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_state.dart';

class LoyaltyHistoryBloc
    extends Bloc<LoyaltyHistoryEvent, LoyaltyHistoryState> {
  final LoyaltyRepository loyaltyRepository;
  final Logger logger = Logger();

  LoyaltyHistoryBloc({required this.loyaltyRepository})
    : super(const LoyaltyHistoryInitial()) {
    on<GetLoyaltyHistoryRequested>(_onGetLoyaltyHistoryRequested);
    on<RefreshLoyaltyHistoryRequested>(_onRefreshLoyaltyHistoryRequested);
    on<FilterLoyaltyHistoryRequested>(_onFilterLoyaltyHistoryRequested);
  }

  Future<void> _onGetLoyaltyHistoryRequested(
    GetLoyaltyHistoryRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) async {
    emit(const LoyaltyHistoryLoading());
    logger.i('Getting loyalty transaction history');

    final result = await loyaltyRepository.getLoyaltyTransactionHistory();
    result.fold(
      (failure) {
        logger.e('Failed to get loyalty history: ${failure.message}');

        // Handle 404 errors gracefully - user might not have any loyalty history yet
        if (failure is ServerFailure && failure.message.contains('404')) {
          logger.i(
            'No loyalty history found for user (404) - treating as empty history',
          );
          emit(
            const LoyaltyHistoryLoaded(
              transactions: [],
              filteredTransactions: [],
            ),
          );
        } else {
          emit(
            LoyaltyHistoryError(
              message: failure.message,
              errorType: _getErrorType(failure),
            ),
          );
        }
      },
      (transactions) {
        logger.i('Loyalty history loaded: ${transactions.length} transactions');
        emit(
          LoyaltyHistoryLoaded(
            transactions: transactions,
            filteredTransactions: transactions,
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

    logger.i('Refreshing loyalty transaction history');

    final result = await loyaltyRepository.getLoyaltyTransactionHistory();
    result.fold(
      (failure) {
        logger.e('Failed to refresh loyalty history: ${failure.message}');

        // Handle 404 errors gracefully - user might not have any loyalty history yet
        if (failure is ServerFailure && failure.message.contains('404')) {
          logger.i(
            'No loyalty history found for user (404) - treating as empty history',
          );
          emit(
            const LoyaltyHistoryLoaded(
              transactions: [],
              filteredTransactions: [],
            ),
          );
        } else {
          emit(
            LoyaltyHistoryError(
              message: failure.message,
              errorType: _getErrorType(failure),
            ),
          );
        }
      },
      (transactions) {
        logger.i(
          'Loyalty history refreshed: ${transactions.length} transactions',
        );
        emit(
          LoyaltyHistoryLoaded(
            transactions: transactions,
            filteredTransactions: transactions,
          ),
        );
      },
    );
  }

  void _onFilterLoyaltyHistoryRequested(
    FilterLoyaltyHistoryRequested event,
    Emitter<LoyaltyHistoryState> emit,
  ) {
    if (state is! LoyaltyHistoryLoaded) return;

    final currentState = state as LoyaltyHistoryLoaded;
    logger.i('Applying filters to loyalty history: ${event.filterType}');

    List<LoyaltyTransactionEntity> filteredTransactions = List.from(
      currentState.transactions,
    );

    // Apply type filter
    if (event.filterType != null) {
      switch (event.filterType) {
        case 'earning':
          filteredTransactions = filteredTransactions
              .where((transaction) => transaction.isEarned)
              .toList();
          break;
        case 'redemption':
          filteredTransactions = filteredTransactions
              .where((transaction) => transaction.isRedeemed)
              .toList();
          break;
      }
    }

    // Apply date filters
    if (event.startDate != null) {
      filteredTransactions = filteredTransactions
          .where(
            (transaction) =>
                transaction.transactionDate.isAfter(event.startDate!) ||
                transaction.transactionDate.isAtSameMomentAs(event.startDate!),
          )
          .toList();
    }

    if (event.endDate != null) {
      // End date should include the entire end day
      final endOfDay = DateTime(
        event.endDate!.year,
        event.endDate!.month,
        event.endDate!.day,
        23,
        59,
        59,
      );
      filteredTransactions = filteredTransactions
          .where(
            (transaction) =>
                transaction.transactionDate.isBefore(endOfDay) ||
                transaction.transactionDate.isAtSameMomentAs(endOfDay),
          )
          .toList();
    }

    logger.i(
      'Filtered transactions: ${filteredTransactions.length}/${currentState.transactions.length}',
    );

    emit(
      LoyaltyHistoryLoaded(
        transactions: currentState.transactions,
        filteredTransactions: filteredTransactions,
        appliedFilter: event.filterType,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ),
    );
  }

  String _getErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) return 'unauthorized';
    if (failure is NetworkFailure) return 'network';
    return 'server';
  }
}
