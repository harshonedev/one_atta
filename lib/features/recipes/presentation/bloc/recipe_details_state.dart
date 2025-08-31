import 'package:equatable/equatable.dart';
import '../../data/models/recipe.dart';

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
  final Recipe recipe;
  final bool isFavorite;

  const RecipeDetailsLoaded({required this.recipe, this.isFavorite = false});

  RecipeDetailsLoaded copyWith({Recipe? recipe, bool? isFavorite}) {
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
