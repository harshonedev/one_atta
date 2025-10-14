import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:one_atta/features/feedback/data/models/feedback_model.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/feedback';

  FeedbackRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<FeedbackModel> submitFeedback({
    required String subject,
    required String message,
    required String token,
    String category = 'other',
    String priority = 'medium',
    List<FeedbackAttachment>? attachments,
  }) async {
    final data = {
      'subject': subject,
      'message': message,
      'category': category,
      'priority': priority,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments
            .map((a) => {'url': a.url, 'type': a.type})
            .toList(),
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: baseUrl,
      data: data,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? FeedbackModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to submit feedback',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<FeedbackModel>> getUserFeedbackHistory({
    required String token,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    String url = '$baseUrl?page=$page&limit=$limit';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: url,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data']['feedback'] as List)
                  .map((fb) => FeedbackModel.fromJson(fb))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch feedback history',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<FeedbackModel> getFeedbackById({
    required String feedbackId,
    required String token,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$feedbackId',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? FeedbackModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch feedback',
              ),
      ApiError() => throw response.failure,
    };
  }
}
