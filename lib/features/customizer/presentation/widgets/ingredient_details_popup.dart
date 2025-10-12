import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';

class IngredientDetailsPopup extends StatefulWidget {
  final Ingredient ingredient;
  final int totalWeight; // grams
  final PacketSize packetSize;
  final double
  currentTotalPercentage; // current total percentage of all ingredients
  final bool isMaxCapacityReached;

  const IngredientDetailsPopup({
    super.key,
    required this.ingredient,
    required this.totalWeight,
    required this.packetSize,
    required this.currentTotalPercentage,
    required this.isMaxCapacityReached,
  });

  @override
  State<IngredientDetailsPopup> createState() => _IngredientDetailsPopupState();
}

class _IngredientDetailsPopupState extends State<IngredientDetailsPopup> {
  late double _percentage; // 0 - 1

  int get divisions => (widget.totalWeight / 100).round(); // 100g steps

  // Check if a new percentage would exceed max capacity
  bool _wouldExceedCapacity(double newPercentage) {
    const tolerance = 0.001; // Same tolerance as in the bloc
    final currentIngredientPercentage = widget.ingredient.percentage;
    final percentageDifference = newPercentage - currentIngredientPercentage;
    final newTotalPercentage =
        widget.currentTotalPercentage + percentageDifference;
    return newTotalPercentage > (1.0 + tolerance);
  }

  @override
  void initState() {
    super.initState();
    _percentage = widget.ingredient.percentage;
  }

  // Constant 5 stops aligned with slider ticks (every 100g)
  List<int> _getConstantStops() {
    final totalWeight = widget.totalWeight;
    final step = totalWeight ~/ 5; // Divide into 4 equal parts for 5 stops
    final alignedStep = (step / 100).round() * 100; // Snap to nearest 100g
    return [
      0,
      alignedStep,
      alignedStep * 2,
      alignedStep * 3,
      alignedStep * 4,
      totalWeight,
    ];
  }

  // Check if current weight matches any stop (within 25g tolerance for 100g steps)
  bool _isCurrentWeightAtStop(int stopWeight, int currentWeight) {
    return (currentWeight - stopWeight).abs() <= 25;
  }

  String _weightLabel(int grams) {
    if (grams >= 1000) {
      final kg = (grams / 1000).toStringAsFixed(grams % 1000 == 0 ? 0 : 1);
      return grams == widget.totalWeight ? '${kg}kg' : '${kg}kg';
    }
    return '${grams}g';
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
                  child: SvgPicture.asset(
                    'assets/icons/${widget.ingredient.name.toLowerCase()}.svg',
                    height: 90,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFFB0792E),
                      BlendMode.srcIn,
                    ),

                    errorBuilder: (_, _, _) => Icon(
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
                  totalWeight: widget.totalWeight,
                  onChanged: (p) {
                    // Only allow the change if it's a decrease or if it doesn't exceed capacity
                    if (p <= _percentage || !_wouldExceedCapacity(p)) {
                      setState(() => _percentage = p);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Constant weight labels with highlighting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getConstantStops()
                        .map(
                          (g) => Text(
                            _weightLabel(g),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isCurrentWeightAtStop(g, currentWeight)
                                  ? const Color(0xFFE59A3B)
                                  : Colors.black54,
                              fontWeight:
                                  _isCurrentWeightAtStop(g, currentWeight)
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
                  'This adds +${widget.ingredient.nutritionalInfo?.protein?.toStringAsFixed(1) ?? '2.1'} g protein / 100 g',
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
  final int totalWeight;

  const _SliderWithTicks({
    required this.percentage,
    required this.divisions,
    required this.onChanged,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final step = totalWeight ~/ 5; // Divide into 5 equal parts for 5 stops
    final alignedStep = (step / 100).round(); // Snap to nearest 100g
    final stops = [
      0,
      alignedStep,
      alignedStep * 2,
      alignedStep * 3,
      alignedStep * 4,
      totalWeight ~/ 100,
    ];
    final theme = Theme.of(context);
    final trackColor = const Color(0xFFF1E7DA);
    final activeColor = theme.colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tickCount = divisions + 1;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Track background with corner radius
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            // Ticks
            Positioned.fill(
              top: 10,
              bottom: 10,
              left: 10,
              right: 10,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    tickCount,
                    (i) => Container(
                      width: 2,
                      height: stops.contains(i) ? 36 : 18,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
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
              color: Theme.of(context).colorScheme.onPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
