import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';

abstract class CustomizerRepository {
  /// Analyze a custom blend using AI
  Future<Either<Failure, BlendAnalysisEntity>> analyzeBlend(
    BlendRequestEntity blendRequest,
  );

  /// Save a custom blend
  Future<Either<Failure, SavedBlendEntity>> saveBlend(
    SaveBlendEntity saveBlendRequest,
  );
}
