import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';

class IngredientDetailsPopup extends StatefulWidget {
  final Ingredient ingredient;
  final int totalWeight; // grams
  final PacketSize packetSize;

  const IngredientDetailsPopup({
    super.key,
    required this.ingredient,
    required this.totalWeight,
    required this.packetSize,
  });

  @override
  State<IngredientDetailsPopup> createState() => _IngredientDetailsPopupState();
}

class _IngredientDetailsPopupState extends State<IngredientDetailsPopup> {
  late double _percentage; // 0 - 1

  int get divisions => (widget.totalWeight / 100).round(); // 100g steps

  @override
  void initState() {
    super.initState();
    _percentage = widget.ingredient.percentage;
  }

  // Dynamic labels that adjust based on current slider position
  List<int> _getDynamicLabelStops() {
    final currentWeight = (_percentage * widget.totalWeight).round();
    final totalWeight = widget.totalWeight;

    // Snap current weight to nearest 100g
    final snappedCurrentWeight = (currentWeight / 100).round() * 100;

    switch (widget.packetSize) {
      case PacketSize.kg1:
        final baseStops = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000];
        return _getRelevantStops(baseStops, snappedCurrentWeight, totalWeight);
      case PacketSize.kg3:
        final baseStops = [
          300,
          600,
          900,
          1200,
          1500,
          1800,
          2100,
          2400,
          2700,
          3000,
        ];
        return _getRelevantStops(baseStops, snappedCurrentWeight, totalWeight);
      case PacketSize.kg5:
        final baseStops = [
          500,
          1000,
          1500,
          2000,
          2500,
          3000,
          3500,
          4000,
          4500,
          5000,
        ];
        return _getRelevantStops(baseStops, snappedCurrentWeight, totalWeight);
    }
  }

  // Get 4-5 relevant stops around current position
  List<int> _getRelevantStops(
    List<int> allStops,
    int currentWeight,
    int totalWeight,
  ) {
    // Always include 0 and totalWeight
    final result = <int>{0};

    // Find stops around current weight
    final filteredStops = allStops
        .where((stop) => stop <= totalWeight)
        .toList();

    // Find the position of current weight in the stops
    int insertIndex = 0;
    for (int i = 0; i < filteredStops.length; i++) {
      if (filteredStops[i] <= currentWeight) {
        insertIndex = i + 1;
      } else {
        break;
      }
    }

    // Add current weight if it's not already in the list
    if (!filteredStops.contains(currentWeight) && currentWeight > 0) {
      result.add(currentWeight);
    }

    // Add 1-2 stops before and after current position
    for (
      int i = math.max(0, insertIndex - 2);
      i < math.min(filteredStops.length, insertIndex + 2);
      i++
    ) {
      result.add(filteredStops[i]);
    }

    // Always include total weight
    result.add(totalWeight);

    // Convert to sorted list and limit to 5 items max
    final sortedList = result.toList()..sort();
    if (sortedList.length > 5) {
      // Keep first, last, current, and 2 others
      final List<int> finalList = [sortedList.first];
      if (sortedList.contains(currentWeight) &&
          currentWeight != sortedList.first &&
          currentWeight != sortedList.last) {
        finalList.add(currentWeight);
      }
      // Add one or two middle values
      final middleIndex = sortedList.length ~/ 2;
      if (middleIndex != 0 && middleIndex != sortedList.length - 1) {
        finalList.add(sortedList[middleIndex]);
      }
      if (sortedList.last != sortedList.first) {
        finalList.add(sortedList.last);
      }
      return finalList.toSet().toList()..sort();
    }

    return sortedList;
  }

  String _weightLabel(int grams) {
    if (grams >= 1000) {
      final kg = (grams / 1000).toStringAsFixed(grams % 1000 == 0 ? 0 : 1);
      return grams == widget.totalWeight ? '${kg} kg' : '${kg} kg';
    }
    return '$grams g';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWeight = widget.totalWeight;
    final currentWeight = (_percentage * totalWeight).round();
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F4ED),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ingredient.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Hero(
                  tag: 'ingredient_${widget.ingredient.name}',
                  child: Image.asset(
                    'assets/images/${widget.ingredient.name.toLowerCase()}.png',
                    height: 90,
                    errorBuilder: (_, __, ___) => Icon(
                      widget.ingredient.icon,
                      size: 90,
                      color: const Color(0xFFB0792E),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _SliderWithTicks(
                  percentage: _percentage,
                  divisions: divisions,
                  onChanged: (p) => setState(() => _percentage = p),
                ),
                const SizedBox(height: 12),
                // Dynamic weight labels based on current position
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getDynamicLabelStops()
                        .map(
                          (g) => Text(
                            _weightLabel(g),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: g == currentWeight
                                  ? const Color(0xFFE59A3B)
                                  : Colors.black54,
                              fontWeight: g == currentWeight
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Current weight display - prominently shown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${currentWeight}g',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE59A3B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_percentage * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'of blend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This adds +2.1 g protein / 100 g',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: _PrimaryPillButton(
                    label: 'Done with ${widget.ingredient.name}',
                    onTap: () {
                      // Snap to nearest 100g before dispatch
                      final snappedWeight = (currentWeight / 100).round() * 100;
                      final snappedPercentage = snappedWeight / totalWeight;
                      context.read<CustomizerBloc>().add(
                        UpdateIngredientPercentage(
                          widget.ingredient.name,
                          snappedPercentage.clamp(0, 1),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderWithTicks extends StatelessWidget {
  final double percentage; // 0-1
  final int divisions; // number of 100g steps
  final ValueChanged<double> onChanged;

  const _SliderWithTicks({
    required this.percentage,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = const Color(0xFFF1E7DA);
    final activeColor = const Color(0xFFE59A3B);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tickCount = divisions + 1;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Track background with corner radius
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            // Ticks
            Positioned.fill(
              top: 10,
              bottom: 10,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    tickCount,
                    (i) => Container(
                      width: 2,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Slider overlay
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 0, // We draw custom track
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: activeColor,
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 16,
                  elevation: 2,
                ),
              ),
              child: Slider(
                value: percentage,
                min: 0,
                max: 1,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
