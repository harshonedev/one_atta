import 'package:equatable/equatable.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';

abstract class RecipeDetailsState extends Equatable {
  const RecipeDetailsState();

  @override
  List<Object?> get props => [];
}

class RecipeDetailsInitial extends RecipeDetailsState {
  const RecipeDetailsInitial();
}

class RecipeDetailsLoading extends RecipeDetailsState {
  const RecipeDetailsLoading();
}

class RecipeDetailsLoaded extends RecipeDetailsState {
  final RecipeEntity recipe;
  final bool isFavorite;
  final bool isLiked;
  final int likesCount;
  final bool isLiking;

  const RecipeDetailsLoaded({
    required this.recipe,
    this.isFavorite = false,
    this.isLiked = false,
    required this.likesCount,
    this.isLiking = false,
  });

  RecipeDetailsLoaded copyWith({
    RecipeEntity? recipe,
    bool? isFavorite,
    bool? isLiked,
    int? likesCount,
    bool? isLiking,
  }) {
    return RecipeDetailsLoaded(
      recipe: recipe ?? this.recipe,
      isFavorite: isFavorite ?? this.isFavorite,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
      isLiking: isLiking ?? this.isLiking,
    );
  }

  @override
  List<Object?> get props => [
    recipe,
    isFavorite,
    isLiked,
    likesCount,
    isLiking,
  ];
}

class RecipeDetailsError extends RecipeDetailsState {
  final String message;

  const RecipeDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
