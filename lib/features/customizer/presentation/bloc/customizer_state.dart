part of 'customizer_bloc.dart';

// State
class CustomizerState extends Equatable {
  final PacketSize selectedPacketSize;
  final int totalWeight; // in grams
  final List<Ingredient> availableIngredients;
  final List<Ingredient> selectedIngredients;
  final bool isMaxCapacityReached;
  final bool isAnalyzing;
  final bool isSaving;
  final bool isLoadingIngredients;
  final BlendAnalysisEntity? analysisResult;
  final SavedBlendEntity? savedBlend;
  final List<BlendEntity> userBlends;
  final UserEntity? currentUser;
  final String? error;

  const CustomizerState({
    required this.selectedPacketSize,
    required this.totalWeight,
    required this.availableIngredients,
    required this.selectedIngredients,
    required this.isMaxCapacityReached,
    this.isAnalyzing = false,
    this.isSaving = false,
    this.isLoadingIngredients = false,
    this.analysisResult,
    this.savedBlend,
    this.userBlends = const [],
    this.currentUser,
    this.error,
  });

  factory CustomizerState.initial() {
    return CustomizerState(
      selectedPacketSize: PacketSize.kg1,
      totalWeight: 1000, // 1kg in grams
      availableIngredients: [],
      selectedIngredients: [],
      isMaxCapacityReached: false,
      isLoadingIngredients: true,
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
    bool? isLoadingIngredients,
    BlendAnalysisEntity? analysisResult,
    SavedBlendEntity? savedBlend,
    List<BlendEntity>? userBlends,
    UserEntity? currentUser,
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
      isLoadingIngredients: isLoadingIngredients ?? this.isLoadingIngredients,
      analysisResult: clearAnalysisResult
          ? null
          : (analysisResult ?? this.analysisResult),
      savedBlend: clearSavedBlend ? null : (savedBlend ?? this.savedBlend),
      userBlends: userBlends ?? this.userBlends,
      currentUser: currentUser ?? this.currentUser,
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
    isLoadingIngredients,
    analysisResult,
    savedBlend,
    userBlends,
    currentUser,
    error,
  ];
}

enum PacketSize { kg1, kg3, kg5 }
