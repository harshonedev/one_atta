import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/app_settings/data/datasources/app_settings_remote_data_source.dart';
import 'package:one_atta/features/app_settings/domain/entities/app_settings_entity.dart';
import 'package:one_atta/features/app_settings/domain/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsRemoteDataSource remoteDataSource;

  AppSettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppSettingsEntity>> getAppSettings() async {
    try {
      final result = await remoteDataSource.getAppSettings();
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch app settings: $e'));
    }
  }
}
