import 'package:one_atta/features/blends/data/models/blend_model.dart';
import 'package:one_atta/features/blends/data/models/blend_request_model.dart';

abstract class BlendsRemoteDataSource {
  /// Get all public blends
  Future<List<PublicBlendModel>> getAllPublicBlends();

  /// Create a new blend
  Future<BlendModel> createBlend(CreateBlendModel blend);

  /// Get blend details with price analysis
  Future<BlendDetailsModel> getBlendDetails(String id, String token);

  /// Get user's own blends
  Future<List<BlendModel>> getUserBlends(String token);
}
