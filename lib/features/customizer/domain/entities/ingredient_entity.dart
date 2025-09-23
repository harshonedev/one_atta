import 'package:equatable/equatable.dart';

/// Entity class for Ingredient
///
/// This represents the domain model for ingredients that can be used
/// in custom blend creation. Based on the Ingredient API documentation.
class IngredientEntity extends Equatable {
  /// Unique identifier for the ingredient (MongoDB ObjectId)
  final String id;

  /// Auto-generated SKU in format: ING-XXX-9999
  final String sku;

  /// Name of the ingredient
  final String name;

  /// Optional description of the ingredient
  final String? description;

  /// Whether the ingredient is seasonal
  final bool isSeasonal;

  /// Whether the ingredient is currently available
  final bool isAvailable;

  /// Price per kilogram
  final double pricePerKg;

  /// Optional image URL for the ingredient
  final String? ingPicture;

  /// Nutritional information (optional)
  final NutritionalInfo? nutritionalInfo;

  /// Virtual display name: 'name (sku)'
  final String displayName;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  const IngredientEntity({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.isSeasonal,
    required this.isAvailable,
    required this.pricePerKg,
    this.ingPicture,
    this.nutritionalInfo,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    description,
    isSeasonal,
    isAvailable,
    pricePerKg,
    ingPicture,
    nutritionalInfo,
    displayName,
    createdAt,
    updatedAt,
  ];
}

/// Nutritional information entity
class NutritionalInfo extends Equatable {
  /// Calories per 100g
  final double? calories;

  /// Protein content in grams per 100g
  final double? protein;

  /// Carbohydrate content in grams per 100g
  final double? carbs;

  const NutritionalInfo({this.calories, this.protein, this.carbs});

  @override
  List<Object?> get props => [calories, protein, carbs];
}
