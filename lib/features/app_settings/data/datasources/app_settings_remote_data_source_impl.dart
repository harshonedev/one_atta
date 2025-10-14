import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/app_settings/data/datasources/app_settings_remote_data_source.dart';
import 'package:one_atta/features/app_settings/data/models/app_settings_model.dart';

class AppSettingsRemoteDataSourceImpl implements AppSettingsRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/app-settings';

  AppSettingsRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<AppSettingsModel> getAppSettings() async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: baseUrl,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AppSettingsModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch app settings',
              ),
      ApiError() => throw response.failure,
    };
  }
}
