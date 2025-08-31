import 'package:one_atta/features/blends/domain/entities/price_analysis_entity.dart';

class PriceAnalysisModel extends PriceAnalysisEntity {
  const PriceAnalysisModel({
    required super.ingredientId,
    required super.percentageChange,
    required super.status,
    required super.currentPrice,
    required super.originalPrice,
  });

  factory PriceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PriceAnalysisModel(
      ingredientId: json['ingredientId'] ?? '',
      percentageChange: (json['percentageChange'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'percentageChange': percentageChange,
      'status': status,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
    };
  }

  PriceAnalysisEntity toEntity() {
    return PriceAnalysisEntity(
      ingredientId: ingredientId,
      percentageChange: percentageChange,
      status: status,
      currentPrice: currentPrice,
      originalPrice: originalPrice,
    );
  }
}

class BlendPriceComparisonModel extends BlendPriceComparisonEntity {
  const BlendPriceComparisonModel({
    required super.currentPricePerKg,
    required super.originalPricePerKg,
    required super.percentageChange,
    required super.status,
  });

  factory BlendPriceComparisonModel.fromJson(Map<String, dynamic> json) {
    return BlendPriceComparisonModel(
      currentPricePerKg: (json['currentPricePerKg'] ?? 0).toDouble(),
      originalPricePerKg: (json['originalPricePerKg'] ?? 0).toDouble(),
      percentageChange: (json['percentageChange'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPricePerKg': currentPricePerKg,
      'originalPricePerKg': originalPricePerKg,
      'percentageChange': percentageChange,
      'status': status,
    };
  }

  BlendPriceComparisonEntity toEntity() {
    return BlendPriceComparisonEntity(
      currentPricePerKg: currentPricePerKg,
      originalPricePerKg: originalPricePerKg,
      percentageChange: percentageChange,
      status: status,
    );
  }
}

class PricingModel extends PricingEntity {
  const PricingModel({required super.current, required super.original});

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      current: PriceDetailsModel.fromJson(json['current'] ?? {}),
      original: PriceDetailsModel.fromJson(json['original'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': (current as PriceDetailsModel).toJson(),
      'original': (original as PriceDetailsModel).toJson(),
    };
  }

  PricingEntity toEntity() {
    return PricingEntity(current: current, original: original);
  }
}

class PriceDetailsModel extends PriceDetailsEntity {
  const PriceDetailsModel({required super.perKg});

  factory PriceDetailsModel.fromJson(Map<String, dynamic> json) {
    return PriceDetailsModel(perKg: (json['perKg'] ?? 0).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'perKg': perKg};
  }

  PriceDetailsEntity toEntity() {
    return PriceDetailsEntity(perKg: perKg);
  }
}
