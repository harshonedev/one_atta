import 'package:one_atta/features/blends/data/models/blend_model.dart';
import 'package:one_atta/features/blends/data/models/blend_request_model.dart';

abstract class BlendsRemoteDataSource {
  /// Get all public blends
  Future<List<PublicBlendModel>> getAllPublicBlends();

  /// Create a new blend
  Future<BlendModel> createBlend(CreateBlendModel blend);

  /// Get blend details with price analysis
  Future<BlendDetailsModel> getBlendDetails(String id, String token);

  /// Share a blend
  Future<String> shareBlend(String id);

  /// Subscribe to a blend
  Future<void> subscribeToBlend(String id);

  /// Update a blend
  Future<BlendModel> updateBlend(String id, UpdateBlendModel blend);

  /// Get blend by share code
  Future<PublicBlendModel> getBlendByShareCode(String shareCode);
}
