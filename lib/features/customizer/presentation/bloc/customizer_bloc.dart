import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';
import 'package:one_atta/features/customizer/domain/repositories/customizer_repository.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Events
abstract class CustomizerEvent extends Equatable {
  const CustomizerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCustomizer extends CustomizerEvent {}

class SelectPacketSize extends CustomizerEvent {
  final PacketSize packetSize;

  const SelectPacketSize(this.packetSize);

  @override
  List<Object?> get props => [packetSize];
}

class UpdateWheatPercentage extends CustomizerEvent {
  final double percentage;

  const UpdateWheatPercentage(this.percentage);

  @override
  List<Object?> get props => [percentage];
}

class AddIngredient extends CustomizerEvent {
  final Ingredient ingredient;

  const AddIngredient(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

class RemoveIngredient extends CustomizerEvent {
  final String ingredientName;

  const RemoveIngredient(this.ingredientName);

  @override
  List<Object?> get props => [ingredientName];
}

class UpdateIngredientPercentage extends CustomizerEvent {
  final String ingredientName;
  final double percentage;

  const UpdateIngredientPercentage(this.ingredientName, this.percentage);

  @override
  List<Object?> get props => [ingredientName, percentage];
}

class ShowCapacityExceededSnackbar extends CustomizerEvent {}

class AnalyzeBlend extends CustomizerEvent {}

class SaveBlend extends CustomizerEvent {
  final String blendName;

  const SaveBlend(this.blendName);

  @override
  List<Object?> get props => [blendName];
}

// State
class CustomizerState extends Equatable {
  final PacketSize selectedPacketSize;
  final int totalWeight; // in grams
  final List<Ingredient> availableIngredients;
  final List<Ingredient> selectedIngredients;
  final bool isMaxCapacityReached;
  final bool isAnalyzing;
  final bool isSaving;
  final BlendAnalysisEntity? analysisResult;
  final SavedBlendEntity? savedBlend;
  final String? error;

  const CustomizerState({
    required this.selectedPacketSize,
    required this.totalWeight,
    required this.availableIngredients,
    required this.selectedIngredients,
    required this.isMaxCapacityReached,
    this.isAnalyzing = false,
    this.isSaving = false,
    this.analysisResult,
    this.savedBlend,
    this.error,
  });

  factory CustomizerState.initial() {
    return CustomizerState(
      selectedPacketSize: PacketSize.kg1,
      totalWeight: 1000, // 1kg in grams
      availableIngredients: [
        Ingredient(name: 'Wheat', percentage: 0, icon: MdiIcons.grain),
        Ingredient(name: 'Chana', percentage: 0, icon: MdiIcons.seed),
        Ingredient(name: 'Makka', percentage: 0, icon: MdiIcons.corn),
        Ingredient(name: 'Bajra', percentage: 0, icon: MdiIcons.barley),
        Ingredient(name: 'Malt', percentage: 0, icon: MdiIcons.grain),
        Ingredient(name: 'Ragi', percentage: 0, icon: MdiIcons.seedOutline),
      ],
      selectedIngredients: [
        Ingredient(
          name: 'Wheat',
          percentage: 0.3,
          icon: MdiIcons.grain,
        ), // 30% default
      ],
      isMaxCapacityReached: false,
    );
  }

  double get totalPercentage {
    double total = 0;
    for (final ingredient in selectedIngredients) {
      total += ingredient.percentage;
    }
    return total;
  }

  List<Ingredient> get allIngredients => selectedIngredients;

  CustomizerState copyWith({
    PacketSize? selectedPacketSize,
    int? totalWeight,
    List<Ingredient>? availableIngredients,
    List<Ingredient>? selectedIngredients,
    bool? isMaxCapacityReached,
    bool? isAnalyzing,
    bool? isSaving,
    BlendAnalysisEntity? analysisResult,
    SavedBlendEntity? savedBlend,
    String? error,
    bool clearError = false,
    bool clearAnalysisResult = false,
    bool clearSavedBlend = false,
  }) {
    return CustomizerState(
      selectedPacketSize: selectedPacketSize ?? this.selectedPacketSize,
      totalWeight: totalWeight ?? this.totalWeight,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      isMaxCapacityReached: isMaxCapacityReached ?? this.isMaxCapacityReached,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isSaving: isSaving ?? this.isSaving,
      analysisResult: clearAnalysisResult
          ? null
          : (analysisResult ?? this.analysisResult),
      savedBlend: clearSavedBlend ? null : (savedBlend ?? this.savedBlend),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    selectedPacketSize,
    totalWeight,
    availableIngredients,
    selectedIngredients,
    isMaxCapacityReached,
    isAnalyzing,
    isSaving,
    analysisResult,
    savedBlend,
    error,
  ];
}

enum PacketSize { kg1, kg3, kg5 }

// Bloc
class CustomizerBloc extends Bloc<CustomizerEvent, CustomizerState> {
  final CustomizerRepository customizerRepository;
  final Logger logger = Logger();

  CustomizerBloc({required this.customizerRepository})
    : super(CustomizerState.initial()) {
    on<InitializeCustomizer>(_onInitializeCustomizer);
    on<SelectPacketSize>(_onSelectPacketSize);
    on<UpdateWheatPercentage>(_onUpdateWheatPercentage);
    on<AddIngredient>(_onAddIngredient);
    on<RemoveIngredient>(_onRemoveIngredient);
    on<UpdateIngredientPercentage>(_onUpdateIngredientPercentage);
    on<ShowCapacityExceededSnackbar>(_onShowCapacityExceededSnackbar);
    on<AnalyzeBlend>(_onAnalyzeBlend);
    on<SaveBlend>(_onSaveBlend);
  }

  void _onInitializeCustomizer(
    InitializeCustomizer event,
    Emitter<CustomizerState> emit,
  ) {
    // Already initialized in initial state
  }

  void _onSelectPacketSize(
    SelectPacketSize event,
    Emitter<CustomizerState> emit,
  ) {
    int newWeight;
    switch (event.packetSize) {
      case PacketSize.kg1:
        newWeight = 1000;
        break;
      case PacketSize.kg3:
        newWeight = 3000;
        break;
      case PacketSize.kg5:
        newWeight = 5000;
        break;
    }

    // Adjust ingredient percentages to ensure weights are multiples of 100g
    final adjustedIngredients = _adjustIngredientsForPacketSize(
      state.selectedIngredients,
      newWeight,
    );

    emit(
      state.copyWith(
        selectedPacketSize: event.packetSize,
        totalWeight: newWeight,
        selectedIngredients: adjustedIngredients,
      ),
    );
  }

  void _onUpdateWheatPercentage(
    UpdateWheatPercentage event,
    Emitter<CustomizerState> emit,
  ) {
    // Find wheat in selected ingredients and update its percentage
    final updatedSelectedIngredients = state.selectedIngredients.map((
      ingredient,
    ) {
      if (ingredient.name == 'Wheat') {
        return Ingredient(
          name: ingredient.name,
          percentage: event.percentage,
          icon: ingredient.icon,
        );
      }
      return ingredient;
    }).toList();

    final newState = state.copyWith(
      selectedIngredients: updatedSelectedIngredients,
      isMaxCapacityReached: _isCapacityReached(updatedSelectedIngredients),
    );

    emit(newState);
  }

  void _onAddIngredient(AddIngredient event, Emitter<CustomizerState> emit) {
    if (state.isMaxCapacityReached) return;

    final remainingPercentage = 1.0 - state.totalPercentage;
    if (remainingPercentage <= 0.1) {
      if (remainingPercentage <= 0) {
        return; // No capacity left
      }
      event = AddIngredient(
        Ingredient(
          name: event.ingredient.name,
          percentage: remainingPercentage,
          icon: event.ingredient.icon,
        ),
      );
    }

    final newSelectedIngredients = [
      ...state.selectedIngredients,
      event.ingredient,
    ];

    final newState = state.copyWith(
      selectedIngredients: newSelectedIngredients,
      isMaxCapacityReached: _isCapacityReached(newSelectedIngredients),
    );

    emit(newState);
  }

  void _onRemoveIngredient(
    RemoveIngredient event,
    Emitter<CustomizerState> emit,
  ) {
    final newSelectedIngredients = state.selectedIngredients
        .where((ingredient) => ingredient.name != event.ingredientName)
        .toList();

    final newState = state.copyWith(
      selectedIngredients: newSelectedIngredients,
      isMaxCapacityReached: _isCapacityReached(newSelectedIngredients),
    );

    emit(newState);
  }

  void _onUpdateIngredientPercentage(
    UpdateIngredientPercentage event,
    Emitter<CustomizerState> emit,
  ) {
    // Calculate what the new total would be
    final currentIngredient = state.selectedIngredients.firstWhere(
      (ingredient) => ingredient.name == event.ingredientName,
    );
    final percentageDifference =
        event.percentage - currentIngredient.percentage;
    final newTotalPercentage = state.totalPercentage + percentageDifference;

    // Use tolerance for floating-point comparison (0.001 = 0.1%)
    const tolerance = 0.001;

    // Check if the new percentage would exceed capacity
    if (newTotalPercentage > (1.0 + tolerance) && percentageDifference > 0) {
      // Don't update - just return without triggering snackbar
      return;
    }

    final newSelectedIngredients = state.selectedIngredients.map((ingredient) {
      if (ingredient.name == event.ingredientName) {
        return Ingredient(
          name: ingredient.name,
          percentage: event.percentage,
          icon: ingredient.icon,
        );
      }
      return ingredient;
    }).toList();

    final newState = state.copyWith(
      selectedIngredients: newSelectedIngredients,
      isMaxCapacityReached: _isCapacityReached(newSelectedIngredients),
    );

    emit(newState);
  }

  double _calculateTotalPercentage(List<Ingredient> selectedIngredients) {
    double total = 0;
    for (final ingredient in selectedIngredients) {
      total += ingredient.percentage;
    }
    return total;
  }

  // Helper method to check if capacity is reached with tolerance
  bool _isCapacityReached(List<Ingredient> selectedIngredients) {
    const tolerance = 0.001; // 0.1% tolerance for floating-point precision
    return _calculateTotalPercentage(selectedIngredients) >= (1.0 - tolerance);
  }

  void _onShowCapacityExceededSnackbar(
    ShowCapacityExceededSnackbar event,
    Emitter<CustomizerState> emit,
  ) {
    emit(
      state.copyWith(
        error: 'Blend over capacity! Remove ingredients or reduce percentages.',
      ),
    );

    // Clear the error message after a delay
    Future.delayed(const Duration(milliseconds: 100), () {
      emit(state.copyWith(error: null));
    });
  }

  Future<void> _onAnalyzeBlend(
    AnalyzeBlend event,
    Emitter<CustomizerState> emit,
  ) async {
    emit(state.copyWith(isAnalyzing: true, clearError: true));

    final start = DateTime.now();
    const minDuration = Duration(seconds: 8); // ensure animation visible

    BlendAnalysisEntity? successfulAnalysis;
    String? failureMessage;

    try {
      // Prepare ingredients map with weights in grams
      final ingredientsMap = <String, int>{};
      for (final ingredient in state.selectedIngredients) {
        final weight = (ingredient.percentage * state.totalWeight).round();
        final name = ingredient.name.toLowerCase() == 'malta'
            ? 'joo'
            : ingredient.name.toLowerCase();
        ingredientsMap[name] = weight;
      }
      // Fill any remainder into wheat if present, otherwise the first ingredient
      final totalMapped = ingredientsMap.values.fold(0, (a, b) => a + b);
      if (totalMapped < state.totalWeight && ingredientsMap.isNotEmpty) {
        final remainder = state.totalWeight - totalMapped;
        if (ingredientsMap.containsKey('wheat')) {
          ingredientsMap['wheat'] = (ingredientsMap['wheat'] ?? 0) + remainder;
        } else {
          final firstKey = ingredientsMap.keys.first;
          ingredientsMap[firstKey] =
              (ingredientsMap[firstKey] ?? 0) + remainder;
        }
      }

      logger.i('Analyzing blend with ingredients: $ingredientsMap');

      final blendRequest = BlendRequestEntity(
        ingredients: ingredientsMap,
        totalWeightG: state.totalWeight,
      );

      final result = await customizerRepository.analyzeBlend(blendRequest);
      result.fold(
        (failure) => failureMessage = failure.message,
        (analysis) => successfulAnalysis = analysis,
      );
    } catch (e) {
      failureMessage = 'Failed to analyze blend: $e';
    } finally {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDuration) {
        final remaining = minDuration - elapsed;
        await Future.delayed(remaining);
      }
      if (failureMessage != null) {
        emit(state.copyWith(isAnalyzing: false, error: failureMessage));
      } else {
        emit(
          state.copyWith(
            isAnalyzing: false,
            analysisResult: successfulAnalysis,
          ),
        );
      }
    }
  }

  Future<void> _onSaveBlend(
    SaveBlend event,
    Emitter<CustomizerState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      // Prepare additives list
      final additives = <AdditiveEntity>[];

      // Add all selected ingredients as additives
      for (final ingredient in state.selectedIngredients) {
        additives.add(
          AdditiveEntity(
            ingredient:
                '${ingredient.name.toLowerCase()}_id', // This should be the actual ingredient ID
            percentage: ingredient.percentage * 100,
          ),
        );
      }

      final saveBlendRequest = SaveBlendEntity(
        name: event.blendName,
        additives: additives,
        isPublic: false,
        weightKg: state.totalWeight / 1000,
      );

      final result = await customizerRepository.saveBlend(saveBlendRequest);

      result.fold(
        (failure) =>
            emit(state.copyWith(isSaving: false, error: failure.message)),
        (savedBlend) =>
            emit(state.copyWith(isSaving: false, savedBlend: savedBlend)),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to save blend: $e'));
    }
  }

  /// Adjusts ingredient percentages to ensure weights are multiples of 100g
  /// while maintaining proportions as closely as possible
  List<Ingredient> _adjustIngredientsForPacketSize(
    List<Ingredient> currentIngredients,
    int newTotalWeight,
  ) {
    if (currentIngredients.isEmpty) return currentIngredients;

    // Convert current percentages to weights in grams and round to 100g multiples
    final adjustedIngredients = <Ingredient>[];
    var totalAdjustedWeight = 0;

    // First pass: convert to rounded weights
    final roundedWeights = <int>[];
    for (final ingredient in currentIngredients) {
      final currentWeight = (ingredient.percentage * newTotalWeight).round();
      final roundedWeight = (currentWeight / 100).round() * 100;
      roundedWeights.add(roundedWeight);
      totalAdjustedWeight += roundedWeight;
    }

    // Second pass: distribute remainder to maintain 100% total
    final remainder = newTotalWeight - totalAdjustedWeight;

    if (remainder != 0) {
      // Find the ingredient with the largest rounding error to adjust
      var maxErrorIndex = 0;
      var maxError = 0.0;

      for (int i = 0; i < currentIngredients.length; i++) {
        final originalWeight =
            currentIngredients[i].percentage * newTotalWeight;
        final error = (originalWeight - roundedWeights[i]).abs();
        if (error > maxError) {
          maxError = error;
          maxErrorIndex = i;
        }
      }

      // Adjust the ingredient with the largest error
      if (remainder > 0) {
        // Add remainder in 100g increments
        final increments = (remainder / 100).round();
        roundedWeights[maxErrorIndex] += increments * 100;
      } else {
        // Subtract remainder in 100g increments
        final decrements = (remainder.abs() / 100).round();
        roundedWeights[maxErrorIndex] =
            (roundedWeights[maxErrorIndex] - decrements * 100).clamp(
              100,
              newTotalWeight,
            );
      }
    }

    // Convert back to percentages and create adjusted ingredients
    for (int i = 0; i < currentIngredients.length; i++) {
      final newPercentage = roundedWeights[i] / newTotalWeight;
      adjustedIngredients.add(
        Ingredient(
          name: currentIngredients[i].name,
          percentage: newPercentage,
          icon: currentIngredients[i].icon,
        ),
      );
    }

    return adjustedIngredients;
  }
}
