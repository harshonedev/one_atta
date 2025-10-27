import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/widgets/ingredient_card.dart';

class AvailableIngredientsSection extends StatelessWidget {
  final List<Ingredient> availableIngredients;
  final List<Ingredient> selectedIngredients;
  final bool isMaxCapacityReached;
  final ValueChanged<Ingredient> onIngredientAdded;
  final ValueChanged<Ingredient> onIngredientRemoved;
  final ScrollController? scrollController;

  const AvailableIngredientsSection({
    super.key,
    required this.availableIngredients,
    required this.selectedIngredients,
    required this.isMaxCapacityReached,
    required this.onIngredientRemoved,
    required this.onIngredientAdded,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (availableIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120, // Increased height for larger cards
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: availableIngredientsSorted.length,
        itemBuilder: (context, index) {
          final ingredient = availableIngredientsSorted[index];
          return IngredientCard(
            ingredient: ingredient,
            isSelected: isIngredientSelected(ingredient.name),
            onTap: () {
              // Always try to add with the default percentage
              // The BLoC will handle capacity checks and adjustments
              // if is already selected, do nothing
              if (selectedIngredients.any(
                (ing) => ing.name == ingredient.name,
              )) {
                if (ingredient.name.toLowerCase() != 'wheat') {
                  onIngredientRemoved(ingredient);
                }
                return;
              }
              onIngredientAdded(ingredient.copyWith(percentage: 0.1));
            },
          );
        },
      ),
    );
  }

  bool isIngredientSelected(String ingredientName) {
    return selectedIngredients.any(
      (ingredient) => ingredient.name == ingredientName,
    );
  }

  List<Ingredient> get availableIngredientsSorted {
    // by selected one comes first
    // wheat should always be first if selected
    final selectedNames = selectedIngredients.map((e) => e.name).toSet();
    final wheatIngredient = selectedIngredients
        .where((ingredient) => ingredient.name.toLowerCase() == 'wheat')
        .first;
    final selected = availableIngredients
        .where(
          (ingredient) =>
              selectedNames.contains(ingredient.name) &&
              ingredient.name.toLowerCase() != 'wheat',
        )
        .toList();
    final unselected = availableIngredients
        .where((ingredient) => !selectedNames.contains(ingredient.name))
        .toList();
    return [wheatIngredient, ...selected, ...unselected];
  }
}
