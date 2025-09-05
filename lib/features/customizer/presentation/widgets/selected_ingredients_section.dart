import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/widgets/selected_ingredient_card.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

class SelectedIngredientsSection extends StatelessWidget {
  final List<Ingredient> selectedIngredients;
  final int totalWeight;
  final PacketSize packetSize;
  final double totalPercentage;
  final bool isMaxCapacityReached;
  final ValueChanged<Ingredient> onIngredientRemoved;
  final Function(Ingredient, double) onPercentageChanged;

  const SelectedIngredientsSection({
    super.key,
    required this.selectedIngredients,
    required this.totalWeight,
    required this.packetSize,
    required this.totalPercentage,
    required this.isMaxCapacityReached,
    required this.onIngredientRemoved,
    required this.onPercentageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: selectedIngredients
          .map(
            (ingredient) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SelectedIngredientCard(
                ingredient: ingredient,
                totalWeight: totalWeight,
                packetSize: packetSize,
                totalPercentage: totalPercentage,
                isMaxCapacityReached: isMaxCapacityReached,
                onRemoved: () => onIngredientRemoved(ingredient),
                onPercentageChanged: (value) =>
                    onPercentageChanged(ingredient, value),
              ),
            ),
          )
          .toList(),
    );
  }
}
