import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/recipe.dart';
import 'recipe_details_event.dart';
import 'recipe_details_state.dart';

class RecipeDetailsBloc extends Bloc<RecipeDetailsEvent, RecipeDetailsState> {
  RecipeDetailsBloc() : super(const RecipeDetailsInitial()) {
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<ToggleRecipeFavorite>(_onToggleRecipeFavorite);
    on<ShareRecipe>(_onShareRecipe);
  }

  Future<void> _onLoadRecipeDetails(
    LoadRecipeDetails event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    emit(const RecipeDetailsLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Get recipe from dummy data - in real app this would come from API/repository
      final recipe = _getDummyRecipeById(event.recipeId);

      if (recipe != null) {
        emit(RecipeDetailsLoaded(recipe: recipe));
      } else {
        emit(const RecipeDetailsError('Recipe not found'));
      }
    } catch (e) {
      emit(RecipeDetailsError('Failed to load recipe details: $e'));
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
    // This could trigger a share dialog or copy link to clipboard
  }

  Recipe? _getDummyRecipeById(String id) {
    final recipes = _getDummyRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Recipe> _getDummyRecipes() {
    return [
      Recipe(
        id: '1',
        title: 'Gluten-Free Pancakes',
        description:
            'Start your day with fluffy, gluten-free pancakes made with our special blend.',
        imageUrl:
            'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=800&h=600&fit=crop',
        prepTime: 30,
        rating: 4.5,
        difficulty: 'Easy',
        categories: ['Breakfast', 'All'],
        isFeatured: true,
        ingredients: [
          Ingredient(name: 'Gluten-Free Blend', quantity: '2 cups'),
          Ingredient(name: 'Mashed ripe bananas', quantity: '1 cup'),
          Ingredient(name: 'Sugar', quantity: '1/2 cup'),
          Ingredient(name: 'Melted butter', quantity: '1/4 cup'),
          Ingredient(name: 'Eggs', quantity: '2'),
          Ingredient(name: 'Baking soda', quantity: '1 tsp'),
          Ingredient(name: 'Salt', quantity: '1/2 tsp'),
          Ingredient(name: 'Chopped walnuts (optional)', quantity: '1/2 cup'),
        ],
        instructions: [
          'Preheat oven to 350°F (175°C). Grease a loaf pan.',
          'In a large bowl, combine Gluten-Free Blend, sugar, baking soda, and salt.',
          'In another bowl, whisk together mashed bananas, melted butter, and eggs.',
          'Add wet ingredients to dry ingredients and mix until just combined. Stir in walnuts, if using.',
          'Pour batter into prepared pan and bake for 50-60 minutes, or until a toothpick inserted into the center comes out clean.',
        ],
        nutrition: Nutrition(calories: 250, protein: 5, carbs: 40, fat: 10),
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      ),
      Recipe(
        id: '2',
        title: 'High-Protein Pizza',
        description:
            'Enjoy a healthier pizza with a protein-packed crust, perfect for a guilt-free meal.',
        imageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&h=600&fit=crop',
        prepTime: 45,
        rating: 4.2,
        difficulty: 'Medium',
        categories: ['Lunch', 'Dinner', 'All'],
        isFeatured: true,
        ingredients: [
          Ingredient(name: 'High-Protein Flour Mix', quantity: '2 cups'),
          Ingredient(name: 'Warm water', quantity: '3/4 cup'),
          Ingredient(name: 'Olive oil', quantity: '2 tbsp'),
          Ingredient(name: 'Salt', quantity: '1 tsp'),
          Ingredient(name: 'Pizza sauce', quantity: '1/2 cup'),
          Ingredient(name: 'Mozzarella cheese', quantity: '1 cup'),
          Ingredient(name: 'Fresh basil', quantity: '1/4 cup'),
          Ingredient(name: 'Cherry tomatoes', quantity: '1/2 cup'),
        ],
        instructions: [
          'Mix flour, salt, and warm water to form a dough. Let it rest for 30 minutes.',
          'Roll out the dough on a floured surface.',
          'Brush with olive oil and spread pizza sauce evenly.',
          'Top with cheese, tomatoes, and basil.',
          'Bake at 425°F (220°C) for 12-15 minutes until crust is golden.',
        ],
        nutrition: Nutrition(calories: 320, protein: 18, carbs: 35, fat: 12),
      ),
      Recipe(
        id: '3',
        title: 'Quinoa Energy Balls',
        description:
            'Perfect snack for busy days, packed with nutrients and natural energy.',
        imageUrl:
            'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=800&h=600&fit=crop',
        prepTime: 15,
        rating: 4.8,
        difficulty: 'Easy',
        categories: ['Snacks', 'All'],
        isFeatured: false,
        ingredients: [
          Ingredient(name: 'Cooked quinoa', quantity: '1 cup'),
          Ingredient(name: 'Peanut butter', quantity: '1/2 cup'),
          Ingredient(name: 'Honey', quantity: '1/4 cup'),
          Ingredient(name: 'Chia seeds', quantity: '2 tbsp'),
          Ingredient(name: 'Dark chocolate chips', quantity: '1/4 cup'),
        ],
        instructions: [
          'Mix all ingredients in a large bowl.',
          'Roll mixture into small balls using your hands.',
          'Refrigerate for at least 30 minutes before serving.',
          'Store in refrigerator for up to one week.',
        ],
        nutrition: Nutrition(calories: 150, protein: 6, carbs: 15, fat: 8),
      ),
      Recipe(
        id: '4',
        title: 'Gluten-Free Banana Bread',
        description:
            'This recipe uses our Gluten-Free Blend for a moist and delicious banana bread.',
        imageUrl:
            'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800&h=600&fit=crop',
        prepTime: 60,
        rating: 4.6,
        difficulty: 'Easy',
        categories: ['Breakfast', 'Snacks', 'All'],
        isFeatured: false,
        ingredients: [
          Ingredient(name: 'Gluten-Free Blend', quantity: '2 cups'),
          Ingredient(name: 'Mashed ripe bananas', quantity: '1 cup'),
          Ingredient(name: 'Sugar', quantity: '1/2 cup'),
          Ingredient(name: 'Melted butter', quantity: '1/4 cup'),
          Ingredient(name: 'Eggs', quantity: '2'),
          Ingredient(name: 'Baking soda', quantity: '1 tsp'),
          Ingredient(name: 'Salt', quantity: '1/2 tsp'),
          Ingredient(name: 'Chopped walnuts (optional)', quantity: '1/2 cup'),
        ],
        instructions: [
          'Preheat oven to 350°F (175°C). Grease a loaf pan.',
          'In a large bowl, combine Gluten-Free Blend, sugar, baking soda, and salt.',
          'In another bowl, whisk together mashed bananas, melted butter, and eggs.',
          'Add wet ingredients to dry ingredients and mix until just combined. Stir in walnuts, if using.',
          'Pour batter into prepared pan and bake for 50-60 minutes, or until a toothpick inserted into the center comes out clean.',
        ],
        nutrition: Nutrition(calories: 220, protein: 4, carbs: 38, fat: 8),
      ),
      Recipe(
        id: '5',
        title: 'Protein-Rich Smoothie Bowl',
        description:
            'A nutritious breakfast bowl that will keep you energized all morning.',
        imageUrl:
            'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=800&h=600&fit=crop',
        prepTime: 10,
        rating: 4.4,
        difficulty: 'Easy',
        categories: ['Breakfast', 'All'],
        isFeatured: false,
        ingredients: [
          Ingredient(name: 'Protein powder', quantity: '1 scoop'),
          Ingredient(name: 'Frozen berries', quantity: '1 cup'),
          Ingredient(name: 'Banana', quantity: '1'),
          Ingredient(name: 'Almond milk', quantity: '1/2 cup'),
          Ingredient(name: 'Granola', quantity: '1/4 cup'),
          Ingredient(name: 'Fresh fruits', quantity: 'for topping'),
        ],
        instructions: [
          'Blend protein powder, frozen berries, banana, and almond milk until smooth.',
          'Pour into a bowl.',
          'Top with granola and fresh fruits.',
          'Serve immediately.',
        ],
        nutrition: Nutrition(calories: 280, protein: 20, carbs: 35, fat: 6),
      ),
      Recipe(
        id: '6',
        title: 'Healthy Pasta Salad',
        description:
            'A light and refreshing pasta salad perfect for lunch or dinner.',
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc353d946?w=800&h=600&fit=crop',
        prepTime: 25,
        rating: 4.3,
        difficulty: 'Easy',
        categories: ['Lunch', 'Dinner', 'All'],
        isFeatured: false,
        ingredients: [
          Ingredient(name: 'Whole wheat pasta', quantity: '2 cups'),
          Ingredient(name: 'Cherry tomatoes', quantity: '1 cup'),
          Ingredient(name: 'Cucumber', quantity: '1'),
          Ingredient(name: 'Red onion', quantity: '1/4 cup'),
          Ingredient(name: 'Feta cheese', quantity: '1/2 cup'),
          Ingredient(name: 'Olive oil', quantity: '3 tbsp'),
          Ingredient(name: 'Lemon juice', quantity: '2 tbsp'),
        ],
        instructions: [
          'Cook pasta according to package instructions and let cool.',
          'Chop vegetables and mix with pasta.',
          'Whisk olive oil and lemon juice for dressing.',
          'Toss everything together and add feta cheese.',
          'Chill for 30 minutes before serving.',
        ],
        nutrition: Nutrition(calories: 340, protein: 12, carbs: 45, fat: 14),
      ),
    ];
  }
}
