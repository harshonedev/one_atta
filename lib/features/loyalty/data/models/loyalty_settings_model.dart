import 'package:one_atta/features/loyalty/domain/entities/loyalty_settings_entity.dart';

class LoyaltySettingsModel extends LoyaltySettingsEntity {
  const LoyaltySettingsModel({
    required super.orderPercentForPoints,
    required super.pointValue,
    required super.reviewPoints,
    required super.sharePoints,
    required super.enableOrderRewards,
    required super.enableReviewRewards,
    required super.enableBlendShareRewards,
  });

  factory LoyaltySettingsModel.fromJson(Map<String, dynamic> data) {
    return LoyaltySettingsModel(
      orderPercentForPoints: data['order_percentage'] as int? ?? 0,
      pointValue: (data['point_value'] as num?)?.toDouble() ?? 0.0,
      reviewPoints: data['review_points'] as int? ?? 0,
      sharePoints: data['share_points'] as int? ?? 0,
      enableOrderRewards: data['enable_order_rewards'] as bool? ?? false,
      enableReviewRewards: data['enable_reviews'] as bool? ?? false,
      enableBlendShareRewards: data['enable_blend_sharing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_percentage': orderPercentForPoints,
      'point_value': pointValue,
      'review_points': reviewPoints,
      'share_points': sharePoints,
      'enable_order_rewards': enableOrderRewards,
      'enable_reviews': enableReviewRewards,
      'enable_blend_sharing': enableBlendShareRewards,
    };
  }

  LoyaltySettingsEntity toEntity() {
    return LoyaltySettingsEntity(
      orderPercentForPoints: orderPercentForPoints,
      pointValue: pointValue,
      reviewPoints: reviewPoints,
      sharePoints: sharePoints,
      enableOrderRewards: enableOrderRewards,
      enableReviewRewards: enableReviewRewards,
      enableBlendShareRewards: enableBlendShareRewards,
    );
  }
}
