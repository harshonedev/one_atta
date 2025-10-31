import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:one_atta/features/contact/data/models/contact_model.dart';

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/contact';

  ContactRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<ContactModel> getContactDetails() async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: baseUrl,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? ContactModel.fromJson(
                response.data['data'] as Map<String, dynamic>,
              )
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch contact details',
              ),
      ApiError() => throw response.failure,
    };
  }
}
