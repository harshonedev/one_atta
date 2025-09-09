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

  List<int> _labelStops() {
    switch (widget.packetSize) {
      case PacketSize.kg1:
        return [100, 200, 300, widget.totalWeight];
      case PacketSize.kg3:
        return [500, 1000, 1500, widget.totalWeight];
      case PacketSize.kg5:
        return [1000, 2000, 3000, widget.totalWeight];
    }
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _labelStops()
                        .map(
                          (g) => Text(
                            _weightLabel(g),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${(_percentage * 100).toStringAsFixed(0)}% of blend',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
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
