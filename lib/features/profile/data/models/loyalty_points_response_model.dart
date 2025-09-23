import 'package:one_atta/features/profile/domain/entities/loyalty_points_response_entity.dart';

class LoyaltyPointsResponseModel extends LoyaltyPointsResponseEntity {
  const LoyaltyPointsResponseModel({
    required super.message,
    required super.points,
    required super.totalPoints,
  });

  factory LoyaltyPointsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoyaltyPointsResponseModel(
      message: json['message'] as String,
      points: data?['points'] as int? ?? 0,
      totalPoints: data?['totalPoints'] as int? ?? 0,
    );
  }

  LoyaltyPointsResponseEntity toEntity() {
    return LoyaltyPointsResponseEntity(
      message: message,
      points: points,
      totalPoints: totalPoints,
    );
  }
}
