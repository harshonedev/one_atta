import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';

class LoyaltyTransactionModel extends LoyaltyTransactionEntity {
  const LoyaltyTransactionModel({
    required super.id,
    required super.userId,
    required super.reason,
    required super.referenceId,
    required super.points,
    required super.description,
    super.earnedAt,
    super.redeemedAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      reason: LoyaltyTransactionReason.fromString(json['reason'] ?? ''),
      referenceId: json['reference_id'] ?? '',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : null,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'reason': reason.value,
      'reference_id': referenceId,
      'points': points,
      'description': description,
      'earnedAt': earnedAt?.toIso8601String(),
      'redeemedAt': redeemedAt?.toIso8601String(),
    };
  }

  LoyaltyTransactionEntity toEntity() {
    return LoyaltyTransactionEntity(
      id: id,
      userId: userId,
      reason: reason,
      referenceId: referenceId,
      points: points,
      description: description,
      earnedAt: earnedAt,
      redeemedAt: redeemedAt,
    );
  }

  factory LoyaltyTransactionModel.fromEntity(LoyaltyTransactionEntity entity) {
    return LoyaltyTransactionModel(
      id: entity.id,
      userId: entity.userId,
      reason: entity.reason,
      referenceId: entity.referenceId,
      points: entity.points,
      description: entity.description,
      earnedAt: entity.earnedAt,
      redeemedAt: entity.redeemedAt,
    );
  }
}

class LoyaltyHistoryResponseModel {
  final bool success;
  final List<LoyaltyTransactionModel> history;

  const LoyaltyHistoryResponseModel({
    required this.success,
    required this.history,
  });

  factory LoyaltyHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyHistoryResponseModel(
      success: json['success'] ?? false,
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (transaction) => LoyaltyTransactionModel.fromJson(transaction),
              )
              .toList() ??
          [],
    );
  }
}

class LoyaltyPointsResponseTransactionModel extends LoyaltyPointsResponse {
  const LoyaltyPointsResponseTransactionModel({
    required super.success,
    required super.points,
    super.monetaryValue,
    required super.message,
    super.transactionId,
  });

  factory LoyaltyPointsResponseTransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? {};
    return LoyaltyPointsResponseTransactionModel(
      success: json['success'] ?? false,
      points: data['points'] ?? 0,
      monetaryValue: data['monetaryValue']?.toDouble(),
      message: json['message'] ?? data['message'] ?? '',
      transactionId: data['transactionId'],
    );
  }

  LoyaltyPointsResponse toEntity() {
    return LoyaltyPointsResponse(
      success: success,
      points: points,
      monetaryValue: monetaryValue,
      message: message,
      transactionId: transactionId,
    );
  }
}

class RedemptionResponseModel extends RedemptionResponse {
  const RedemptionResponseModel({
    required super.redeemed,
    required super.remainingPoints,
    required super.transactionId,
  });

  factory RedemptionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return RedemptionResponseModel(
      redeemed: data['redeemed'] ?? 0,
      remainingPoints: data['remainingPoints'] ?? 0,
      transactionId: data['transactionId'] ?? '',
    );
  }

  RedemptionResponse toEntity() {
    return RedemptionResponse(
      redeemed: redeemed,
      remainingPoints: remainingPoints,
      transactionId: transactionId,
    );
  }
}
