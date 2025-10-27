import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/presentation/widgets/packet_size_selector.dart';
import 'package:one_atta/features/customizer/presentation/widgets/total_progress_card.dart';
import 'package:one_atta/features/customizer/presentation/widgets/available_ingredients_section.dart';
import 'package:one_atta/features/customizer/presentation/bloc/packet_size_extension.dart';
import 'package:one_atta/features/customizer/presentation/widgets/selected_ingredients_section.dart';

class CustomizerPage extends StatefulWidget {
  const CustomizerPage({super.key});

  @override
  State<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends State<CustomizerPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Initialize the customizer
    context.read<CustomizerBloc>()
      ..add(InitializeCustomizer())
      ..add(LoadIngredients())
      ..add(LoadUserBlends());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomizerBloc, CustomizerState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          SnackbarUtils.showError(context, state.error!);
        }
      },
      child: BlocBuilder<CustomizerBloc, CustomizerState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        'Customizer',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomizerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Packet Size Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PacketSizeSelector(
                selectedWeight: state.selectedPacketSize,
                onWeightChanged: (packetSize) {
                  context.read<CustomizerBloc>().add(
                    SelectPacketSize(packetSize),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Total Progress Indicator
          TotalProgressCard(
            totalPercentage: state.totalPercentage,
            isMaxReached: state.isMaxCapacityReached,
            totalWeight:
                state.totalWeight / 1000.0, // Convert grams to kg for display
            packetSize: state.selectedPacketSize.weightInKg.toDouble(),
          ),

          const SizedBox(height: 16),

          if (state.availableIngredients.isEmpty)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          else ...[
            // Available Ingredients Section
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Select Ingredients',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AvailableIngredientsSection(
              availableIngredients: state.availableIngredients,
              selectedIngredients: state.selectedIngredients,
              isMaxCapacityReached: state.isMaxCapacityReached,
              scrollController: _horizontalScrollController,
              onIngredientAdded: (ingredient) {
                context.read<CustomizerBloc>().add(AddIngredient(ingredient));
              },
              onIngredientRemoved: (ingredient) {
                context.read<CustomizerBloc>().add(
                  RemoveIngredient(ingredient.name),
                );
              },
            ),
          ],

          const SizedBox(height: 24),

          // Selected Ingredients Section
          if (state.selectedIngredients.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap an ingredient to change its amount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SelectedIngredientsSection(
              selectedIngredients: state.selectedIngredients,
              totalWeight: state.totalWeight,
              packetSize: state.selectedPacketSize,
              totalPercentage: state.totalPercentage,
              isMaxCapacityReached: state.isMaxCapacityReached,
              onIngredientRemoved: (ingredient) {
                context.read<CustomizerBloc>().add(
                  RemoveIngredient(ingredient.name),
                );
              },
              onPercentageChanged: (ingredient, value) {
                context.read<CustomizerBloc>().add(
                  UpdateIngredientPercentage(ingredient.name, value),
                );
              },
            ),
          ],

          const SizedBox(height: 8),

          // Analyze Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.selectedIngredients.isNotEmpty
                  ? () {
                      // Check if blend is at 100% before analyzing
                      const tolerance = 0.001;
                      if (state.totalPercentage < (1.0 - tolerance)) {
                        // Show snackbar if not at 100%
                        SnackbarUtils.showWarning(
                          context,
                          'Blend must be at 100% to analyze. Current: ${(state.totalPercentage * 100).toStringAsFixed(0)}%',
                        );
                        return;
                      }

                      // Proceed with analysis if at 100%
                      context.read<CustomizerBloc>().add(AnalyzeBlend());
                      context.push('/analysis');
                    }
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Analyze Blend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
