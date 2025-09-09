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
              if (!isMaxCapacityReached) {
                onIngredientAdded(
                  Ingredient(
                    name: ingredient.name,
                    percentage: 0.1, // Start with 10%
                    icon: ingredient.icon,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Maximum capacity reached. Remove some ingredients to add more.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
