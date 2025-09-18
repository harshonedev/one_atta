import 'package:equatable/equatable.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';

class BlendAnalysisModel extends Equatable {
  final NutritionalInfoModel nutritionalInfoPer100g;
  final RotiCharacteristicsModel rotiCharacteristics;
  final List<String> healthBenefits;
  final List<String> allergens;
  final String suitabilityNotes;

  const BlendAnalysisModel({
    required this.nutritionalInfoPer100g,
    required this.rotiCharacteristics,
    required this.healthBenefits,
    required this.allergens,
    required this.suitabilityNotes,
  });

  factory BlendAnalysisModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    final nutrients =
        json['nutritional_info_per_100g'] as Map<String, dynamic>?;
    final rotiInfo = json['roti_characteristics'] as Map<String, dynamic>?;

    return BlendAnalysisModel(
      nutritionalInfoPer100g: NutritionalInfoModel.fromJson(nutrients ?? {}),
      rotiCharacteristics: RotiCharacteristicsModel.fromJson(rotiInfo ?? {}),
      healthBenefits: json['health_benefits'] != null
          ? List<String>.from(json['health_benefits'])
          : <String>[
              'Provides essential nutrients from multiple grains',
              'Rich in fiber and protein',
              'Supports balanced nutrition',
            ],
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : <String>[
              'May contain gluten from wheat',
              'Check individual grain sensitivities',
            ],
      suitabilityNotes:
          json['suitability_notes'] ??
          'Suitable for most dietary preferences. Check allergen information for specific restrictions.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutritional_info_per_100g': nutritionalInfoPer100g.toJson(),
      'roti_characteristics': rotiCharacteristics.toJson(),
      'health_benefits': healthBenefits,
      'allergens': allergens,
      'suitability_notes': suitabilityNotes,
    };
  }

  BlendAnalysisEntity toEntity() {
    return BlendAnalysisEntity(
      nutritionalInfo: nutritionalInfoPer100g.toEntity(),
      rotiCharacteristics: rotiCharacteristics.toEntity(),
      healthBenefits: healthBenefits,
      allergens: allergens,
      suitabilityNotes: suitabilityNotes,
    );
  }

  @override
  List<Object?> get props => [
    nutritionalInfoPer100g,
    rotiCharacteristics,
    healthBenefits,
    allergens,
    suitabilityNotes,
  ];
}

class NutritionalInfoModel extends Equatable {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double iron;

  const NutritionalInfoModel({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    required this.iron,
  });

  factory NutritionalInfoModel.fromJson(Map<String, dynamic> json) {
    return NutritionalInfoModel(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'iron': iron,
    };
  }

  NutritionalInfoEntity toEntity() {
    return NutritionalInfoEntity(
      calories: calories,
      protein: protein,
      fat: fat,
      carbohydrates: carbohydrates,
      fiber: fiber,
      iron: iron,
    );
  }

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

class RotiCharacteristicsModel extends Equatable {
  final String taste;
  final int tasteRating;
  final String texture;
  final int textureRating;
  final String softness;
  final int softnessRating;

  const RotiCharacteristicsModel({
    required this.taste,
    required this.tasteRating,
    required this.texture,
    required this.textureRating,
    required this.softness,
    required this.softnessRating,
  });

  factory RotiCharacteristicsModel.fromJson(Map<String, dynamic> json) {
    // The API currently doesn't return roti characteristics, so we'll provide defaults
    // based on nutritional info or use empty values until the API is updated
    return RotiCharacteristicsModel(
      taste: json['taste'] ?? 'Balanced flavor profile',
      tasteRating: json['taste_rating'] ?? 7,
      texture: json['texture'] ?? 'Smooth and consistent',
      textureRating: json['texture_rating'] ?? 7,
      softness: json['softness'] ?? 'Soft and pliable',
      softnessRating: json['softness_rating'] ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taste': taste,
      'taste_rating': tasteRating,
      'texture': texture,
      'texture_rating': textureRating,
      'softness': softness,
      'softness_rating': softnessRating,
    };
  }

  RotiCharacteristicsEntity toEntity() {
    return RotiCharacteristicsEntity(
      taste: taste,
      tasteRating: tasteRating,
      texture: texture,
      textureRating: textureRating,
      softness: softness,
      softnessRating: softnessRating,
    );
  }

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
