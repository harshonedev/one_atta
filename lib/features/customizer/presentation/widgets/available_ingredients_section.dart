import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/widgets/ingredient_card.dart';

class AvailableIngredientsSection extends StatelessWidget {
  final List<Ingredient> availableIngredients;
  final List<Ingredient> selectedIngredients;
  final bool isMaxCapacityReached;
  final ValueChanged<Ingredient> onIngredientAdded;
  final ScrollController? scrollController;

  const AvailableIngredientsSection({
    super.key,
    required this.availableIngredients,
    required this.selectedIngredients,
    required this.isMaxCapacityReached,
    required this.onIngredientAdded,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out already selected ingredients (Wheat now can be removed/added like others)
    final unselectedIngredients = availableIngredients
        .where(
          (ingredient) => !selectedIngredients.any(
            (selected) => selected.name == ingredient.name,
          ),
        )
        .toList();

    if (unselectedIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120, // Increased height for larger cards
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: unselectedIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = unselectedIngredients[index];
          return IngredientCard(
            ingredient: ingredient,
            isSelected: false,
            onTap: () {
              // Always try to add with the default percentage
              // The BLoC will handle capacity checks and adjustments
              onIngredientAdded(ingredient.copyWith(percentage: 0.1));
            },
          );
        },
      ),
    );
  }
}
