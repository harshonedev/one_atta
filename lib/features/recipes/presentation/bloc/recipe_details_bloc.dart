import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';
import 'recipe_details_event.dart';
import 'recipe_details_state.dart';

class RecipeDetailsBloc extends Bloc<RecipeDetailsEvent, RecipeDetailsState> {
  final RecipesRepository repository;

  RecipeDetailsBloc({required this.repository})
    : super(const RecipeDetailsInitial()) {
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<ToggleRecipeFavorite>(_onToggleRecipeFavorite);
    on<ShareRecipe>(_onShareRecipe);
    on<LikeRecipe>(_onLikeRecipe);
  }

  Future<void> _onLoadRecipeDetails(
    LoadRecipeDetails event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    emit(const RecipeDetailsLoading());

    final result = await repository.getRecipeById(event.recipeId);

    result.fold(
      (failure) => emit(RecipeDetailsError(failure.message)),
      (recipe) =>
          emit(RecipeDetailsLoaded(recipe: recipe, likesCount: recipe.likes)),
    );
  }

  Future<void> _onLikeRecipe(
    LikeRecipe event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    if (state is RecipeDetailsLoaded) {
      final currentState = state as RecipeDetailsLoaded;

      // Optimistic update - immediately update the UI
      final newLikesCount = currentState.isLiked
          ? currentState.likesCount - 1
          : currentState.likesCount + 1;

      emit(
        currentState.copyWith(
          isLiked: !currentState.isLiked,
          likesCount: newLikesCount,
          isLiking: true,
        ),
      );

      // Sync with remote database
      final result = await repository.toggleRecipeLike(event.recipeId);

      result.fold(
        (failure) {
          // Revert the optimistic update on failure
          emit(
            currentState.copyWith(
              isLiked: currentState.isLiked,
              likesCount: currentState.likesCount,
              isLiking: false,
            ),
          );
          emit(RecipeDetailsError(failure.message));
        },
        (likeData) {
          // Update with actual server response
          emit(
            currentState.copyWith(
              isLiked: likeData['isLiked'] ?? !currentState.isLiked,
              likesCount: likeData['likesCount'] ?? newLikesCount,
              isLiking: false,
            ),
          );
        },
      );
    }
  }

  Future<void> _onToggleRecipeFavorite(
    ToggleRecipeFavorite event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    if (state is RecipeDetailsLoaded) {
      final currentState = state as RecipeDetailsLoaded;
      emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
    }
  }

  Future<void> _onShareRecipe(
    ShareRecipe event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    // Handle recipe sharing logic here
    // This could call a sharing service or update analytics
  }
}
