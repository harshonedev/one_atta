import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/faq/data/datasources/faq_remote_data_source.dart';
import 'package:one_atta/features/faq/data/models/faq_model.dart';

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/faqs';

  FaqRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<List<FaqModel>> getFaqs() async {
    String url = baseUrl;

    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: url,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data']['faqs'] as List)
                  .map((faq) => FaqModel.fromJson(faq))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch FAQs',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<FaqModel>> getFaqsByCategory(String category) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/category/$category',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List)
                  .map((faq) => FaqModel.fromJson(faq))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch FAQs by category',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<FaqModel>> searchFaqs(String searchQuery) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/search?search=$searchQuery',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List)
                  .map((faq) => FaqModel.fromJson(faq))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to search FAQs',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<FaqHelpfulMarkedResponseModel> markFaqAsHelpful(String faqId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/$faqId/helpful',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? FaqHelpfulMarkedResponseModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to mark FAQ as helpful',
              ),
      ApiError() => throw response.failure,
    };
  }
}
