import 'package:flutter/material.dart';
import 'dart:math';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Blend Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<CustomizerBloc, CustomizerState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.savedBlend != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Blend saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isAnalyzing) {
            return const _AnalyzingLoader();
          }

          if (state.analysisResult == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No analysis data available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CustomizerBloc>().add(AnalyzeBlend());
                    },
                    child: const Text('Analyze Blend'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BlendSummaryCard(
                  ingredients: state.allIngredients,
                  packetSize: state.selectedPacketSize,
                  totalWeight: state.totalWeight,
                ),
                const SizedBox(height: 24),
                _NutritionalInfoCard(analysis: state.analysisResult!),
                const SizedBox(height: 24),
                _RotiCharacteristicsCard(analysis: state.analysisResult!),
                const SizedBox(height: 24),
                _HealthBenefitsCard(analysis: state.analysisResult!),
                const SizedBox(height: 24),
                _AllergensCard(analysis: state.analysisResult!),
                const SizedBox(height: 24),
                _DisclaimerSection(),

                const SizedBox(height: 16),
                _ActionButtonsSection(isSaving: state.isSaving),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BlendSummaryCard extends StatelessWidget {
  final List<Ingredient> ingredients;
  final PacketSize packetSize;
  final int totalWeight;

  const _BlendSummaryCard({
    required this.ingredients,
    required this.packetSize,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Custom Blend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'Size',
                  value: packetSize == PacketSize.kg1
                      ? '1 Kg'
                      : packetSize == PacketSize.kg3
                      ? '3 Kg'
                      : '5 Kg',
                  icon: Icons.scale,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  label: 'Best Used Within',
                  value: '45 days',
                  icon: Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingredients:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...ingredients.map((ingredient) {
            final weightInGrams = (ingredient.percentage * totalWeight).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ingredient.name == 'Wheat'
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ingredient.icon,
                      size: 16,
                      color: ingredient.name == 'Wheat'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${(ingredient.percentage * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${weightInGrams}g',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
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
      icon: Icons.insights,
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
            '${analysis.nutritionalInfo.iron.toStringAsFixed(1)}mg',
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
      icon: Icons.restaurant,
      child: Column(
        children: [
          _CharacteristicRow(
            'Taste',
            analysis.rotiCharacteristics.taste,
            analysis.rotiCharacteristics.tasteRating,
          ),
          _CharacteristicRow(
            'Texture',
            analysis.rotiCharacteristics.texture,
            analysis.rotiCharacteristics.textureRating,
          ),
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
      icon: Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: analysis.healthBenefits
            .map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
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
      title: 'Allergens & Warnings',
      icon: Icons.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...analysis.allergens.map(
            (allergen) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allergen,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (analysis.suitabilityNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                analysis.suitabilityNotes,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtonsSection extends StatelessWidget {
  final bool isSaving;

  const _ActionButtonsSection({required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: isSaving
                    ? null
                    : () => _showSaveBlendDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Save Blend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement add to cart functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    // Generate default name - you can customize this logic
    nameController.text =
        "Blend 1"; // TODO: Get actual username and increment number

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
              const Text('Give your custom blend a name:'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter blend name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label),
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
                final blendName = nameController.text.trim();
                if (blendName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a blend name'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                context.read<CustomizerBloc>().add(SaveBlend(blendName));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String nutrient;
  final String value;

  const _NutrientRow(this.nutrient, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                characteristic,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$rating/10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerSection extends StatelessWidget {
  const _DisclaimerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This information is for educational purposes only and is not intended as medical advice. Roti characteristic predictions are estimates based on typical preparations. Consult with a healthcare professional or registered dietitian before making significant changes to your diet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated analyzing loader mimicking grain particles falling into a bag
class _AnalyzingLoader extends StatefulWidget {
  const _AnalyzingLoader();

  @override
  State<_AnalyzingLoader> createState() => _AnalyzingLoaderState();
}

class _AnalyzingLoaderState extends State<_AnalyzingLoader>
    with TickerProviderStateMixin {
  final GlobalKey _bagKey = GlobalKey();
  late AnimationController _spawnController; // loops to spawn particles
  late AnimationController _fallController; // drives particle fall curve
  final List<_AnalyzeParticle> _particles = [];
  final Random _random = Random();
  static const int _maxParticles = 90; // performance cap

  static final List<IconData> _ingredientIcons = [
    MdiIcons.seed,
    MdiIcons.corn,
    MdiIcons.barley,
    MdiIcons.grain,
    MdiIcons.seedOutline,
  ];

  @override
  void initState() {
    super.initState();
    _spawnController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _spawnController.forward(from: 0); // loop
          }
        });
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _spawnController.forward();
    _fallController.repeat();
    _scheduleParticleSpawn();
  }

  void _scheduleParticleSpawn() async {
    // periodically add particles
    Future.doWhile(() async {
      if (!mounted) return false;
      _addParticles(batch: 4 + _random.nextInt(4));
      await Future.delayed(const Duration(milliseconds: 220));
      return mounted;
    });
  }

  void _addParticles({int batch = 5}) {
    final renderBox = _bagKey.currentContext?.findRenderObject() as RenderBox?;
    final bagPos = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final bagSize = renderBox?.size ?? const Size(120, 120);
    if (renderBox == null) return; // wait until bag laid out
    setState(() {
      if (_particles.length >= _maxParticles) return;
      final allowed = min(batch, _maxParticles - _particles.length);
      for (int i = 0; i < allowed; i++) {
        final icon = _ingredientIcons[_random.nextInt(_ingredientIcons.length)];
        final screenWidth = MediaQuery.of(context).size.width;
        final bagCenterX = bagPos.dx + bagSize.width / 2;
        // Start anywhere across screen width for a uniform rain
        final startX = _random.nextDouble() * screenWidth;
        final startY = -60.0 - _random.nextDouble() * 80.0; // higher start
        // Converge towards bag center with mild jitter
        final endOffset = Offset(
          bagCenterX + (_random.nextDouble() * 48 - 24),
          bagPos.dy + bagSize.height * 0.12, // just inside top of bag
        );
        final startOffset = Offset(startX, startY);
        _particles.add(
          _AnalyzeParticle(
            key: UniqueKey(),
            startOffset: startOffset,
            endOffset: endOffset,
            controller: _fallController,
            icon: icon,
            onDone: (k) {
              if (mounted) {
                setState(() {
                  _particles.removeWhere((p) => p.key == k);
                });
              }
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _spawnController.dispose();
    _fallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                width: 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Falling particles
                    ..._particles,
                    // Bag image centered bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        key: _bagKey,
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.none,
                        child: Image.asset(
                          'assets/images/wheat_bag.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Analyzing your blend...',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Estimating nutrition & characteristics',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyzeParticle extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final AnimationController controller;
  final void Function(Key) onDone;
  final IconData icon;

  const _AnalyzeParticle({
    required Key key,
    required this.startOffset,
    required this.endOffset,
    required this.controller,
    required this.onDone,
    required this.icon,
  }) : super(key: key);

  @override
  State<_AnalyzeParticle> createState() => _AnalyzeParticleState();
}

class _AnalyzeParticleState extends State<_AnalyzeParticle> {
  late Animation<double> _progress;
  late double _startX;
  late double _startY;
  final Random _rand = Random();
  late double _swayAmp;
  late double _size;
  late Color _color;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _progress = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(
        _rand.nextDouble() * 0.5,
        0.9 + _rand.nextDouble() * 0.1,
        curve: Curves.easeIn,
      ),
    );
    // Defer inherited + startOffset usage until didChangeDependencies
    _startX = 0;
    _startY = 0;
    _swayAmp = 10 + _rand.nextDouble() * 18;
    _size = 14 + _rand.nextDouble() * 6; // icon size
    _color = Colors.amber; // temporary until resolved
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_resolved) {
      _startX = widget.startOffset.dx;
      _startY = widget.startOffset.dy;
      final scheme = Theme.of(context).colorScheme;
      final seed = _rand.nextInt(3);
      _color = [
        scheme.primary,
        scheme.secondary,
        scheme.tertiaryContainer,
      ][seed].withOpacity(0.85);
      _resolved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final t = _progress.value;
        if (t >= 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onDone(widget.key!);
          });
        }
        final easeT = Curves.easeIn.transform(t);
        final dx = _startX + sin(t * pi * 2) * _swayAmp;
        final dy = _startY + (widget.endOffset.dy - _startY) * easeT;
        final fade = (1 - t).clamp(0.0, 1.0);
        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: fade,
            child: Icon(
              widget.icon,
              size: _size,
              color: _color,
              shadows: [Shadow(color: _color.withOpacity(0.4), blurRadius: 4)],
            ),
          ),
        );
      },
    );
  }
}
