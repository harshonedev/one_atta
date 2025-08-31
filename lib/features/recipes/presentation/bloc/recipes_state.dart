import 'package:equatable/equatable.dart';
import '../../data/models/recipe.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  final List<Recipe> featuredRecipes;
  final List<CommunityMember> communityMembers;
  final String selectedCategory;
  final String searchQuery;

  const RecipesLoaded({
    required this.recipes,
    required this.featuredRecipes,
    required this.communityMembers,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  RecipesLoaded copyWith({
    List<Recipe>? recipes,
    List<Recipe>? featuredRecipes,
    List<CommunityMember>? communityMembers,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return RecipesLoaded(
      recipes: recipes ?? this.recipes,
      featuredRecipes: featuredRecipes ?? this.featuredRecipes,
      communityMembers: communityMembers ?? this.communityMembers,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    recipes,
    featuredRecipes,
    communityMembers,
    selectedCategory,
    searchQuery,
  ];
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError(this.message);

  @override
  List<Object?> get props => [message];
}
