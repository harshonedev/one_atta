import 'package:flutter_test/flutter_test.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_state.dart';

void main() {
  group('Recipe Like Functionality Tests', () {
    test('RecipeDetailsLoaded state should handle like status correctly', () {
      final testDate = DateTime.now();

      // Test initial state
      final initialState = RecipeDetailsLoaded(
        recipe: RecipeEntity(
          id: '1',
          title: 'Test Recipe',
          ingredients: const [],
          steps: const [],
          likes: 10,
          createdAt: testDate,
          updatedAt: testDate,
        ),
        likesCount: 10,
        isLiked: false,
        isLiking: false,
      );

      expect(initialState.isLiked, false);
      expect(initialState.likesCount, 10);
      expect(initialState.isLiking, false);

      // Test liked state
      final likedState = initialState.copyWith(isLiked: true, likesCount: 11);

      expect(likedState.isLiked, true);
      expect(likedState.likesCount, 11);
      expect(likedState.isLiking, false);

      // Test liking state
      final likingState = initialState.copyWith(isLiking: true);

      expect(likingState.isLiking, true);
    });

    test('Like count should update optimistically', () {
      final testDate = DateTime.now();

      final initialState = RecipeDetailsLoaded(
        recipe: RecipeEntity(
          id: '1',
          title: 'Test Recipe',
          ingredients: const [],
          steps: const [],
          likes: 10,
          createdAt: testDate,
          updatedAt: testDate,
        ),
        likesCount: 10,
        isLiked: false,
        isLiking: false,
      );

      // Simulate optimistic like
      final optimisticLikeState = initialState.copyWith(
        isLiked: true,
        likesCount: initialState.likesCount + 1,
        isLiking: true,
      );

      expect(optimisticLikeState.isLiked, true);
      expect(optimisticLikeState.likesCount, 11);
      expect(optimisticLikeState.isLiking, true);

      // Simulate completed like
      final completedLikeState = optimisticLikeState.copyWith(isLiking: false);

      expect(completedLikeState.isLiked, true);
      expect(completedLikeState.likesCount, 11);
      expect(completedLikeState.isLiking, false);
    });

    test('Like status should revert on error', () {
      final testDate = DateTime.now();

      final likedState = RecipeDetailsLoaded(
        recipe: RecipeEntity(
          id: '1',
          title: 'Test Recipe',
          ingredients: const [],
          steps: const [],
          likes: 11,
          createdAt: testDate,
          updatedAt: testDate,
        ),
        likesCount: 11,
        isLiked: true,
        isLiking: false,
      );

      // Simulate error - revert to original state
      final revertedState = likedState.copyWith(
        isLiked: false,
        likesCount: 10,
        isLiking: false,
      );

      expect(revertedState.isLiked, false);
      expect(revertedState.likesCount, 10);
      expect(revertedState.isLiking, false);
    });
  });
}
