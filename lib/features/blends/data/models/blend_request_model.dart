import 'package:one_atta/features/blends/domain/entities/blend_request_entity.dart';

class CreateBlendModel {
  final String? name;
  final List<CreateAdditiveModel> additives;
  final bool? isPublic;
  final double? weightKg;

  const CreateBlendModel({
    this.name,
    required this.additives,
    this.isPublic,
    this.weightKg,
  });

  factory CreateBlendModel.fromEntity(CreateBlendEntity entity) {
    return CreateBlendModel(
      name: entity.name,
      additives: entity.additives
          .map((additive) => CreateAdditiveModel.fromEntity(additive))
          .toList(),
      isPublic: entity.isPublic,
      weightKg: entity.weightKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      'additives': additives.map((additive) => additive.toJson()).toList(),
      if (isPublic != null) 'is_public': isPublic,
      if (weightKg != null) 'weight_kg': weightKg,
    };
  }
}

class CreateAdditiveModel {
  final String ingredient;
  final double percentage;

  const CreateAdditiveModel({
    required this.ingredient,
    required this.percentage,
  });

  factory CreateAdditiveModel.fromEntity(CreateAdditiveEntity entity) {
    return CreateAdditiveModel(
      ingredient: entity.ingredient,
      percentage: entity.percentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredient': ingredient, 'percentage': percentage};
  }
}

class UpdateBlendModel {
  final String? name;
  final String? baseGrain;
  final List<CreateAdditiveModel>? additives;
  final bool? isPublic;
  final double? pricePerKg;

  const UpdateBlendModel({
    this.name,
    this.baseGrain,
    this.additives,
    this.isPublic,
    this.pricePerKg,
  });

  factory UpdateBlendModel.fromEntity(UpdateBlendEntity entity) {
    return UpdateBlendModel(
      name: entity.name,
      baseGrain: entity.baseGrain,
      additives: entity.additives
          ?.map((additive) => CreateAdditiveModel.fromEntity(additive))
          .toList(),
      isPublic: entity.isPublic,
      pricePerKg: entity.pricePerKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (baseGrain != null) 'base_grain': baseGrain,
      if (additives != null)
        'additives': additives!.map((additive) => additive.toJson()).toList(),
      if (isPublic != null) 'is_public': isPublic,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
    };
  }
}
