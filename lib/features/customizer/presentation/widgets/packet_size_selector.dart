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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Select Packet Size',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<PacketSize>(
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            segments: [
              ButtonSegment<PacketSize>(
                value: PacketSize.kg1,
                label: const Text('1 Kg'),
              ),
              ButtonSegment<PacketSize>(
                value: PacketSize.kg3,
                label: const Text('3 Kg'),
              ),
              ButtonSegment<PacketSize>(
                value: PacketSize.kg5,
                label: const Text('5 Kg'),
              ),
            ],
            selected: <PacketSize>{selectedWeight},
            onSelectionChanged: (Set<PacketSize> newSelection) {
              if (newSelection.isNotEmpty) {
                onWeightChanged(newSelection.first);
              }
            },
          ),
        ],
      ),
    );
  }
}
