import 'package:one_atta/features/blends/data/models/additive_model.dart';
import 'package:one_atta/features/blends/data/models/created_by_model.dart';
import 'package:one_atta/features/blends/data/models/price_analysis_model.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';

class BlendModel extends BlendEntity {
  const BlendModel({
    required super.id,
    required super.name,
    required super.additives,
    required super.createdBy,
    required super.shareCode,
    required super.shareCount,
    required super.isPublic,
    required super.pricePerKg,
    super.totalPrice,
    required super.expiryDays,
    required super.deleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BlendModel.fromJson(Map<String, dynamic> json) {
    return BlendModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      additives:
          (json['additives'] as List<dynamic>?)
              ?.map((additive) => AdditiveModel.fromJson(additive))
              .toList() ??
          [],
      createdBy: json['created_by'] ?? '',
      shareCode: json['share_code'] ?? '',
      shareCount: json['share_count'] ?? 0,
      isPublic: json['is_public'] ?? false,
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      totalPrice: json['total_price']?.toDouble(),
      expiryDays: json['expiry_days'] ?? 0,
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'additives': additives
          .map((additive) => (additive as AdditiveModel).toJson())
          .toList(),
      'created_by': createdBy,
      'share_code': shareCode,
      'share_count': shareCount,
      'is_public': isPublic,
      'price_per_kg': pricePerKg,
      'total_price': totalPrice,
      'expiry_days': expiryDays,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BlendEntity toEntity() {
    return BlendEntity(
      id: id,
      name: name,
      additives: additives,
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

class BlendDetailsModel extends BlendDetailsEntity {
  const BlendDetailsModel({
    required super.id,
    required super.name,
    required super.additives,
    required super.createdBy,
    required super.shareCode,
    required super.shareCount,
    required super.isPublic,
    required super.pricePerKg,
    super.totalPrice,
    required super.expiryDays,
    super.priceAnalysis,
    super.blendPriceComparison,
    super.pricing,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BlendDetailsModel.fromJson(Map<String, dynamic> json) {
    return BlendDetailsModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      additives:
          (json['additives'] as List<dynamic>?)
              ?.map((additive) => AdditiveModel.fromJson(additive))
              .toList() ??
          [],
      createdBy: json['created_by'] ?? '',
      shareCode: json['share_code'] ?? '',
      shareCount: json['share_count'] ?? 0,
      isPublic: json['is_public'] ?? false,
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      totalPrice: json['total_price']?.toDouble(),
      expiryDays: json['expiry_days'] ?? 0,
      priceAnalysis: (json['priceAnalysis'] as List<dynamic>?)
          ?.map((analysis) => PriceAnalysisModel.fromJson(analysis))
          .toList(),
      blendPriceComparison: json['blendPriceComparison'] != null
          ? BlendPriceComparisonModel.fromJson(json['blendPriceComparison'])
          : null,
      pricing: json['pricing'] != null
          ? PricingModel.fromJson(json['pricing'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'additives': additives
          .map((additive) => (additive as AdditiveModel).toJson())
          .toList(),
      'created_by': createdBy,
      'share_code': shareCode,
      'share_count': shareCount,
      'is_public': isPublic,
      'price_per_kg': pricePerKg,
      'total_price': totalPrice,
      'expiry_days': expiryDays,
      'priceAnalysis': priceAnalysis
          ?.map((analysis) => (analysis as PriceAnalysisModel).toJson())
          .toList(),
      'blendPriceComparison':
          (blendPriceComparison as BlendPriceComparisonModel?)?.toJson(),
      'pricing': (pricing as PricingModel?)?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BlendDetailsEntity toEntity() {
    return BlendDetailsEntity(
      id: id,
      name: name,
      additives: additives,
      createdBy: createdBy,
      shareCode: shareCode,
      shareCount: shareCount,
      isPublic: isPublic,
      pricePerKg: pricePerKg,
      totalPrice: totalPrice,
      expiryDays: expiryDays,
      priceAnalysis: priceAnalysis,
      blendPriceComparison: blendPriceComparison,
      pricing: pricing,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PublicBlendModel extends PublicBlendEntity {
  const PublicBlendModel({
    required super.id,
    required super.name,
    required super.additives,
    required super.createdBy,
    required super.shareCode,
    required super.shareCount,
    required super.isPublic,
    required super.pricePerKg,
    required super.expiryDays,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PublicBlendModel.fromJson(Map<String, dynamic> json) {
    return PublicBlendModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      additives:
          (json['additives'] as List<dynamic>?)
              ?.map((additive) => AdditiveModel.fromJson(additive))
              .toList() ??
          [],
      createdBy: CreatedByModel.fromJson(json['created_by'] ?? {}),
      shareCode: json['share_code'] ?? '',
      shareCount: json['share_count'] ?? 0,
      isPublic: json['is_public'] ?? false,
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      expiryDays: json['expiry_days'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'additives': additives
          .map((additive) => (additive as AdditiveModel).toJson())
          .toList(),
      'created_by': (createdBy as CreatedByModel).toJson(),
      'share_code': shareCode,
      'share_count': shareCount,
      'is_public': isPublic,
      'price_per_kg': pricePerKg,
      'expiry_days': expiryDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PublicBlendEntity toEntity() {
    return PublicBlendEntity(
      id: id,
      name: name,
      additives: additives,
      createdBy: createdBy,
      shareCode: shareCode,
      shareCount: shareCount,
      isPublic: isPublic,
      pricePerKg: pricePerKg,
      expiryDays: expiryDays,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
