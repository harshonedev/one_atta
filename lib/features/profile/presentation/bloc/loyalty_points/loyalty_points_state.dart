import 'package:equatable/equatable.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_points_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/redemption_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';

abstract class LoyaltyPointsState extends Equatable {
  const LoyaltyPointsState();

  @override
  List<Object?> get props => [];
}

// Initial State
class LoyaltyPointsInitial extends LoyaltyPointsState {
  const LoyaltyPointsInitial();
}

// Loading States
class LoyaltyPointsLoading extends LoyaltyPointsState {
  final String operation;

  const LoyaltyPointsLoading({required this.operation});

  @override
  List<Object?> get props => [operation];
}

// Success States
class PointsEarned extends LoyaltyPointsState {
  final LoyaltyPointsResponseEntity response;
  final LoyaltyTransactionReason reason;

  const PointsEarned({required this.response, required this.reason});

  @override
  List<Object?> get props => [response, reason];

  /// Get a user-friendly success message
  String get successMessage {
    if (response.points <= 0) {
      return response.message;
    }

    switch (reason) {
      case LoyaltyTransactionReason.order:
        return 'Earned ${response.points} points from your order!';
      case LoyaltyTransactionReason.share:
        return 'Earned ${response.points} points for sharing your blend!';
      case LoyaltyTransactionReason.review:
        return 'Earned ${response.points} points for your review!';
      default:
        return 'Earned ${response.points} points!';
    }
  }
}

class PointsRedeemed extends LoyaltyPointsState {
  final RedemptionResponseEntity response;

  const PointsRedeemed({required this.response});

  @override
  List<Object?> get props => [response];

  /// Get a user-friendly success message
  String get successMessage =>
      'Successfully redeemed ${response.redeemed} points! Remaining balance: ${response.remainingPoints} points.';
}

// Error States
class LoyaltyPointsError extends LoyaltyPointsState {
  final String message;
  final String? errorType;
  final String operation;

  const LoyaltyPointsError({
    required this.message,
    required this.operation,
    this.errorType,
  });

  @override
  List<Object?> get props => [message, errorType, operation];

  /// Check if error is due to insufficient points
  bool get isInsufficientPointsError =>
      message.toLowerCase().contains('insufficient');

  /// Check if error is due to authentication issues
  bool get isAuthError => errorType == 'unauthorized';

  /// Check if error is due to network issues
  bool get isNetworkError => errorType == 'network';

  /// Check if error is due to validation issues
  bool get isValidationError => errorType == 'validation';

  /// Get a user-friendly error title based on operation
  String get errorTitle {
    switch (operation) {
      case 'earn_order':
        return 'Failed to Earn Points from Order';
      case 'earn_share':
        return 'Failed to Earn Points from Share';
      case 'earn_review':
        return 'Failed to Earn Points from Review';
      case 'redeem':
        return 'Failed to Redeem Points';
      default:
        return 'Loyalty Points Error';
    }
  }
}
