import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';
import 'recipe_details_event.dart';
import 'recipe_details_state.dart';

class RecipeDetailsBloc extends Bloc<RecipeDetailsEvent, RecipeDetailsState> {
  final RecipesRepository repository;
  final Logger logger = Logger();

  RecipeDetailsBloc({required this.repository})
    : super(const RecipeDetailsInitial()) {
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<LikeRecipe>(_onLikeRecipe);
    on<LoadLikedRecipes>(_onLoadLikedRecipes);
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

    add(const LoadLikedRecipes());
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
          isLiking: false,
        ),
      );

      // Sync with remote database
      final result = await repository.toggleRecipeLike(event.recipeId);

      result.fold(
        (failure) {
          logger.e('Error liking recipe: ${failure.message}');
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

  Future<void> _onLoadLikedRecipes(
    LoadLikedRecipes event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    try {
      final result = await repository.getLikedRecipes();
      result.fold(
        (failure) {
          logger.e('Error loading liked recipes: ${failure.message}');
          // Nothing to emit here as per the requirement
        },
        (likedRecipes) {
          // Handle the loaded liked recipes if needed
          logger.i('Loaded ${likedRecipes.length} liked recipes');
          // check current recipe is in likedRecipes
          if (state is RecipeDetailsLoaded) {
            final currentState = state as RecipeDetailsLoaded;
            final isLiked = likedRecipes.any(
              (recipe) => recipe.id == currentState.recipe.id,
            );
            emit(currentState.copyWith(isLiked: isLiked));
          }
        },
      );
    } catch (e) {
      logger.e('Error loading liked recipes: $e');
      // Nothing to emit here as per the requirement
    }
  }
}
