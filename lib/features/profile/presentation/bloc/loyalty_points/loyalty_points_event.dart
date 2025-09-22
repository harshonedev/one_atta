import 'package:equatable/equatable.dart';

abstract class LoyaltyPointsEvent extends Equatable {
  const LoyaltyPointsEvent();

  @override
  List<Object?> get props => [];
}

class EarnPointsFromOrderRequested extends LoyaltyPointsEvent {
  final double amount;
  final String orderId;

  const EarnPointsFromOrderRequested({
    required this.amount,
    required this.orderId,
  });

  @override
  List<Object?> get props => [amount, orderId];
}

class EarnPointsFromShareRequested extends LoyaltyPointsEvent {
  final String blendId;

  const EarnPointsFromShareRequested({required this.blendId});

  @override
  List<Object?> get props => [blendId];
}

class EarnPointsFromReviewRequested extends LoyaltyPointsEvent {
  final String reviewId;

  const EarnPointsFromReviewRequested({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

class RedeemPointsRequested extends LoyaltyPointsEvent {
  final String orderId;
  final int pointsToRedeem;

  const RedeemPointsRequested({
    required this.orderId,
    required this.pointsToRedeem,
  });

  @override
  List<Object?> get props => [orderId, pointsToRedeem];
}

class ResetLoyaltyOperationState extends LoyaltyPointsEvent {
  const ResetLoyaltyOperationState();
}
