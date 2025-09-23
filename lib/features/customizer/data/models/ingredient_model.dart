import 'package:one_atta/features/customizer/domain/entities/ingredient_entity.dart';

/// Data model for Ingredient API responses
///
/// This maps the JSON response from the '/api/ingredients' endpoint
/// to the domain entity. Based on the Ingredient API documentation.
class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.id,
    required super.sku,
    required super.name,
    super.description,
    required super.isSeasonal,
    required super.isAvailable,
    required super.pricePerKg,
    super.ingPicture,
    super.nutritionalInfo,
    required super.displayName,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create IngredientModel from JSON
  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isSeasonal: json['isSeasonal'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      ingPicture: json['ing_picture'] as String?,
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfoModel.fromJson(
              json['nutritional_info'] as Map<String, dynamic>,
            )
          : null,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert IngredientModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'isSeasonal': isSeasonal,
      'is_available': isAvailable,
      'price_per_kg': pricePerKg,
      'ing_picture': ingPicture,
      'nutritional_info': nutritionalInfo != null
          ? (nutritionalInfo! as NutritionalInfoModel).toJson()
          : null,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create IngredientModel from entity
  factory IngredientModel.fromEntity(IngredientEntity entity) {
    return IngredientModel(
      id: entity.id,
      sku: entity.sku,
      name: entity.name,
      description: entity.description,
      isSeasonal: entity.isSeasonal,
      isAvailable: entity.isAvailable,
      pricePerKg: entity.pricePerKg,
      ingPicture: entity.ingPicture,
      nutritionalInfo: entity.nutritionalInfo != null
          ? NutritionalInfoModel.fromEntity(entity.nutritionalInfo!)
          : null,
      displayName: entity.displayName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Data model for Nutritional Information
class NutritionalInfoModel extends NutritionalInfo {
  const NutritionalInfoModel({super.calories, super.protein, super.carbs});

  /// Create NutritionalInfoModel from JSON
  factory NutritionalInfoModel.fromJson(Map<String, dynamic> json) {
    return NutritionalInfoModel(
      calories: json['calories'] != null
          ? (json['calories'] as num).toDouble()
          : null,
      protein: json['protein'] != null
          ? (json['protein'] as num).toDouble()
          : null,
      carbs: json['carbs'] != null ? (json['carbs'] as num).toDouble() : null,
    );
  }

  /// Convert NutritionalInfoModel to JSON
  Map<String, dynamic> toJson() {
    return {'calories': calories, 'protein': protein, 'carbs': carbs};
  }

  /// Create NutritionalInfoModel from entity
  factory NutritionalInfoModel.fromEntity(NutritionalInfo entity) {
    return NutritionalInfoModel(
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
    );
  }
}

/// API Response model for ingredients endpoint
class IngredientsApiResponse {
  final bool success;
  final String message;
  final List<IngredientModel> data;

  const IngredientsApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Create IngredientsApiResponse from JSON
  factory IngredientsApiResponse.fromJson(Map<String, dynamic> json) {
    return IngredientsApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => IngredientModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
