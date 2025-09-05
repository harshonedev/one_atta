import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source.dart';
import 'package:one_atta/features/customizer/data/models/blend_request_model.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_analysis_entity.dart';
import 'package:one_atta/features/customizer/domain/entities/blend_request_entity.dart';
import 'package:one_atta/features/customizer/domain/repositories/customizer_repository.dart';

class CustomizerRepositoryImpl implements CustomizerRepository {
  final CustomizerRemoteDataSource remoteDataSource;
  final logger = Logger();

  CustomizerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BlendAnalysisEntity>> analyzeBlend(
    BlendRequestEntity blendRequest,
  ) async {
    try {
      final blendRequestModel = BlendRequestModel.fromEntity(blendRequest);
      final result = await remoteDataSource.analyzeBlend(blendRequestModel);
      logger.i('Blend analysis result: $result');
      logger.i('Blend analysis result (as entity): ${result.toEntity()}');
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedBlendEntity>> saveBlend(
    SaveBlendEntity saveBlendRequest,
  ) async {
    try {
      final saveBlendModel = SaveBlendModel.fromEntity(saveBlendRequest);
      final result = await remoteDataSource.saveBlend(saveBlendModel);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
