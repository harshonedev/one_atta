import 'package:equatable/equatable.dart';

class LoyaltySettingsEntity extends Equatable {
  final int orderPercentForPoints;
  final double pointValue;
  final int reviewPoints;
  final int sharePoints;
  final bool enableOrderRewards;
  final bool enableReviewRewards;
  final bool enableBlendShareRewards;

  const LoyaltySettingsEntity({
    required this.orderPercentForPoints,
    required this.pointValue,
    required this.reviewPoints,
    required this.sharePoints,
    required this.enableOrderRewards,
    required this.enableReviewRewards,
    required this.enableBlendShareRewards,
  });

  @override
  List<Object?> get props => [
    orderPercentForPoints,
    pointValue,
    reviewPoints,
    sharePoints,
    enableOrderRewards,
    enableReviewRewards,
    enableBlendShareRewards,
  ];
}
