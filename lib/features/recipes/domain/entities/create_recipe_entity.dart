import 'package:equatable/equatable.dart';
import 'package:one_atta/features/recipes/domain/entities/ingredient_entity.dart';

class CreateRecipeEntity extends Equatable {
  final String title;
  final List<IngredientEntity> ingredients;
  final List<String> steps;
  final String? description;
  final String? blendUsedId;
  final String? videoUrl;
  final String? recipePicture;

  const CreateRecipeEntity({
    required this.title,
    required this.ingredients,
    required this.steps,
    this.description,
    this.blendUsedId,
    this.videoUrl,
    this.recipePicture,
  });

  @override
  List<Object?> get props => [
    title,
    ingredients,
    steps,
    description,
    blendUsedId,
    videoUrl,
    recipePicture,
  ];
}
