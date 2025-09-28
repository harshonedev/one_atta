import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_points/loyalty_points_event.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_points/loyalty_points_state.dart';

class LoyaltyPointsBloc extends Bloc<LoyaltyPointsEvent, LoyaltyPointsState> {
  final ProfileRepository profileRepository;
  final Logger logger = Logger();

  LoyaltyPointsBloc({required this.profileRepository})
    : super(const LoyaltyPointsInitial()) {
    on<EarnPointsFromOrderRequested>(_onEarnPointsFromOrderRequested);
    on<EarnPointsFromShareRequested>(_onEarnPointsFromShareRequested);
    on<EarnPointsFromReviewRequested>(_onEarnPointsFromReviewRequested);
    on<RedeemPointsRequested>(_onRedeemPointsRequested);
    on<ResetLoyaltyOperationState>(_onResetLoyaltyOperationState);
  }

  Future<void> _onEarnPointsFromOrderRequested(
    EarnPointsFromOrderRequested event,
    Emitter<LoyaltyPointsState> emit,
  ) async {
    emit(const LoyaltyPointsLoading(operation: 'Earning points from order'));
    logger.i(
      'Earning points from order: ${event.orderId}, amount: ${event.amount}',
    );

    final result = await profileRepository.earnPointsFromOrder(
      amount: event.amount,
      orderId: event.orderId,
    );

    result.fold(
      (failure) {
        logger.e('Failed to earn points from order: ${failure.message}');
        emit(
          LoyaltyPointsError(
            message: failure.message,
            operation: 'earn_order',
            errorType: _getErrorType(failure),
          ),
        );
      },
      (response) {
        logger.i('Points earned from order: ${response.points}');
        emit(
          PointsEarned(
            response: response,
            reason: LoyaltyTransactionReason.order,
          ),
        );
      },
    );
  }

  Future<void> _onEarnPointsFromShareRequested(
    EarnPointsFromShareRequested event,
    Emitter<LoyaltyPointsState> emit,
  ) async {
    emit(const LoyaltyPointsLoading(operation: 'Earning points from share'));
    logger.i('Earning points from sharing blend: ${event.blendId}');

    final result = await profileRepository.earnPointsFromShare(
      blendId: event.blendId,
    );

    result.fold(
      (failure) {
        logger.e('Failed to earn points from share: ${failure.message}');
        emit(
          LoyaltyPointsError(
            message: failure.message,
            operation: 'earn_share',
            errorType: _getErrorType(failure),
          ),
        );
      },
      (response) {
        logger.i('Points earned from sharing: ${response.points}');
        emit(
          PointsEarned(
            response: response,
            reason: LoyaltyTransactionReason.share,
          ),
        );
      },
    );
  }

  Future<void> _onEarnPointsFromReviewRequested(
    EarnPointsFromReviewRequested event,
    Emitter<LoyaltyPointsState> emit,
  ) async {
    emit(const LoyaltyPointsLoading(operation: 'Earning points from review'));
    logger.i('Earning points from review: ${event.reviewId}');

    final result = await profileRepository.earnPointsFromReview(
      reviewId: event.reviewId,
    );

    result.fold(
      (failure) {
        logger.e('Failed to earn points from review: ${failure.message}');
        emit(
          LoyaltyPointsError(
            message: failure.message,
            operation: 'earn_review',
            errorType: _getErrorType(failure),
          ),
        );
      },
      (response) {
        logger.i('Points earned from review: ${response.points}');
        emit(
          PointsEarned(
            response: response,
            reason: LoyaltyTransactionReason.review,
          ),
        );
      },
    );
  }

  Future<void> _onRedeemPointsRequested(
    RedeemPointsRequested event,
    Emitter<LoyaltyPointsState> emit,
  ) async {
    emit(const LoyaltyPointsLoading(operation: 'Redeeming points'));
    logger.i(
      'Redeeming points: ${event.pointsToRedeem} for order: ${event.orderId}',
    );

    final result = await profileRepository.redeemPoints(
      orderId: event.orderId,
      pointsToRedeem: event.pointsToRedeem,
    );

    result.fold(
      (failure) {
        logger.e('Failed to redeem points: ${failure.message}');
        emit(
          LoyaltyPointsError(
            message: failure.message,
            operation: 'redeem',
            errorType: _getErrorType(failure),
          ),
        );
      },
      (response) {
        logger.i(
          'Points redeemed: ${response.redeemed}, remaining: ${response.remainingPoints}',
        );
        emit(PointsRedeemed(response: response));
      },
    );
  }

  Future<void> _onResetLoyaltyOperationState(
    ResetLoyaltyOperationState event,
    Emitter<LoyaltyPointsState> emit,
  ) async {
    logger.i('Resetting loyalty points state');
    emit(const LoyaltyPointsInitial());
  }

  String _getErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) return 'unauthorized';
    if (failure is NetworkFailure) return 'network';
    if (failure is ValidationFailure) return 'validation';
    return 'server';
  }
}
