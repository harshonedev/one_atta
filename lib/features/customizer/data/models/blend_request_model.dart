import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';

class BlendRequestModel  {
  final Map<String, int> ingredients;
  final int totalWeightG;

  BlendRequestModel({required this.ingredients, required this.totalWeightG});

  factory BlendRequestModel.fromEntity(BlendRequestEntity entity) {
    return BlendRequestModel(
      ingredients: entity.ingredients,
      totalWeightG: entity.totalWeightG,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredients': ingredients, 'total_weight_g': totalWeightG};
  }
}

class SaveBlendModel {
  final String name;
  final List<AdditiveModel> additives;
  final bool isPublic;
  final double weightKg;

  SaveBlendModel({
    required this.name,
    required this.additives,
    required this.isPublic,
    required this.weightKg,
  });

  factory SaveBlendModel.fromEntity(SaveBlendEntity entity) {
    return SaveBlendModel(
      name: entity.name,
      additives: entity.additives
          .map((additive) => AdditiveModel.fromEntity(additive))
          .toList(),
      isPublic: entity.isPublic,
      weightKg: entity.weightKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'additives': additives.map((additive) => additive.toJson()).toList(),
      'is_public': isPublic,
      'weight_kg': weightKg,
    };
  }
}

class AdditiveModel {
  final String ingredient;
  final double percentage;

  AdditiveModel({required this.ingredient, required this.percentage});

  factory AdditiveModel.fromEntity(AdditiveEntity entity) {
    return AdditiveModel(
      ingredient: entity.ingredient,
      percentage: entity.percentage,
    );
  }

  factory AdditiveModel.fromJson(Map<String, dynamic> json) {
    return AdditiveModel(
      ingredient: json['ingredient'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredient': ingredient, 'percentage': percentage};
  }

  AdditiveEntity toEntity() {
    return AdditiveEntity(ingredient: ingredient, percentage: percentage);
  }
}

class SavedBlendModel {
  final String id;
  final String name;
  final List<AdditiveModel> additives;
  final String createdBy;
  final String shareCode;
  final int shareCount;
  final bool isPublic;
  final double pricePerKg;
  final double totalPrice;
  final int expiryDays;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedBlendModel({
    required this.id,
    required this.name,
    required this.additives,
    required this.createdBy,
    required this.shareCode,
    required this.shareCount,
    required this.isPublic,
    required this.pricePerKg,
    required this.totalPrice,
    required this.expiryDays,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedBlendModel.fromJson(Map<String, dynamic> json) {
    return SavedBlendModel(
      id: json['id'],
      name: json['name'],
      additives: (json['additives'] as List)
          .map((additive) => AdditiveModel.fromJson(additive))
          .toList(),
      createdBy: json['created_by'],
      shareCode: json['share_code'],
      shareCount: json['share_count'],
      isPublic: json['is_public'],
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      expiryDays: json['expiry_days'],
      deleted: json['deleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  SavedBlendEntity toEntity() {
    return SavedBlendEntity(
      id: id,
      name: name,
      additives: additives.map((additive) => additive.toEntity()).toList(),
      createdBy: createdBy,
      shareCode: shareCode,
      shareCount: shareCount,
      isPublic: isPublic,
      pricePerKg: pricePerKg,
      totalPrice: totalPrice,
      expiryDays: expiryDays,
      deleted: deleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
