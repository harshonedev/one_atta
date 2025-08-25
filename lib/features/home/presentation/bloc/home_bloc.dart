import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'home_models.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<SearchBlends>(_onSearchBlends);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final userProfile = const UserProfile(name: 'Priya', grainPoints: 245);

      final readyToSellBlends = [
        const BlendItem(
          id: '1',
          name: 'Atta (Classic Wheat)',
          description: 'Traditional whole wheat flour blend',
          imageUrl: AppAssets.attaImage,
          rating: 4.8,
          category: 'Classic',
          tags: ['Traditional', 'Whole Wheat'],
        ),
        const BlendItem(
          id: '2',
          name: 'Bedmi',
          description: 'Special spiced flour blend for bedmi puri',
          imageUrl: AppAssets.bedmiImage,
          rating: 4.6,
          category: 'Special',
          tags: ['Spiced', 'Traditional'],
        ),
        const BlendItem(
          id: '3',
          name: 'Missi',
          description: 'Mixed gram and wheat flour blend',
          imageUrl: AppAssets.missiImage,
          rating: 4.7,
          category: 'Mixed',
          tags: ['Gram', 'Wheat', 'Protein'],
        ),
      ];

      final trendingBlends = [
        const BlendItem(
          id: '4',
          name: 'Multigrain Protein',
          description: '7 grains blend',
          imageUrl: AppAssets.multigrainImage,
          rating: 4.8,
          category: 'Protein',
          tags: ['Protein', 'Multigrain'],
        ),
        const BlendItem(
          id: '5',
          name: 'Ragi Superfood',
          description: 'Fiber-rich mix',
          imageUrl: AppAssets.ragiImage,
          rating: 4.7,
          category: 'Superfood',
          tags: ['Fiber', 'Healthy'],
        ),
        const BlendItem(
          id: '6',
          name: 'Brown Rice',
          description: 'Classic texture',
          imageUrl: AppAssets.brownRiceImage,
          rating: 4.5,
          category: 'Classic',
          tags: ['Rice', 'Healthy'],
        ),
      ];

      final recipes = [
        const RecipeItem(
          id: '1',
          name: 'Perfect Soft Rotis',
          description: 'Learn to make perfect soft rotis',
          imageUrl: AppAssets.recipeImage1,
          cookingTime: 20,
          difficulty: 'Easy',
          rating: 4.9,
          reviewCount: 342,
          tags: ['Heart-Healthy'],
        ),
        const RecipeItem(
          id: '2',
          name: 'Veggie Multigrain Paratha',
          description: 'Healthy vegetable paratha recipe',
          imageUrl: AppAssets.recipeImage2,
          cookingTime: 35,
          difficulty: 'Medium',
          rating: 4.7,
          reviewCount: 216,
          tags: ['Vegetables', 'Multigrain'],
        ),
      ];

      emit(
        HomeLoaded(
          userProfile: userProfile,
          readyToSellBlends: readyToSellBlends,
          trendingBlends: trendingBlends,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data: ${e.toString()}'));
    }
  }

  Future<void> _onSearchBlends(
    SearchBlends event,
    Emitter<HomeState> emit,
  ) async {
    // Implementation for search functionality
    // For now, just reload data
    add(const LoadHomeData());
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    add(const LoadHomeData());
  }
}
