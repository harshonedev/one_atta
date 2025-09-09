import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

class PacketSizeSelector extends StatelessWidget {
  final PacketSize selectedWeight;
  final ValueChanged<PacketSize> onWeightChanged;

  const PacketSizeSelector({
    super.key,
    required this.selectedWeight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWeightOption(context, PacketSize.kg1, '1 kg'),
          _buildWeightOption(context, PacketSize.kg3, '3 kg'),
          _buildWeightOption(context, PacketSize.kg5, '5 kg'),
        ],
      ),
    );
  }

  Widget _buildWeightOption(
    BuildContext context,
    PacketSize weight,
    String label,
  ) {
    final isSelected = selectedWeight == weight;
    return GestureDetector(
      onTap: () => onWeightChanged(weight),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
