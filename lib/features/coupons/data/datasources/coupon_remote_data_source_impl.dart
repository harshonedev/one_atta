import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/coupons/data/datasources/coupon_remote_data_source.dart';
import 'package:one_atta/features/coupons/data/models/coupon_model.dart';

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/coupons';

  CouponRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<List<CouponModel>> getAvailableCoupons({
    required String token,
    double? orderAmount,
    List<String>? itemIds,
  }) async {
    final queryParams = <String, dynamic>{};

    if (orderAmount != null) {
      queryParams['order_amount'] = orderAmount.toString();
    }

    if (itemIds != null && itemIds.isNotEmpty) {
      queryParams['item_ids'] = itemIds.join(',');
    }

    String url = '$baseUrl/available';
    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      url += '?$query';
    }

    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: url,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List)
                  .map((coupon) => CouponModel.fromJson(coupon))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to get coupons',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<CouponValidationModel> validateCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/check-validity',
      data: {
        'coupon_code': couponCode,
        'order_amount': orderAmount,
        'items': itemIds.map((id) => {'item_id': id}).toList(),
      },
      token: token,
    );

    return switch (response) {
      ApiSuccess() => CouponValidationModel.fromJson(response.data),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<CouponValidationModel> applyCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/validate',
      data: {
        'coupon_code': couponCode,
        'order_amount': orderAmount,
        'cart_items': itemIds
            .map(
              (id) => {
                'item_id': id,
                'item_type':
                    'product', // This might need to be determined based on the item
              },
            )
            .toList(),
      },
      token: token,
    );

    return switch (response) {
      ApiSuccess() => CouponValidationModel.fromJson(response.data),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<CouponModel> getCouponByCode({
    required String token,
    required String couponCode,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/code/$couponCode',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? CouponModel.fromJson(response.data['data'])
            : throw Exception(response.data['message'] ?? 'Coupon not found'),
      ApiError() => throw response.failure,
    };
  }
}
