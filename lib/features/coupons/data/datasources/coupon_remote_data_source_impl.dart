import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/coupons/data/datasources/coupon_remote_data_source.dart';
import 'package:one_atta/features/coupons/data/models/coupon_model.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/coupons';

  CouponRemoteDataSourceImpl({required this.apiRequest});
  @override
  Future<CouponValidationModel> applyCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<CouponItem> items,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/validate',
      data: {
        'coupon_code': couponCode,
        'order_data': {
          'items': items
              .map(
                (item) => {
                  'item_type': item.itemType,
                  'item': item.itemId,
                  'quantity': item.quantity,
                  'total_price': item.totalPrice,
                  'price_per_kg': item.pricePerKg,
                },
              )
              .toList(),
        },
      },
      token: token,
    );

    return switch (response) {
      ApiSuccess() => CouponValidationModel.fromApplyResponse(response.data),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<CouponModel> fetchCouponByCode({
    required String token,
    required String couponCode,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/code/$couponCode',
      token: token,
    );

    return switch (response) {
      ApiSuccess() => CouponModel.fromJson(response.data['data']),
      ApiError() => throw response.failure,
    };
  }
}
