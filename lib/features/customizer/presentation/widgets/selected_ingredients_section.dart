import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/widgets/selected_ingredient_card.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

class SelectedIngredientsSection extends StatefulWidget {
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
  State<SelectedIngredientsSection> createState() =>
      _SelectedIngredientsSectionState();
}

class _SelectedIngredientsSectionState
    extends State<SelectedIngredientsSection> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Ingredient> _currentIngredients;

  @override
  void initState() {
    super.initState();
    _currentIngredients = List.from(widget.selectedIngredients);
  }

  @override
  void didUpdateWidget(SelectedIngredientsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList(oldWidget.selectedIngredients, widget.selectedIngredients);
  }

  void _updateList(List<Ingredient> oldList, List<Ingredient> newList) {
    // Handle removals
    for (int i = oldList.length - 1; i >= 0; i--) {
      final ingredient = oldList[i];
      if (!newList.any((item) => item.name == ingredient.name)) {
        _currentIngredients.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(ingredient, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Handle additions
    for (int i = 0; i < newList.length; i++) {
      final ingredient = newList[i];
      if (!oldList.any((item) => item.name == ingredient.name)) {
        _currentIngredients.insert(i, ingredient);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Update percentages for existing items
    setState(() {
      for (int i = 0; i < _currentIngredients.length; i++) {
        final currentIngredient = _currentIngredients[i];
        final newIngredient = newList.firstWhere(
          (item) => item.name == currentIngredient.name,
          orElse: () => currentIngredient,
        );
        if (currentIngredient.percentage != newIngredient.percentage) {
          _currentIngredients[i] = newIngredient;
        }
      }
    });
  }

  Widget _buildRemovedItem(Ingredient ingredient, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: SelectedIngredientCard(
            ingredient: ingredient,
            totalWeight: widget.totalWeight,
            packetSize: widget.packetSize,
            totalPercentage: widget.totalPercentage,
            isMaxCapacityReached: widget.isMaxCapacityReached,
            onRemoved: () {},
            onPercentageChanged: (value) {},
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    if (index >= _currentIngredients.length) return const SizedBox.shrink();

    final ingredient = _currentIngredients[index];
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: SelectedIngredientCard(
            ingredient: ingredient,
            totalWeight: widget.totalWeight,
            packetSize: widget.packetSize,
            totalPercentage: widget.totalPercentage,
            isMaxCapacityReached: widget.isMaxCapacityReached,
            onRemoved: () => widget.onIngredientRemoved(ingredient),
            onPercentageChanged: (value) =>
                widget.onPercentageChanged(ingredient, value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _currentIngredients.length,
      itemBuilder: _buildItem,
    );
  }
}
