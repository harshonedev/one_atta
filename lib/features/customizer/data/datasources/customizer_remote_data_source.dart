import 'package:one_atta/features/customizer/data/models/blend_analysis_model.dart';
import 'package:one_atta/features/customizer/data/models/blend_request_model.dart';
import 'package:one_atta/features/customizer/data/models/ingredient_model.dart';

abstract class CustomizerRemoteDataSource {
  /// Analyze a custom blend using AI
  Future<BlendAnalysisModel> analyzeBlend(BlendRequestModel blendRequest);

  /// Save a custom blend
  Future<SavedBlendModel> saveBlend(SaveBlendModel saveBlendRequest);

  /// Fetch all available ingredients
  Future<List<IngredientModel>> getIngredients();
}
