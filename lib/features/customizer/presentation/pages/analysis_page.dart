import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _pendingAddToCart = false;
  bool _hasItemInCart = false;

  @override
  void initState() {
    super.initState();
    // Load user blends when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomizerBloc>().add(LoadUserBlends());
      // Also load cart to check if current blend is already in cart
      context.read<CartBloc>().add(LoadCart());
    });
  }

  void _checkAndAddToCartIfPending(
    BuildContext context,
    SavedBlendEntity savedBlend,
  ) {
    if (_pendingAddToCart) {
      _pendingAddToCart = false;
      _addBlendToCart(context, savedBlend);
    }
  }

  void _addBlendToCart(BuildContext context, SavedBlendEntity savedBlend) {
    final cartBloc = context.read<CartBloc>();

    // Create cart item from saved blend
    final cartItem = CartItemEntity(
      productId: savedBlend.id,
      productName: savedBlend.name,
      productType: 'blend',
      quantity: 1,
      price: savedBlend.pricePerKg * savedBlend.weightKg,
      pricePerKg: savedBlend.pricePerKg,
      mrp:
          savedBlend.pricePerKg *
          1.2 *
          savedBlend.weightKg, // Assume 20% markup from MRP
      imageUrl: null, // Custom blends might not have images
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      weightInKg: savedBlend.weightKg,
      isCustomBlend: true,
    );

    cartBloc.add(AddItemToCart(item: cartItem));

    // Update state to show "Go to Cart" button
    setState(() {
      _hasItemInCart = true;
    });

    // Show success message
    SnackbarUtils.showAddedToCart(context, savedBlend.name);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CartBloc, CartState>(
          listener: (context, cartState) {
            // Check if current saved blend is in cart
            if (cartState is CartLoaded) {
              final customizerState = context.read<CustomizerBloc>().state;
              if (customizerState.savedBlend != null) {
                final isInCart = cartState.cart.items.any(
                  (item) => item.productId == customizerState.savedBlend!.id,
                );
                if (isInCart != _hasItemInCart) {
                  setState(() {
                    _hasItemInCart = isInCart;
                  });
                }
              }
            }
          },
        ),
      ],
      child: BlocConsumer<CustomizerBloc, CustomizerState>(
        listener: (context, state) {
          if (state.error != null) {
            SnackbarUtils.showError(context, state.error!);
          }
          if (state.savedBlend != null) {
            SnackbarUtils.showSuccess(context, 'Blend saved successfully!');
          }

          // Handle add to cart after save
          if (state.savedBlend != null &&
              !state.isSaving &&
              state.error == null) {
            // Check if this was triggered by SaveBlendAndAddToCart
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _checkAndAddToCartIfPending(context, state.savedBlend!);
              }
            });
          }
        },
        builder: (context, state) {
          if (state.isAnalyzing) {
            return const _AnalyzingLoader();
          }

          if (state.analysisResult == null) {
            return const Center(child: Text('No analysis data available.'));
          }

          final analysis = state.analysisResult!;

          return _AnalysisResult(
            analysis: analysis,
            hasItemInCart: _hasItemInCart,
            isSaving: state.isSaving,
          );
        },
      ),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  final BlendAnalysisEntity analysis;
  final bool hasItemInCart;
  final bool isSaving;
  const _AnalysisResult({
    required this.analysis,
    required this.hasItemInCart,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Blend Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NutritionalInfoCard(analysis: analysis),
              const SizedBox(height: 24),
              _RotiCharacteristicsCard(analysis: analysis),
              const SizedBox(height: 24),
              _HealthBenefitsCard(analysis: analysis),
              const SizedBox(height: 24),
              _AllergensCard(analysis: analysis),
              const SizedBox(height: 24),
              _SuitabilityNotesCard(analysis: analysis),
              const SizedBox(height: 24),
              _DisclaimerCard(),
              const SizedBox(height: 32),
              _ActionButtonsSection(
                isSaving: isSaving,
                hasItemInCart: hasItemInCart,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionalInfoCard extends StatelessWidget {
  final BlendAnalysisEntity analysis;

  const _NutritionalInfoCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Nutritional Information',
      subtitle: 'per 100g',
      icon: MdiIcons.chartLineVariant,
      child: Column(
        children: [
          _NutrientRow(
            'Calories',
            '${analysis.nutritionalInfo.calories.toStringAsFixed(1)} kcal',
          ),
          _NutrientRow(
            'Protein',
            '${analysis.nutritionalInfo.protein.toStringAsFixed(1)}g',
          ),
          _NutrientRow(
            'Fat',
            '${analysis.nutritionalInfo.fat.toStringAsFixed(1)}g',
          ),
          _NutrientRow(
            'Carbohydrates',
            '${analysis.nutritionalInfo.carbohydrates.toStringAsFixed(1)}g',
          ),
          _NutrientRow(
            'Fiber',
            '${analysis.nutritionalInfo.fiber.toStringAsFixed(1)}g',
          ),
          _NutrientRow(
            'Iron',
            analysis.nutritionalInfo.iron.toStringAsFixed(1),
            trailing: Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotiCharacteristicsCard extends StatelessWidget {
  final BlendAnalysisEntity analysis;

  const _RotiCharacteristicsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Roti Characteristics',
      icon: MdiIcons.circleOutline,
      child: Column(
        children: [
          _CharacteristicRow(
            'Taste',
            analysis.rotiCharacteristics.taste,
            analysis.rotiCharacteristics.tasteRating,
          ),
          const SizedBox(height: 16),
          _CharacteristicRow(
            'Texture',
            analysis.rotiCharacteristics.texture,
            analysis.rotiCharacteristics.textureRating,
          ),
          const SizedBox(height: 16),
          _CharacteristicRow(
            'Softness',
            analysis.rotiCharacteristics.softness,
            analysis.rotiCharacteristics.softnessRating,
          ),
        ],
      ),
    );
  }
}

class _HealthBenefitsCard extends StatelessWidget {
  final BlendAnalysisEntity analysis;

  const _HealthBenefitsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Health Benefits',
      icon: Icons.favorite_border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: analysis.healthBenefits
            .map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 8),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        benefit,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AllergensCard extends StatelessWidget {
  final BlendAnalysisEntity analysis;

  const _AllergensCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Allergen Information',
      icon: Icons.warning_amber_outlined,
      child: analysis.allergens.isEmpty
          ? Text(
              'No known allergens',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: analysis.allergens
                  .map(
                    (allergen) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7, right: 8),
                            child: Icon(
                              Icons.warning_amber,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              allergen,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SuitabilityNotesCard extends StatelessWidget {
  final BlendAnalysisEntity analysis;

  const _SuitabilityNotesCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Suitability Notes',
      icon: Icons.info_outline,
      child: Text(
        analysis.suitabilityNotes,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Disclaimer',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This information is for educational purposes only and is not intended as medical advice. Roti characteristic predictions are estimates based on typical preparations. Consult with a healthcare professional or registered dietitian before making significant changes to your diet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsSection extends StatelessWidget {
  final bool isSaving;
  final bool hasItemInCart;

  const _ActionButtonsSection({
    required this.isSaving,
    required this.hasItemInCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: isSaving
                    ? null
                    : () => _showSaveBlendDialog(context),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Text(
                        'Save Blend',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: hasItemInCart
                    ? () => _goToCart(context)
                    : () => _handleAddToCart(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasItemInCart ? 'Go to Cart' : 'Add to Cart',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveBlendDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    // Generate smart default name based on current user and blends
    final customizerBloc = context.read<CustomizerBloc>();
    final state = customizerBloc.state;

    if (state.currentUser != null && state.userBlends.isNotEmpty) {
      final userName = state.currentUser!.name;
      final basePattern = "$userName's Blend";

      // Count existing blends with similar pattern
      int maxNumber = 0;
      final regExp = RegExp(r"^" + RegExp.escape(basePattern) + r" (\d+)$");

      for (final blend in state.userBlends) {
        final match = regExp.firstMatch(blend.name);
        if (match != null) {
          final number = int.tryParse(match.group(1) ?? '') ?? 0;
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }

      nameController.text = "$basePattern ${maxNumber + 1}";
    } else {
      nameController.text = "My Custom Blend";
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Save Your Blend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Give your special atta blend a name to remember it by.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Blend Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<CustomizerBloc>().add(
                    SaveBlend(nameController.text),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _goToCart(BuildContext context) {
    context.push('/cart');
  }

  void _handleAddToCart(BuildContext context) {
    final customizerBloc = context.read<CustomizerBloc>();
    final state = customizerBloc.state;

    // Check if blend is already saved
    if (state.savedBlend != null) {
      // Blend is already saved, directly add to cart
      final analysisPageState = context
          .findAncestorStateOfType<_AnalysisPageState>();
      analysisPageState?._addBlendToCart(context, state.savedBlend!);
    } else {
      // Need to save blend first, then add to cart
      final analysisPageState = context
          .findAncestorStateOfType<_AnalysisPageState>();
      if (analysisPageState != null) {
        analysisPageState._pendingAddToCart = true;
        customizerBloc.add(const SaveBlendAndAddToCart());
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: child,
        ),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String nutrient;
  final String value;
  final Widget? trailing;

  const _NutrientRow(this.nutrient, this.value, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: Theme.of(context).textTheme.bodyLarge),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

class _CharacteristicRow extends StatelessWidget {
  final String characteristic;
  final String description;
  final int rating;

  const _CharacteristicRow(this.characteristic, this.description, this.rating);

  @override
  Widget build(BuildContext context) {
    final ratingOutOf5 = (rating / 2).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                characteristic,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < ratingOutOf5 ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
              const SizedBox(width: 6),
              Text(
                '$ratingOutOf5/5',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Full-screen GIF animation loader
class _AnalyzingLoader extends StatelessWidget {
  const _AnalyzingLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Image.asset(
          'assets/anim/one-atta-anim.gif',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
