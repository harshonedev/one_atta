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
  }

  Future<void> _onLoadRecipeDetails(
    LoadRecipeDetails event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    emit(const RecipeDetailsLoading());

    final result = await repository.getRecipeById(event.recipeId);

    result.fold(
      (failure) => emit(RecipeDetailsError(failure.message)),
      (recipe) => emit(RecipeDetailsLoaded(recipe: recipe)),
    );
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
