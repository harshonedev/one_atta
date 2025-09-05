import 'package:flutter/material.dart';
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
  final TextEditingController _blendNameController = TextEditingController();

  @override
  void dispose() {
    _blendNameController.dispose();
    super.dispose();
  }

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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your blend...'),
                ],
              ),
            );
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
                const SizedBox(height: 32),
                _SaveBlendSection(
                  controller: _blendNameController,
                  isSaving: state.isSaving,
                ),
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
                  value: packetSize.name,
                  icon: Icons.scale,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  label: 'Weight',
                  value: '${totalWeight}g',
                  icon: Icons.fitness_center,
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
      title: 'Nutritional Information (per 100g)',
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

class _SaveBlendSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;

  const _SaveBlendSection({required this.controller, required this.isSaving});

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
          Text(
            'Save Your Blend',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter blend name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () {
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a blend name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      context.read<CustomizerBloc>().add(
                        SaveBlend(controller.text.trim()),
                      );
                    },
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
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
          Wrap(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
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
