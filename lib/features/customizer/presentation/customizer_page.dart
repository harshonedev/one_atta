import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/presentation/widgets/packet_size_selector.dart';
import 'package:one_atta/features/customizer/presentation/widgets/total_progress_card.dart';
import 'package:one_atta/features/customizer/presentation/widgets/available_ingredients_section.dart';
import 'package:one_atta/features/customizer/presentation/widgets/selected_ingredients_section.dart';
import 'package:one_atta/features/customizer/presentation/widgets/section_header.dart';

class CustomizerPage extends StatefulWidget {
  const CustomizerPage({super.key});

  @override
  State<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends State<CustomizerPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _selectedScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Initialize the customizer
    context.read<CustomizerBloc>().add(InitializeCustomizer());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _selectedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomizerBloc, CustomizerState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.onError,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
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

          const SizedBox(height: 24),

          // Total Progress Indicator
          TotalProgressCard(
            totalPercentage: state.totalPercentage,
            isMaxReached: state.isMaxCapacityReached,
          ),

          const SizedBox(height: 24),

          // Available Ingredients Section
          const SectionHeader(title: 'Customize Your Blend'),
          const SizedBox(height: 12),
          AvailableIngredientsSection(
            availableIngredients: state.availableIngredients,
            selectedIngredients: state.selectedIngredients,
            isMaxCapacityReached: state.isMaxCapacityReached,
            scrollController: _horizontalScrollController,
            onIngredientAdded: (ingredient) {
              context.read<CustomizerBloc>().add(AddIngredient(ingredient));
            },
          ),

          const SizedBox(height: 24),

          // Selected Ingredients Section
          if (state.selectedIngredients.isNotEmpty) ...[
            const SectionHeader(title: 'Your Custom Blend'),
            const SizedBox(height: 12),
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

          const SizedBox(height: 24),

          // Analyze Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: state.selectedIngredients.isNotEmpty
                  ? () {
                      context.read<CustomizerBloc>().add(AnalyzeBlend());
                      context.push('/analysis');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analyze Blend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
