import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/refunds/data/models/refund_model.dart';

abstract class RefundRemoteDataSource {
  Future<RefundModel?> getRefundByOrderId(String token, String orderId);
}

class RefundRemoteDataSourceImpl implements RefundRemoteDataSource {
  final ApiRequest apiRequest;

  RefundRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<RefundModel?> getRefundByOrderId(String token, String orderId) async {
    try {
      final response = await apiRequest.callRequest(
        method: HttpMethod.get,
        url: '${ApiEndpoints.refunds}/order/$orderId',
        token: token,
      );

      return switch (response) {
        ApiSuccess() =>
          response.data['success'] == true && response.data['data'] != null
              ? RefundModel.fromJson(
                  response.data['data'] as Map<String, dynamic>,
                )
              : null,
        ApiError() => null, // No refund found
      };
    } catch (e) {
      return null; // Return null if refund doesn't exist
    }
  }
}
