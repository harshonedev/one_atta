import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/presentation/widgets/ingredient_details_popup.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

class WeightOption {
  final int weightInGrams;
  final String label;

  const WeightOption({required this.weightInGrams, required this.label});
}

class SelectedIngredientCard extends StatelessWidget {
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

  int get weightInGrams => (ingredient.percentage * totalWeight).round();

  // Calculate step size for slider based on packet size (100g increments)
  double get stepSize {
    switch (packetSize) {
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
    switch (packetSize) {
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

  void _setPercentage(
    BuildContext context,
    double percentage, {
    bool showSnackbarOnLimit = false,
  }) {
    final snappedValue = _snapToStep(percentage.clamp(0.0, 1.0));
    final currentPercentage = ingredient.percentage;
    final percentageDifference = snappedValue - currentPercentage;
    final newTotalPercentage = totalPercentage + percentageDifference;

    // Use a small tolerance for floating-point comparison (0.001 = 0.1%)
    const tolerance = 0.001;

    // Check if the new percentage would exceed capacity
    if (newTotalPercentage > (1.0 + tolerance) && percentageDifference > 0) {
      if (showSnackbarOnLimit) {
        _showCapacityExceededSnackbar(context);
      }
      return;
    }

    onPercentageChanged(snappedValue);
  }

  void _showCapacityExceededSnackbar(BuildContext context) {
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
                'Blend capacity exceeded. Reduce other ingredients first.',
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
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showIngredientDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ingredient Details',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      pageBuilder: (_, _, _) => BlocProvider.value(
        value: BlocProvider.of<CustomizerBloc>(context),
        child: IngredientDetailsPopup(
          ingredient: ingredient,
          totalWeight: totalWeight,
          packetSize: packetSize,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final int displayWeight = weightInGrams;
    final double displayPercentage = ingredient.percentage * 100;

    return GestureDetector(
      onTap: () => _showIngredientDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                // Ingredient Image
                Image.asset(
                  'assets/images/${ingredient.name.toLowerCase()}.png',
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      ingredient.icon,
                      size: 30,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Ingredient Name and Weight
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${displayWeight}g • ${displayPercentage.toStringAsFixed(0)}%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove Button (all ingredients now removable)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: colorScheme.error,
                  ),
                  onPressed: onRemoved,
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // // Slider
            // SliderTheme(
            //   data: SliderTheme.of(context).copyWith(
            //     trackHeight: 8.0,
            //     trackShape: const RoundedRectSliderTrackShape(),
            //     activeTrackColor: colorScheme.primary,
            //     inactiveTrackColor: colorScheme.surfaceVariant,
            //     thumbShape: const RoundSliderThumbShape(
            //       enabledThumbRadius: 10.0,
            //     ),
            //     thumbColor: colorScheme.primary,
            //     overlayColor: colorScheme.primary.withOpacity(0.2),
            //     overlayShape: const RoundSliderOverlayShape(
            //       overlayRadius: 20.0,
            //     ),
            //   ),
            //   child: Slider(
            //     value: ingredient.percentage,
            //     min: 0.0,
            //     max: 1.0,
            //     onChanged: (value) =>
            //         _setPercentage(context, value, showSnackbarOnLimit: true),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
