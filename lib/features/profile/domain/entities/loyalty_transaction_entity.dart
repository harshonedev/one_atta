import 'package:equatable/equatable.dart';

class LoyaltyTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final LoyaltyTransactionReason reason;
  final String referenceId;
  final int points;
  final String description;
  final DateTime? earnedAt;
  final DateTime? redeemedAt;

  const LoyaltyTransactionEntity({
    required this.id,
    required this.userId,
    required this.reason,
    required this.referenceId,
    required this.points,
    required this.description,
    this.earnedAt,
    this.redeemedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    reason,
    referenceId,
    points,
    description,
    earnedAt,
    redeemedAt,
  ];

  /// Returns true if this is a positive transaction (earning points)
  bool get isEarned => points > 0;

  /// Returns true if this is a negative transaction (redeeming points)
  bool get isRedeemed => points < 0;

  /// Returns the absolute value of points
  int get absolutePoints => points.abs();

  /// Returns the transaction date (earned or redeemed)
  DateTime get transactionDate => earnedAt ?? redeemedAt ?? DateTime.now();
}

enum LoyaltyTransactionReason {
  order('ORDER'),
  share('SHARE'),
  review('REVIEW'),
  redeem('REDEEM'),
  bonus('BONUS'),
  referral('REFERRAL');

  const LoyaltyTransactionReason(this.value);
  final String value;

  static LoyaltyTransactionReason fromString(String value) {
    return LoyaltyTransactionReason.values.firstWhere(
      (reason) => reason.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LoyaltyTransactionReason.bonus,
    );
  }

  String get displayName {
    switch (this) {
      case LoyaltyTransactionReason.order:
        return 'Order Purchase';
      case LoyaltyTransactionReason.share:
        return 'Blend Share';
      case LoyaltyTransactionReason.review:
        return 'Product Review';
      case LoyaltyTransactionReason.redeem:
        return 'Points Redemption';
      case LoyaltyTransactionReason.bonus:
        return 'Bonus Points';
      case LoyaltyTransactionReason.referral:
        return 'Referral Reward';
    }
  }
}

class EarnPointsEntity extends Equatable {
  final String? orderId;
  final String? blendId;
  final String? reviewId;
  final double? amount;

  const EarnPointsEntity({
    this.orderId,
    this.blendId,
    this.reviewId,
    this.amount,
  });

  @override
  List<Object?> get props => [orderId, blendId, reviewId, amount];
}

class RedeemPointsEntity extends Equatable {
  final String orderId;
  final int pointsToRedeem;

  const RedeemPointsEntity({
    required this.orderId,
    required this.pointsToRedeem,
  });

  @override
  List<Object?> get props => [orderId, pointsToRedeem];
}

class LoyaltyPointsResponse extends Equatable {
  final bool success;
  final int points;
  final double? monetaryValue;
  final String message;
  final String? transactionId;

  const LoyaltyPointsResponse({
    required this.success,
    required this.points,
    this.monetaryValue,
    required this.message,
    this.transactionId,
  });

  @override
  List<Object?> get props => [
    success,
    points,
    monetaryValue,
    message,
    transactionId,
  ];
}

class RedemptionResponse extends Equatable {
  final int redeemed;
  final int remainingPoints;
  final String transactionId;

  const RedemptionResponse({
    required this.redeemed,
    required this.remainingPoints,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [redeemed, remainingPoints, transactionId];
}
