import 'package:one_atta/features/recipes/domain/entities/create_recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/update_recipe_entity.dart';
import 'package:one_atta/features/recipes/data/models/recipe.dart';

class CreateRecipeModel {
  final String title;
  final List<IngredientModel> ingredients;
  final List<String> steps;
  final String? description;
  final String? blendUsedId;
  final String? videoUrl;
  final String? recipePicture;

  CreateRecipeModel({
    required this.title,
    required this.ingredients,
    required this.steps,
    this.description,
    this.blendUsedId,
    this.videoUrl,
    this.recipePicture,
  });

  factory CreateRecipeModel.fromEntity(CreateRecipeEntity entity) {
    return CreateRecipeModel(
      title: entity.title,
      ingredients: entity.ingredients
          .map(
            (ingredient) => IngredientModel(
              name: ingredient.name,
              quantity: ingredient.quantity,
              unit: ingredient.unit,
            ),
          )
          .toList(),
      steps: entity.steps,
      description: entity.description,
      blendUsedId: entity.blendUsedId,
      videoUrl: entity.videoUrl,
      recipePicture: entity.recipePicture,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
      'description': description,
      'blend_used': blendUsedId,
      'video_url': videoUrl,
      'recipe_picture': recipePicture,
    };
  }
}

class UpdateRecipeModel {
  final String? title;
  final List<IngredientModel>? ingredients;
  final List<String>? steps;
  final String? description;
  final String? blendUsedId;
  final String? videoUrl;
  final String? recipePicture;
  final int? likes;

  UpdateRecipeModel({
    this.title,
    this.ingredients,
    this.steps,
    this.description,
    this.blendUsedId,
    this.videoUrl,
    this.recipePicture,
    this.likes,
  });

  factory UpdateRecipeModel.fromEntity(UpdateRecipeEntity entity) {
    return UpdateRecipeModel(
      title: entity.title,
      ingredients: entity.ingredients
          ?.map(
            (ingredient) => IngredientModel(
              name: ingredient.name,
              quantity: ingredient.quantity,
              unit: ingredient.unit,
            ),
          )
          .toList(),
      steps: entity.steps,
      description: entity.description,
      blendUsedId: entity.blendUsedId,
      videoUrl: entity.videoUrl,
      recipePicture: entity.recipePicture,
      likes: entity.likes,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (title != null) json['title'] = title;
    if (ingredients != null) {
      json['ingredients'] = ingredients!.map((e) => e.toJson()).toList();
    }
    if (steps != null) json['steps'] = steps;
    if (description != null) json['description'] = description;
    if (blendUsedId != null) json['blend_used'] = blendUsedId;
    if (videoUrl != null) json['video_url'] = videoUrl;
    if (recipePicture != null) json['recipe_picture'] = recipePicture;
    if (likes != null) json['likes'] = likes;

    return json;
  }
}
