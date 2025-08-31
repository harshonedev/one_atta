import 'package:one_atta/features/blends/domain/entities/additive_entity.dart';

class AdditiveModel extends AdditiveEntity {
  const AdditiveModel({
    required super.ingredient,
    required super.percentage,
    required super.originalDetails,
  });

  factory AdditiveModel.fromJson(Map<String, dynamic> json) {
    return AdditiveModel(
      ingredient: json['ingredient'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      originalDetails: OriginalDetailsModel.fromJson(
        json['original_details'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'percentage': percentage,
      'original_details': (originalDetails as OriginalDetailsModel).toJson(),
    };
  }

  AdditiveEntity toEntity() {
    return AdditiveEntity(
      ingredient: ingredient,
      percentage: percentage,
      originalDetails: originalDetails,
    );
  }
}

class OriginalDetailsModel extends OriginalDetailsEntity {
  const OriginalDetailsModel({
    required super.sku,
    required super.name,
    required super.pricePerKg,
  });

  factory OriginalDetailsModel.fromJson(Map<String, dynamic> json) {
    return OriginalDetailsModel(
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'sku': sku, 'name': name, 'price_per_kg': pricePerKg};
  }

  OriginalDetailsEntity toEntity() {
    return OriginalDetailsEntity(sku: sku, name: name, pricePerKg: pricePerKg);
  }
}
