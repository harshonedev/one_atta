import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BlendsRepository blendsRepository;
  final RecipesRepository recipesRepository;
  final AuthRepository authRepository;

  HomeBloc({
    required this.blendsRepository,
    required this.recipesRepository,
    required this.authRepository,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<SearchBlends>(_onSearchBlends);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<LoadTrendingBlends>(_onLoadTrendingBlends);
    on<LoadFeaturedRecipes>(_onLoadFeaturedRecipes);
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _loadUserProfile(),
        _loadTrendingBlends(),
        _loadFeaturedRecipes(),
      ]);

      final user = results[0] as UserEntity?;
      final trendingBlends = results[1] as List<PublicBlendEntity>;
      final featuredRecipes = results[2] as List<RecipeEntity>;

      // Generate ready-to-sell blends (static for now)
      final readyToSellBlends = _getReadyToSellBlends();

      emit(
        HomeLoaded(
          user: user,
          trendingBlends: trendingBlends,
          featuredRecipes: featuredRecipes,
          readyToSellBlends: readyToSellBlends,
        ),
      );
    } catch (e) {
      emit(
        HomeError(
          message: 'Failed to load home data: ${e.toString()}',
          readyToSellBlends: _getReadyToSellBlends(),
        ),
      );
    }
  }

  Future<void> _onSearchBlends(
    SearchBlends event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      HomeSearchResult(query: event.query, searchResults: [], isLoading: true),
    );

    try {
      final result = await blendsRepository.getAllPublicBlends();

      result.fold(
        (failure) =>
            emit(HomeError(message: 'Search failed: ${failure.message}')),
        (blends) {
          // Filter blends based on search query
          final filteredBlends = blends
              .where(
                (blend) =>
                    blend.name.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ||
                    blend.additives.any(
                      (additive) => additive.ingredient.toLowerCase().contains(
                        event.query.toLowerCase(),
                      ),
                    ),
              )
              .toList();

          emit(
            HomeSearchResult(query: event.query, searchResults: filteredBlends),
          );
        },
      );
    } catch (e) {
      emit(HomeError(message: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isRefreshing: true));

      try {
        final results = await Future.wait([
          _loadUserProfile(),
          _loadTrendingBlends(),
          _loadFeaturedRecipes(),
        ]);

        final user = results[0] as UserEntity?;
        final trendingBlends = results[1] as List<PublicBlendEntity>;
        final featuredRecipes = results[2] as List<RecipeEntity>;

        emit(
          currentState.copyWith(
            user: user,
            trendingBlends: trendingBlends,
            featuredRecipes: featuredRecipes,
            isRefreshing: false,
          ),
        );
      } catch (e) {
        emit(
          HomeError(
            message: 'Failed to refresh data: ${e.toString()}',
            user: currentState.user,
            trendingBlends: currentState.trendingBlends,
            featuredRecipes: currentState.featuredRecipes,
            readyToSellBlends: currentState.readyToSellBlends,
          ),
        );
      }
    } else {
      // If not in loaded state, perform a full reload
      add(const LoadHomeData());
    }
  }

  Future<void> _onLoadTrendingBlends(
    LoadTrendingBlends event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(
        HomePartialLoading(
          user: currentState.user,
          trendingBlends: currentState.trendingBlends,
          featuredRecipes: currentState.featuredRecipes,
          readyToSellBlends: currentState.readyToSellBlends,
          isLoadingBlends: true,
        ),
      );

      try {
        final blends = await _loadTrendingBlends();
        emit(currentState.copyWith(trendingBlends: blends));
      } catch (e) {
        emit(
          HomeError(
            message: 'Failed to load trending blends: ${e.toString()}',
            user: currentState.user,
            trendingBlends: currentState.trendingBlends,
            featuredRecipes: currentState.featuredRecipes,
            readyToSellBlends: currentState.readyToSellBlends,
          ),
        );
      }
    }
  }

  Future<void> _onLoadFeaturedRecipes(
    LoadFeaturedRecipes event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(
        HomePartialLoading(
          user: currentState.user,
          trendingBlends: currentState.trendingBlends,
          featuredRecipes: currentState.featuredRecipes,
          readyToSellBlends: currentState.readyToSellBlends,
          isLoadingRecipes: true,
        ),
      );

      try {
        final recipes = await _loadFeaturedRecipes();
        emit(currentState.copyWith(featuredRecipes: recipes));
      } catch (e) {
        emit(
          HomeError(
            message: 'Failed to load featured recipes: ${e.toString()}',
            user: currentState.user,
            trendingBlends: currentState.trendingBlends,
            featuredRecipes: currentState.featuredRecipes,
            readyToSellBlends: currentState.readyToSellBlends,
          ),
        );
      }
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(
        HomePartialLoading(
          user: currentState.user,
          trendingBlends: currentState.trendingBlends,
          featuredRecipes: currentState.featuredRecipes,
          readyToSellBlends: currentState.readyToSellBlends,
          isLoadingUser: true,
        ),
      );

      try {
        final user = await _loadUserProfile();
        emit(currentState.copyWith(user: user));
      } catch (e) {
        emit(
          HomeError(
            message: 'Failed to load user profile: ${e.toString()}',
            user: currentState.user,
            trendingBlends: currentState.trendingBlends,
            featuredRecipes: currentState.featuredRecipes,
            readyToSellBlends: currentState.readyToSellBlends,
          ),
        );
      }
    }
  }

  // Helper methods for loading data
  Future<UserEntity?> _loadUserProfile() async {
    final result = await authRepository.getCurrentUser();
    return result.fold((failure) => null, (user) => user);
  }

  Future<List<PublicBlendEntity>> _loadTrendingBlends() async {
    final result = await blendsRepository.getAllPublicBlends();
    return result.fold((failure) => <PublicBlendEntity>[], (blends) {
      // Sort by popularity and take top trending ones
      final sortedBlends = List<PublicBlendEntity>.from(blends);
      sortedBlends.sort((a, b) => b.shareCount.compareTo(a.shareCount));
      return sortedBlends.take(6).toList();
    });
  }

  Future<List<RecipeEntity>> _loadFeaturedRecipes() async {
    final result = await recipesRepository.getAllRecipes();
    return result.fold((failure) => <RecipeEntity>[], (recipes) {
      // Sort by likes and take featured ones
      final sortedRecipes = List<RecipeEntity>.from(recipes);
      sortedRecipes.sort((a, b) => b.likes.compareTo(a.likes));
      return sortedRecipes.take(4).toList();
    });
  }

  List<BlendItem> _getReadyToSellBlends() {
    return [
      const BlendItem(
        id: 'ready_1',
        name: 'Atta (Classic Wheat)',
        description:
            'Traditional whole wheat flour blend perfect for daily use',
        imageUrl: AppAssets.attaImage,
        category: 'Classic',
        pricePerKg: 50.0,
        tags: ['Traditional', 'Whole Wheat', 'Daily Use'],
      ),
      const BlendItem(
        id: 'ready_2',
        name: 'Bedmi',
        description: 'Special spiced flour blend for authentic bedmi puri',
        imageUrl: AppAssets.bedmiImage,
        category: 'Special',
        pricePerKg: 70.0,
        tags: ['Spiced', 'Traditional', 'Authentic'],
      ),
      const BlendItem(
        id: 'ready_3',
        name: 'Missi',
        description: 'Mixed gram and wheat flour blend rich in protein',
        imageUrl: AppAssets.missiImage,
        category: 'Protein',
        pricePerKg: 80.0,
        tags: ['Gram', 'Wheat', 'High Protein'],
      ),
    ];
  }
}

class BlendItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> tags;
  final double pricePerKg;

  const BlendItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.tags,
    required this.pricePerKg,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        category,
        tags,
        pricePerKg,
      ];
}
