import 'package:equatable/equatable.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final UserEntity? user;
  final List<PublicBlendEntity> trendingBlends;
  final List<RecipeEntity> featuredRecipes;
  final List<BlendItem> readyToSellBlends;
  final bool isRefreshing;

  const HomeLoaded({
    this.user,
    required this.trendingBlends,
    required this.featuredRecipes,
    required this.readyToSellBlends,
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    UserEntity? user,
    List<PublicBlendEntity>? trendingBlends,
    List<RecipeEntity>? featuredRecipes,
    List<BlendItem>? readyToSellBlends,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      trendingBlends: trendingBlends ?? this.trendingBlends,
      featuredRecipes: featuredRecipes ?? this.featuredRecipes,
      readyToSellBlends: readyToSellBlends ?? this.readyToSellBlends,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    user,
    trendingBlends,
    featuredRecipes,
    readyToSellBlends,
    isRefreshing,
  ];
}

class HomePartialLoading extends HomeState {
  final UserEntity? user;
  final List<PublicBlendEntity> trendingBlends;
  final List<RecipeEntity> featuredRecipes;
  final List<BlendItem> readyToSellBlends;
  final bool isLoadingBlends;
  final bool isLoadingRecipes;
  final bool isLoadingUser;

  const HomePartialLoading({
    this.user,
    required this.trendingBlends,
    required this.featuredRecipes,
    required this.readyToSellBlends,
    this.isLoadingBlends = false,
    this.isLoadingRecipes = false,
    this.isLoadingUser = false,
  });

  @override
  List<Object?> get props => [
    user,
    trendingBlends,
    featuredRecipes,
    readyToSellBlends,
    isLoadingBlends,
    isLoadingRecipes,
    isLoadingUser,
  ];
}

class HomeError extends HomeState {
  final String message;
  final UserEntity? user;
  final List<PublicBlendEntity> trendingBlends;
  final List<RecipeEntity> featuredRecipes;
  final List<BlendItem> readyToSellBlends;

  const HomeError({
    required this.message,
    this.user,
    this.trendingBlends = const [],
    this.featuredRecipes = const [],
    this.readyToSellBlends = const [],
  });

  @override
  List<Object?> get props => [
    message,
    user,
    trendingBlends,
    featuredRecipes,
    readyToSellBlends,
  ];
}

class HomeSearchResult extends HomeState {
  final String query;
  final List<PublicBlendEntity> searchResults;
  final bool isLoading;

  const HomeSearchResult({
    required this.query,
    required this.searchResults,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [query, searchResults, isLoading];
}
