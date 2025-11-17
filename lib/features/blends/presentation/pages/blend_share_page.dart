import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_state.dart';
import 'package:one_atta/features/blends/presentation/widgets/ingredients_card.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:share_plus/share_plus.dart';

class BlendSharePage extends StatelessWidget {
  final String shareCode;

  const BlendSharePage({super.key, required this.shareCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BlendShareBloc(repository: di.sl())
            ..add(LoadBlendByShareCode(shareCode)),
      child: BlendShareView(shareCode: shareCode),
    );
  }
}

class BlendShareView extends StatefulWidget {
  final String shareCode;

  const BlendShareView({super.key, required this.shareCode});

  @override
  State<BlendShareView> createState() => _BlendShareViewState();
}

class _BlendShareViewState extends State<BlendShareView> {
  int _selectedWeight = 1; // Default to 1Kg
  final List<int> _availableWeights = [1, 3, 5]; // Available weights in Kg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<BlendShareBloc, BlendShareState>(
        builder: (context, state) {
          if (state is BlendShareLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is BlendShareError) {
            return _buildErrorState(context, state.message, state);
          }

          if (state is BlendShareLoaded) {
            final blend = state.blend;

            return _buildBlendDetails(
              context,
              blend,
              state is BlendShareLoading,
              state,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    BlendShareError state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blend Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ErrorPage(
        message: message,
        failure: state.failure,
        onRetry: () {
          context.read<BlendShareBloc>().add(
            LoadBlendByShareCode(widget.shareCode),
          );
        },
      ),
    );
  }

  Widget _buildBlendDetails(
    BuildContext context,
    dynamic blend,
    bool isLoading,
    BlendShareState state,
  ) {
    return CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: BackButton(color: Theme.of(context).colorScheme.onSurface),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.network(
                      blend.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer,
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.blender,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer,
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          'Check out this Blend: ${blend.name}\n${AppConstants.shareBaseUrl}/blend/${blend.shareCode}',
                      subject: 'OneAtta\'s ${blend.name}',
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blend.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Creator name
                    Row(
                      children: [
                        Text(
                          'by ${blend.createdBy.name}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.share,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${blend.shareCount} shares',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price section
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${blend.pricePerKg.toStringAsFixed(2)}/Kg',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              '(Inclusive of all taxes)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Best before ${blend.expiryDays} days',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  _addBlendToCart(context, blend);
                                },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_shopping_cart,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add to Cart',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weight Selection
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Weight',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: _availableWeights.map((weight) {
                        final isSelected = _selectedWeight == weight;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedWeight = weight;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$weight Kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${(blend.pricePerKg * weight).toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.9)
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Share code section
              if (blend.shareCode != null && blend.shareCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Share this Blend',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DottedBorder(
                        options: RectDottedBorderOptions(
                          dashPattern: const [8, 4],
                          strokeWidth: 2,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                blend.shareCode,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: blend.shareCode),
                                  );
                                  SnackbarUtils.showSuccess(
                                    context,
                                    'Share code copied!',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ingredients
              IngredientsCard(additives: blend.additives),

              // Benefits section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildBenefitItem(context, 'Supports digestive health'),
                    _buildBenefitItem(context, 'Provides sustained energy'),
                    _buildBenefitItem(context, 'Rich in antioxidants'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(benefit, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _addBlendToCart(BuildContext context, PublicBlendEntity blendUsed) {
    // Add blend to cart using proper cart bloc
    final cartItem = CartItemEntity(
      productId: blendUsed.id,
      productName: blendUsed.name,
      productType: 'blend',
      quantity: 1,
      price: blendUsed.pricePerKg * _selectedWeight,
      mrp: blendUsed.pricePerKg * _selectedWeight,
      pricePerKg: blendUsed.pricePerKg,
      imageUrl: blendUsed.imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      weightInKg: _selectedWeight,
    );

    context.read<CartBloc>().add(AddItemToCart(item: cartItem));

    // Show success feedback
    SnackbarUtils.showAddedToCart(
      context,
      blendUsed.name,
      weight: '$_selectedWeight Kg',
    );
  }
}
