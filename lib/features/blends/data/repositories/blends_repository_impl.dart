import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/blends/data/datasources/blends_remote_data_source.dart';
import 'package:one_atta/features/blends/data/models/blend_request_model.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/domain/entities/blend_request_entity.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';

class BlendsRepositoryImpl implements BlendsRepository {
  final BlendsRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  BlendsRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, List<PublicBlendEntity>>> getAllPublicBlends() async {
    try {
      final result = await remoteDataSource.getAllPublicBlends();
      return Right(result.map((blend) => blend.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, BlendEntity>> createBlend(
    CreateBlendEntity blend,
  ) async {
    try {
      final blendModel = CreateBlendModel.fromEntity(blend);
      final result = await remoteDataSource.createBlend(blendModel);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, BlendDetailsEntity>> getBlendDetails(String id) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      final result = await remoteDataSource.getBlendDetails(id, token);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> shareBlend(String id) async {
    try {
      final result = await remoteDataSource.shareBlend(id);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToBlend(String id) async {
    try {
      await remoteDataSource.subscribeToBlend(id);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, BlendEntity>> updateBlend(
    String id,
    UpdateBlendEntity blend,
  ) async {
    try {
      final blendModel = UpdateBlendModel.fromEntity(blend);
      final result = await remoteDataSource.updateBlend(id, blendModel);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, PublicBlendEntity>> getBlendByShareCode(
    String shareCode,
  ) async {
    try {
      final result = await remoteDataSource.getBlendByShareCode(shareCode);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
