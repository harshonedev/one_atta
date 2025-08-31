import 'package:flutter/material.dart';
import 'package:one_atta/core/presentation/widgets/network_image_loader.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/presentation/constants/blend_images.dart';

class BlendListCard extends StatelessWidget {
  final PublicBlendEntity blend;
  final VoidCallback? onTap;

  const BlendListCard({super.key, required this.blend, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            NetworkImageLoader(
              imageUrl: BlendImages.getImageForBlend(blend.id),
              height: 180,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and share count
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          blend.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Share count
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${blend.shareCount}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Price and expiry
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${blend.pricePerKg.toStringAsFixed(2)}/kg',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'Expires in ${blend.expiryDays} days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // // Ingredients preview
                  // Text(
                  //   'Ingredients:',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),

                  // Wrap(
                  //   spacing: 8,
                  //   runSpacing: 4,
                  //   children: blend.additives.take(3).map((additive) {
                  //     return Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 8,
                  //         vertical: 4,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: Theme.of(
                  //           context,
                  //         ).colorScheme.surfaceContainerHigh,
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Text(
                  //         '${additive.originalDetails.name} (${additive.percentage.toStringAsFixed(0)}%)',
                  //         style: Theme.of(context).textTheme.bodySmall
                  //             ?.copyWith(
                  //               color: Theme.of(
                  //                 context,
                  //               ).colorScheme.onSurfaceVariant,
                  //             ),
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),

                  // if (blend.additives.length > 3)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4),
                  //     child: Text(
                  //       '+${blend.additives.length - 3} more ingredients',
                  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //         color: Theme.of(context).colorScheme.primary,
                  //         fontStyle: FontStyle.italic,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
