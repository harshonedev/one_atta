import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/app_settings/domain/entities/app_settings_entity.dart';

abstract class AppSettingsRepository {
  // Get public app settings (no auth required)
  Future<Either<Failure, AppSettingsEntity>> getAppSettings();
}
