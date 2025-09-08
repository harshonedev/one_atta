import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/ingredient_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/user_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/blend_entity.dart';

class RecipeModel {
  final String id;
  final String title;
  final List<IngredientModel> ingredients;
  final List<String> steps;
  final String? description;
  final BlendModel? blendUsed;
  final String? videoUrl;
  final int likes;
  final String? recipePicture;
  final UserModel? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.description,
    this.blendUsed,
    this.videoUrl,
    required this.likes,
    this.recipePicture,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e))
              .toList() ??
          [],
      steps: List<String>.from(json['steps'] ?? []),
      description: json['description'],
      blendUsed: json['blend_used'] != null
          ? BlendModel.fromJson(json['blend_used'])
          : null,
      videoUrl: json['video_url'],
      likes: json['likes'] ?? 0,
      recipePicture: json['recipe_picture'],
      createdBy: json['created_by'] != null
          ? UserModel.fromJson(json['created_by'])
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
      '_id': id,
      'title': title,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
      'description': description,
      'blend_used': blendUsed?.toJson(),
      'video_url': videoUrl,
      'likes': likes,
      'recipe_picture': recipePicture,
      'created_by': createdBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RecipeEntity toEntity() {
    return RecipeEntity(
      id: id,
      title: title,
      ingredients: ingredients.map((e) => e.toEntity()).toList(),
      steps: steps,
      description: description,
      blendUsed: blendUsed?.toEntity(),
      videoUrl: videoUrl,
      likes: likes,
      recipePicture: recipePicture,
      createdBy: createdBy?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class IngredientModel {
  final String name;
  final double quantity;
  final String unit;

  IngredientModel({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit};
  }

  IngredientEntity toEntity() {
    return IngredientEntity(name: name, quantity: quantity, unit: unit);
  }
}

class BlendModel {
  final String id;
  final String name;
  final String? description;

  BlendModel({required this.id, required this.name, this.description});

  factory BlendModel.fromJson(Map<String, dynamic> json) {
    return BlendModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'description': description};
  }

  RecipeBlendEntity toEntity() {
    return RecipeBlendEntity(id: id, name: name, description: description);
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email};
  }

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email);
  }
}
