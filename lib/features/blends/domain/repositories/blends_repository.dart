import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/domain/entities/blend_request_entity.dart';

abstract class BlendsRepository {
  /// Get all public blends
  Future<Either<Failure, List<PublicBlendEntity>>> getAllPublicBlends();

  /// Create a new blend
  Future<Either<Failure, BlendEntity>> createBlend(CreateBlendEntity blend);

  /// Get blend details with price analysis
  Future<Either<Failure, BlendDetailsEntity>> getBlendDetails(String id);

  /// Share a blend
  Future<Either<Failure, String>> shareBlend(String id);

  /// Subscribe to a blend
  Future<Either<Failure, void>> subscribeToBlend(String id);

  /// Update a blend
  Future<Either<Failure, BlendEntity>> updateBlend(
    String id,
    UpdateBlendEntity blend,
  );

  /// Get blend by share code
  Future<Either<Failure, PublicBlendEntity>> getBlendByShareCode(
    String shareCode,
  );

  /// Get user's own blends
  Future<Either<Failure, List<BlendEntity>>> getUserBlends();
}
