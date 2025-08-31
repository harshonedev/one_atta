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

  const RecipeDetailsLoaded({required this.recipe, this.isFavorite = false});

  RecipeDetailsLoaded copyWith({RecipeEntity? recipe, bool? isFavorite}) {
    return RecipeDetailsLoaded(
      recipe: recipe ?? this.recipe,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [recipe, isFavorite];
}

class RecipeDetailsError extends RecipeDetailsState {
  final String message;

  const RecipeDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
