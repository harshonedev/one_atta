import 'package:one_atta/features/profile/domain/entities/redemption_response_entity.dart';

class RedemptionResponseModel extends RedemptionResponseEntity {
  const RedemptionResponseModel({
    required super.message,
    required super.redeemed,
    required super.remainingPoints,
  });

  factory RedemptionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return RedemptionResponseModel(
      message: json['message'] as String,
      redeemed: data?['redeemed'] as int? ?? 0,
      remainingPoints: data?['remainingPoints'] as int? ?? 0,
    );
  }

  RedemptionResponseEntity toEntity() {
    return RedemptionResponseEntity(
      message: message,
      redeemed: redeemed,
      remainingPoints: remainingPoints,
    );
  }
}
