import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/customizer/presentation/models/ingredient.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';
import 'package:one_atta/features/customizer/domain/repositories/customizer_repository.dart';
import 'package:one_atta/features/customizer/domain/usecases/get_ingredients.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

part 'customizer_event.dart';
part 'customizer_state.dart';

// Bloc
class CustomizerBloc extends Bloc<CustomizerEvent, CustomizerState> {
  final CustomizerRepository customizerRepository;
  final GetIngredientsUseCase getIngredientsUseCase;
  final BlendsRepository blendsRepository;
  final AuthRepository authRepository;
  final Logger logger = Logger();

  CustomizerBloc({
    required this.customizerRepository,
    required this.getIngredientsUseCase,
    required this.blendsRepository,
    required this.authRepository,
  }) : super(CustomizerState.initial()) {
    on<InitializeCustomizer>(_onInitializeCustomizer);
    on<LoadIngredients>(_onLoadIngredients);
    on<SelectPacketSize>(_onSelectPacketSize);
    on<UpdateWheatPercentage>(_onUpdateWheatPercentage);
    on<AddIngredient>(_onAddIngredient);
    on<RemoveIngredient>(_onRemoveIngredient);
    on<UpdateIngredientPercentage>(_onUpdateIngredientPercentage);
    on<ShowCapacityExceededSnackbar>(_onShowCapacityExceededSnackbar);
    on<AnalyzeBlend>(_onAnalyzeBlend);
    on<SaveBlend>(_onSaveBlend);
    on<LoadUserBlends>(_onLoadUserBlends);
    on<SaveBlendAndAddToCart>(_onSaveBlendAndAddToCart);
  }

  void _onInitializeCustomizer(
    InitializeCustomizer event,
    Emitter<CustomizerState> emit,
  ) {
    // Already initialized in initial state
  }

  void _onLoadIngredients(
    LoadIngredients event,
    Emitter<CustomizerState> emit,
  ) async {
    emit(state.copyWith(isLoadingIngredients: true));

    final result = await getIngredientsUseCase();

    result.fold(
      (failure) {
        logger.e('Failed to load ingredients: ${failure.toString()}');
        emit(
          state.copyWith(
            isLoadingIngredients: false,
            error: failure.toString(),
          ),
        );
      },
      (ingredientEntities) {
        logger.i(
          'Successfully loaded ${ingredientEntities.length} ingredients',
        );

        // Convert entities to presentation models
        final ingredients = ingredientEntities.map((entity) {
          return Ingredient(
            id: entity.id,
            name: entity.name,
            percentage: 0,
            icon: _getIconForIngredient(
              entity.name,
            ), // Helper method to get icon
            nutritionalInfo: entity.nutritionalInfo,
          );
        }).toList();

        // Start with wheat at a reasonable percentage to allow room for other ingredients
        final wheatIngredient = ingredients
            .firstWhere(
              (i) => i.name.toLowerCase() == 'wheat',
              orElse: () => ingredients.first,
            )
            .copyWith(
              percentage: 0.3,
            ); // 30% to leave room for other ingredients

        final isAlreadySelected = state.selectedIngredients.isNotEmpty;
        emit(
          state.copyWith(
            isLoadingIngredients: false,
            availableIngredients: ingredients,
            selectedIngredients: isAlreadySelected
                ? state.selectedIngredients
                : [wheatIngredient],
            isMaxCapacityReached: false, // Explicitly set to false initially
            clearError: true,
          ),
        );
      },
    );
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

    final ingredients = state.selectedIngredients.map((ingredient) {
      final weightInGrams = (ingredient.percentage * newWeight).round();
      final adjustedPercentage = weightInGrams % 100 == 0
          ? ingredient.percentage
          : (weightInGrams - (weightInGrams % 100)) / newWeight;
      return ingredient.copyWith(percentage: adjustedPercentage);
    }).toList();

    emit(
      state.copyWith(
        selectedPacketSize: event.packetSize,
        totalWeight: newWeight,
        selectedIngredients: ingredients,
        isMaxCapacityReached: _isCapacityReached(ingredients),
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
      if (ingredient.name.toLowerCase() == 'wheat') {
        return ingredient.copyWith(percentage: event.percentage);
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
    // Calculate current total percentage
    final currentTotalPercentage = state.totalPercentage;

    // Check if we have room for the new ingredient (with tolerance for floating point precision)
    const tolerance = 0.001; // 0.1% tolerance
    final remainingPercentage = 1.0 - currentTotalPercentage;

    // If there's no room left (less than 0.1%), don't add
    if (remainingPercentage < tolerance) {
      // Trigger capacity exceeded message
      add(ShowCapacityExceededSnackbar());
      return;
    }

    // Set smart default percentage based on available space
    var ingredientToAdd = event.ingredient;
    const minPercentage = 0.05; // 5% minimum

    if (ingredientToAdd.percentage > remainingPercentage) {
      // If the requested percentage exceeds available space, use the remaining space
      final adjustedPercentage = remainingPercentage.clamp(minPercentage, 1.0);
      ingredientToAdd = ingredientToAdd.copyWith(
        percentage: adjustedPercentage,
      );
    } else if (ingredientToAdd.percentage < minPercentage &&
        remainingPercentage >= minPercentage) {
      // If the percentage is too small but we have room for minimum, use minimum
      ingredientToAdd = ingredientToAdd.copyWith(percentage: minPercentage);
    }

    final newSelectedIngredients = [
      ...state.selectedIngredients,
      ingredientToAdd,
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
        return ingredient.copyWith(percentage: event.percentage);
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
    final totalPercentage = _calculateTotalPercentage(selectedIngredients);
    return totalPercentage >= (1.0 - tolerance);
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
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!isClosed) {
        emit(state.copyWith(clearError: true));
      }
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
            savedBlend: null, // Clear any previous saved blend
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
      // Check if we need to generate smart name or validate the provided name
      String finalBlendName = event.blendName;

      // If the default name pattern is used, generate smart name
      if (event.blendName == "My Custom Blend" &&
          state.currentUser != null &&
          state.userBlends.isNotEmpty) {
        finalBlendName = _generateSmartBlendName(
          state.currentUser!,
          state.userBlends,
        );
      }
      // Check if the provided name already exists
      else if (state.userBlends.any(
        (blend) => blend.name.toLowerCase() == event.blendName.toLowerCase(),
      )) {
        emit(
          state.copyWith(
            isSaving: false,
            error:
                'A blend with this name already exists. Please choose a different name.',
          ),
        );
        return;
      }

      // Prepare additives list
      final additives = <AdditiveEntity>[];

      // Add all selected ingredients as additives
      for (final ingredient in state.selectedIngredients) {
        additives.add(
          AdditiveEntity(
            ingredient:
                ingredient.id, // This should be the actual ingredient ID
            percentage: ingredient.percentage * 100,
          ),
        );
      }

      final saveBlendRequest = SaveBlendEntity(
        name: finalBlendName,
        additives: additives,
        isPublic: true,
        weightKg: state.totalWeight / 1000,
      );

      final result = await customizerRepository.saveBlend(saveBlendRequest);

      result.fold(
        (failure) =>
            emit(state.copyWith(isSaving: false, error: failure.message)),
        (savedBlend) => emit(
          state.copyWith(
            isSaving: false,
            savedBlend: savedBlend.copyWith(
              weightKg: state.totalWeight ~/ 1000,
            ),
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to save blend: $e'));
    }
  }

  /// Generate a smart blend name based on username and existing blends count
  String _generateSmartBlendName(
    UserEntity user,
    List<BlendEntity> userBlends,
  ) {
    final userName = user.name;
    final basePattern = "$userName's Blend";

    // Count existing blends with similar pattern
    int maxNumber = 0;
    final regExp = RegExp(r"^" + RegExp.escape(basePattern) + r" (\d+)$");

    for (final blend in userBlends) {
      final match = regExp.firstMatch(blend.name);
      if (match != null) {
        final number = int.tryParse(match.group(1) ?? '') ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }

    return "$basePattern ${maxNumber + 1}";
  }

  Future<void> _onLoadUserBlends(
    LoadUserBlends event,
    Emitter<CustomizerState> emit,
  ) async {
    try {
      // Load current user and user blends in parallel
      final results = await Future.wait([
        authRepository.getCurrentUser(),
        blendsRepository.getUserBlends(),
      ]);

      final userResult = results[0];
      final blendsResult = results[1];

      userResult.fold(
        (failure) => emit(
          state.copyWith(error: 'Failed to get user: ${failure.message}'),
        ),
        (user) => blendsResult.fold(
          (failure) => emit(
            state.copyWith(
              error: 'Failed to load user blends: ${failure.message}',
            ),
          ),
          (blends) => emit(
            state.copyWith(
              currentUser: user as UserEntity?,
              userBlends: blends as List<BlendEntity>,
            ),
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load user data: $e'));
    }
  }

  Future<void> _onSaveBlendAndAddToCart(
    SaveBlendAndAddToCart event,
    Emitter<CustomizerState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      SavedBlendEntity? blendToAddToCart;

      // Check if there's already a saved blend from current analysis
      if (state.savedBlend != null) {
        blendToAddToCart = state.savedBlend;
      } else {
        // Need to save the blend first
        String blendName = event.blendName ?? _generateDefaultBlendName();

        // Check if the provided name already exists
        if (state.userBlends.any(
          (blend) => blend.name.toLowerCase() == blendName.toLowerCase(),
        )) {
          // Generate a unique name by appending number
          int counter = 1;
          String originalName = blendName;
          while (state.userBlends.any(
            (blend) => blend.name.toLowerCase() == blendName.toLowerCase(),
          )) {
            blendName = '$originalName $counter';
            counter++;
          }
        }

        // Prepare additives list
        final additives = <AdditiveEntity>[];
        for (final ingredient in state.selectedIngredients) {
          additives.add(
            AdditiveEntity(
              ingredient: ingredient.id,
              percentage: ingredient.percentage * 100,
            ),
          );
        }

        final saveBlendRequest = SaveBlendEntity(
          name: blendName,
          additives: additives,
          isPublic: true,
          weightKg: state.totalWeight / 1000,
        );

        final result = await customizerRepository.saveBlend(saveBlendRequest);

        await result.fold(
          (failure) async {
            emit(state.copyWith(isSaving: false, error: failure.message));
            return;
          },
          (savedBlend) async {
            blendToAddToCart = savedBlend;
            emit(state.copyWith(savedBlend: savedBlend));
          },
        );
      }

      // Now add to cart (this will be handled by the UI layer)
      if (blendToAddToCart != null) {
        emit(
          state.copyWith(
            isSaving: false,
            savedBlend: blendToAddToCart,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: 'Failed to save blend and add to cart: $e',
        ),
      );
    }
  }

  String _generateDefaultBlendName() {
    if (state.currentUser != null) {
      return _generateSmartBlendName(state.currentUser!, state.userBlends);
    }
    return 'My Custom Blend';
  }

  /// Helper method to get appropriate icon for ingredient name
  IconData _getIconForIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();

    if (name.contains('wheat') || name.contains('atta')) {
      return MdiIcons.grain;
    } else if (name.contains('chana') || name.contains('gram')) {
      return MdiIcons.seed;
    } else if (name.contains('makka') || name.contains('corn')) {
      return MdiIcons.corn;
    } else if (name.contains('bajra') || name.contains('millet')) {
      return MdiIcons.barley;
    } else if (name.contains('malt')) {
      return MdiIcons.grain;
    } else if (name.contains('ragi') || name.contains('finger')) {
      return MdiIcons.seedOutline;
    } else if (name.contains('rice')) {
      return MdiIcons.rice;
    } else if (name.contains('oat')) {
      return MdiIcons.grain;
    } else if (name.contains('barley')) {
      return MdiIcons.barley;
    } else if (name.contains('quinoa')) {
      return MdiIcons.seed;
    } else if (name.contains('almond')) {
      return MdiIcons.peanut;
    } else {
      return MdiIcons.grain; // Default fallback icon
    }
  }
}
