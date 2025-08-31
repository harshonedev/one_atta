import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/core/presentation/widgets/svg_image_loader.dart';
import 'package:one_atta/features/blends/domain/entities/additive_entity.dart';

class IngredientsCard extends StatelessWidget {
  final List<AdditiveEntity> additives;

  const IngredientsCard({super.key, required this.additives});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Text(
            'A blend of ${additives.length} carefully selected ingredients, offering a naturally balanced base for healthy cooking.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients list
          ...additives.map(
            (additive) => _buildIngredientItem(context, additive),
          ),

          const SizedBox(height: 8),

          // Total percentage check
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: ${additives.fold<double>(0, (sum, additive) => sum + additive.percentage).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(BuildContext context, AdditiveEntity additive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Ingredient icon/image placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgImageLoader(
              assetName: AppAssets.grainIcon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),

          // Ingredient details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  additive.originalDetails.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),

                Text(
                  '₹${additive.originalDetails.pricePerKg.toStringAsFixed(2)}/kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Percentage
          Text(
            '${additive.percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
