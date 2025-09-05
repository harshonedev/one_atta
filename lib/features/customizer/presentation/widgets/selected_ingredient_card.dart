import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

class WeightOption {
  final int weightInGrams;
  final String label;

  const WeightOption({required this.weightInGrams, required this.label});
}

class SelectedIngredientCard extends StatefulWidget {
  final Ingredient ingredient;
  final int totalWeight;
  final PacketSize packetSize;
  final double totalPercentage;
  final bool isMaxCapacityReached;
  final VoidCallback onRemoved;
  final ValueChanged<double> onPercentageChanged;

  const SelectedIngredientCard({
    super.key,
    required this.ingredient,
    required this.totalWeight,
    required this.packetSize,
    required this.totalPercentage,
    required this.isMaxCapacityReached,
    required this.onRemoved,
    required this.onPercentageChanged,
  });

  @override
  State<SelectedIngredientCard> createState() => _SelectedIngredientCardState();
}

class _SelectedIngredientCardState extends State<SelectedIngredientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _removeAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _removeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _removeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _removeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _removeAnimationController.dispose();
    super.dispose();
  }

  void _handleRemove() {
    _removeAnimationController.forward().then((_) {
      widget.onRemoved();
    });
  }

  int get weightInGrams =>
      (widget.ingredient.percentage * widget.totalWeight).round();

  // Calculate step size for slider based on packet size (100g increments)
  double get stepSize {
    switch (widget.packetSize) {
      case PacketSize.kg1:
        return 0.1; // 10% for 1kg (100g steps)
      case PacketSize.kg3:
        return 0.033; // ~3.33% for 3kg (100g steps)
      case PacketSize.kg5:
        return 0.02; // 2% for 5kg (100g steps)
    }
  }

  // Snap value to nearest step
  double _snapToStep(double value) {
    return (value / stepSize).round() * stepSize;
  }

  // Get weight options based on packet size
  List<WeightOption> get weightOptions {
    switch (widget.packetSize) {
      case PacketSize.kg1:
        return [
          WeightOption(weightInGrams: 200, label: '200g'),
          WeightOption(weightInGrams: 400, label: '400g'),
          WeightOption(weightInGrams: 600, label: '600g'),
          WeightOption(weightInGrams: 800, label: '800g'),
        ];
      case PacketSize.kg3:
        return [
          WeightOption(weightInGrams: 500, label: '500g'),
          WeightOption(weightInGrams: 1000, label: '1Kg'),
          WeightOption(weightInGrams: 1500, label: '1.5Kg'),
          WeightOption(weightInGrams: 2000, label: '2Kg'),
        ];
      case PacketSize.kg5:
        return [
          WeightOption(weightInGrams: 1000, label: '1Kg'),
          WeightOption(weightInGrams: 2000, label: '2Kg'),
          WeightOption(weightInGrams: 3000, label: '3Kg'),
          WeightOption(weightInGrams: 4000, label: '4Kg'),
        ];
    }
  }

  void _setPercentage(double percentage, {bool showSnackbarOnLimit = false}) {
    final snappedValue = _snapToStep(percentage.clamp(0.0, 1.0));
    final currentPercentage = widget.ingredient.percentage;
    final percentageDifference = snappedValue - currentPercentage;
    final newTotalPercentage = widget.totalPercentage + percentageDifference;

    // Use a small tolerance for floating-point comparison (0.001 = 0.1%)
    const tolerance = 0.001;

    // Check if the new percentage would exceed capacity
    if (newTotalPercentage > (1.0 + tolerance) && percentageDifference > 0) {
      if (showSnackbarOnLimit) {
        _showCapacityExceededSnackbar();
      }
      return;
    }

    widget.onPercentageChanged(snappedValue);
  }

  void _showCapacityExceededSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Blend over capacity! Remove ingredients or reduce percentages.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _removeAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 300, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.ingredient.icon,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ingredient.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            Text(
                              '${weightInGrams}g',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(widget.ingredient.percentage * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _handleRemove,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 20,
                          activeTrackColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          thumbShape: SliderComponentShape.noThumb,
                          inactiveTrackColor: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          thumbColor: Theme.of(context).colorScheme.secondary,
                          overlayColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: widget.ingredient.percentage,
                          onChanged: (value) {
                            _setPercentage(value); // No snackbar for slider
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Weight Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: weightOptions
                            .map((option) => _buildWeightOption(option))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightOption(WeightOption option) {
    // Calculate the percentage equivalent for this weight
    final targetPercentage = option.weightInGrams / widget.totalWeight;
    final isSelected =
        (widget.ingredient.percentage - targetPercentage).abs() < 0.01;
    final currentPercentage = widget.ingredient.percentage;
    final percentageDifference = targetPercentage - currentPercentage;
    final newTotalPercentage = widget.totalPercentage + percentageDifference;

    // Use same tolerance as in _setPercentage method
    const tolerance = 0.001;
    final wouldExceedCapacity =
        newTotalPercentage > (1.0 + tolerance) && percentageDifference > 0;

    return GestureDetector(
      onTap: wouldExceedCapacity
          ? () => _setPercentage(targetPercentage, showSnackbarOnLimit: true)
          : () => _setPercentage(targetPercentage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: wouldExceedCapacity
              ? Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: wouldExceedCapacity
                ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                : isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          option.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: wouldExceedCapacity
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
