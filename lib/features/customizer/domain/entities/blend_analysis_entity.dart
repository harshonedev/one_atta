import 'package:equatable/equatable.dart';

class BlendAnalysisEntity extends Equatable {
  final NutritionalInfoEntity nutritionalInfo;
  final RotiCharacteristicsEntity rotiCharacteristics;
  final List<String> healthBenefits;
  final List<String> allergens;
  final String suitabilityNotes;

  const BlendAnalysisEntity({
    required this.nutritionalInfo,
    required this.rotiCharacteristics,
    required this.healthBenefits,
    required this.allergens,
    required this.suitabilityNotes,
  });

  @override
  List<Object?> get props => [
    nutritionalInfo,
    rotiCharacteristics,
    healthBenefits,
    allergens,
    suitabilityNotes,
  ];
}

class NutritionalInfoEntity extends Equatable {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double iron;

  const NutritionalInfoEntity({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    required this.iron,
  });

  @override
  List<Object?> get props => [
    calories,
    protein,
    fat,
    carbohydrates,
    fiber,
    iron,
  ];
}

class RotiCharacteristicsEntity extends Equatable {
  final String taste;
  final int tasteRating;
  final String texture;
  final int textureRating;
  final String softness;
  final int softnessRating;

  const RotiCharacteristicsEntity({
    required this.taste,
    required this.tasteRating,
    required this.texture,
    required this.textureRating,
    required this.softness,
    required this.softnessRating,
  });

  @override
  List<Object?> get props => [
    taste,
    tasteRating,
    texture,
    textureRating,
    softness,
    softnessRating,
  ];
}
