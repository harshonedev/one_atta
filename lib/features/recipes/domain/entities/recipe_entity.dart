import 'package:equatable/equatable.dart';
import 'package:one_atta/features/recipes/domain/entities/ingredient_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/user_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/blend_entity.dart';

class RecipeEntity extends Equatable {
  final String id;
  final String title;
  final List<IngredientEntity> ingredients;
  final List<String> steps;
  final String? description;
  final RecipeBlendEntity? blendUsed;
  final String? videoUrl;
  final int likes;
  final String? recipePicture;
  final UserEntity? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecipeEntity({
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

  @override
  List<Object?> get props => [
    id,
    title,
    ingredients,
    steps,
    description,
    blendUsed,
    videoUrl,
    likes,
    recipePicture,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
