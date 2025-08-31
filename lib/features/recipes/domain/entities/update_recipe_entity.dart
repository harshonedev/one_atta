import 'package:equatable/equatable.dart';
import 'package:one_atta/features/recipes/domain/entities/ingredient_entity.dart';

class UpdateRecipeEntity extends Equatable {
  final String? title;
  final List<IngredientEntity>? ingredients;
  final List<String>? steps;
  final String? description;
  final String? blendUsedId;
  final String? videoUrl;
  final String? recipePicture;
  final int? likes;

  const UpdateRecipeEntity({
    this.title,
    this.ingredients,
    this.steps,
    this.description,
    this.blendUsedId,
    this.videoUrl,
    this.recipePicture,
    this.likes,
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
    likes,
  ];
}
