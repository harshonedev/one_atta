import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepository repository;

  RecipesBloc({required this.repository}) : super(const RecipesInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<CreateRecipe>(_onCreateRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<FilterRecipesByCategory>(_onFilterRecipesByCategory);
    on<SearchRecipes>(_onSearchRecipes);
    on<LoadLikedRecipes>(_onLoadLikedRecipes);
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoading());

    final result = await repository.getAllRecipes();

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (recipes) =>
          emit(RecipesLoaded(recipes: recipes, filteredRecipes: recipes)),
    );
  }

  Future<void> _onLoadRecipeDetails(
    LoadRecipeDetails event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipeDetailsLoading());

    final result = await repository.getRecipeById(event.recipeId);

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (recipe) => emit(RecipeDetailsLoaded(recipe)),
    );
  }

  Future<void> _onCreateRecipe(
    CreateRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipeCreating());

    final result = await repository.createRecipe(event.recipe);

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (recipe) {
        emit(RecipeCreated(recipe));
        // Reload recipes after creation
        add(const LoadRecipes());
      },
    );
  }

  Future<void> _onUpdateRecipe(
    UpdateRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipeUpdating());

    final result = await repository.updateRecipe(event.id, event.recipe);

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (recipe) {
        emit(RecipeUpdated(recipe));
        // Reload recipes after update
        add(const LoadRecipes());
      },
    );
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipeDeleting());

    final result = await repository.deleteRecipe(event.id);

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (recipe) {
        emit(RecipeDeleted(recipe));
        // Reload recipes after deletion
        add(const LoadRecipes());
      },
    );
  }

  Future<void> _onFilterRecipesByCategory(
    FilterRecipesByCategory event,
    Emitter<RecipesState> emit,
  ) async {
    if (state is RecipesLoaded) {
      final currentState = state as RecipesLoaded;
      final allRecipes = currentState.recipes;

      List<RecipeEntity> filteredRecipes;
      if (event.category == 'All') {
        filteredRecipes = allRecipes;
      } else {
        // Filter by blend name or description since we don't have categories
        filteredRecipes = allRecipes
            .where(
              (recipe) =>
                  recipe.blendUsed?.name.toLowerCase().contains(
                        event.category.toLowerCase(),
                      ) ==
                      true ||
                  recipe.description?.toLowerCase().contains(
                        event.category.toLowerCase(),
                      ) ==
                      true,
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredRecipes: filteredRecipes,
          selectedCategory: event.category,
        ),
      );
    }
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    if (state is RecipesLoaded) {
      final currentState = state as RecipesLoaded;
      final allRecipes = currentState.recipes;

      List<RecipeEntity> searchResults;
      if (event.query.isEmpty) {
        // If search is empty, apply category filter if any
        if (currentState.selectedCategory == 'All') {
          searchResults = allRecipes;
        } else {
          searchResults = allRecipes
              .where(
                (recipe) =>
                    recipe.blendUsed?.name.toLowerCase().contains(
                          currentState.selectedCategory.toLowerCase(),
                        ) ==
                        true ||
                    recipe.description?.toLowerCase().contains(
                          currentState.selectedCategory.toLowerCase(),
                        ) ==
                        true,
              )
              .toList();
        }
      } else {
        searchResults = allRecipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ) ||
                  recipe.description?.toLowerCase().contains(
                        event.query.toLowerCase(),
                      ) ==
                      true ||
                  recipe.ingredients.any(
                    (ingredient) => ingredient.name.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ),
                  ),
            )
            .toList();

        // Also apply category filter if not 'All'
        if (currentState.selectedCategory != 'All') {
          searchResults = searchResults
              .where(
                (recipe) =>
                    recipe.blendUsed?.name.toLowerCase().contains(
                          currentState.selectedCategory.toLowerCase(),
                        ) ==
                        true ||
                    recipe.description?.toLowerCase().contains(
                          currentState.selectedCategory.toLowerCase(),
                        ) ==
                        true,
              )
              .toList();
        }
      }

      emit(
        currentState.copyWith(
          filteredRecipes: searchResults,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onLoadLikedRecipes(
    LoadLikedRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const LikedRecipesLoading());

    final result = await repository.getLikedRecipes();

    result.fold(
      (failure) => emit(RecipesError(failure.message, failure: failure)),
      (likedRecipes) => emit(LikedRecipesLoaded(likedRecipes)),
    );
  }
}
