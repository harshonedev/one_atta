import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipes extends RecipesEvent {
  const LoadRecipes();
}

class FilterRecipesByCategory extends RecipesEvent {
  final String category;

  const FilterRecipesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchRecipes extends RecipesEvent {
  final String query;

  const SearchRecipes(this.query);

  @override
  List<Object?> get props => [query];
}
