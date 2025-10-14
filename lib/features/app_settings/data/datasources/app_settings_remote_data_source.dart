import 'package:one_atta/features/app_settings/data/models/app_settings_model.dart';

abstract class AppSettingsRemoteDataSource {
  Future<AppSettingsModel> getAppSettings();
}
