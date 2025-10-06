import 'package:logger/logger.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/cart/data/datasources/delivery_remote_data_source.dart';
import 'package:one_atta/features/cart/data/models/delivery_info_model.dart';
import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final ApiRequest apiRequest;
  final Logger logger = Logger();

  DeliveryRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<DeliveryInfoEntity?> checkDeliveryByPincode({
    required String pincode,
    required double orderValue,
    required int weight,
    bool isExpress = false,
  }) async {
    final requestData = {
      'pincode': pincode,
      'order_value': orderValue,
      'weight': weight,
      'is_express': isExpress,
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '${ApiEndpoints.delivery}/check-pincode',
      data: requestData,
    );

    return switch (response) {
      ApiSuccess() => () {
        logger.i('Delivery Check Response: ${response.data}');
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as Map<String, dynamic>?;
          if (data != null && data['available'] == true) {
            return DeliveryInfoModel.fromJson(data).toEntity();
          }
        }
        return null;
      }(),
      ApiError() => () {
        // Handle 404 as delivery not available
        if (response.failure is ServerFailure) {
          final serverFailure = response.failure as ServerFailure;
          if (serverFailure.message.contains('not found') ||
              serverFailure.message.contains('404')) {
            return null;
          }
        }
        throw response.failure;
      }(),
    };
  }

  @override
  Future<ZoneInfoEntity> getDeliveryCharges({
    required String pincode,
    required double orderValue,
    required int weight,
    bool isExpress = false,
  }) async {
    final deliveryInfo = await checkDeliveryByPincode(
      pincode: pincode,
      orderValue: orderValue,
      weight: weight,
      isExpress: isExpress,
    );

    if (deliveryInfo == null) {
      throw ServerFailure('Delivery not available for pincode $pincode');
    }

    return deliveryInfo.zoneInfo;
  }

  @override
  Future<bool> isCodAvailable(String pincode) async {
    try {
      // Use a dummy order value and weight for COD check
      final deliveryInfo = await checkDeliveryByPincode(
        pincode: pincode,
        orderValue: 500.0,
        weight: 1000,
        isExpress: false,
      );

      return deliveryInfo?.zoneInfo.codAvailable ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<EtaEntity> getEstimatedDeliveryTime({
    required String pincode,
    bool isExpress = false,
  }) async {
    final deliveryInfo = await checkDeliveryByPincode(
      pincode: pincode,
      orderValue: 500.0,
      weight: 1000,
      isExpress: isExpress,
    );

    if (deliveryInfo == null) {
      throw ServerFailure('Delivery not available for pincode $pincode');
    }

    if (isExpress && deliveryInfo.zoneInfo.expressDelivery.available) {
      // Return express delivery ETA
      return EtaEntity(
        min: deliveryInfo.zoneInfo.expressDelivery.etaMin,
        max: deliveryInfo.zoneInfo.expressDelivery.etaMax,
        display: deliveryInfo.zoneInfo.expressDelivery.etaDisplay,
      );
    }

    return deliveryInfo.zoneInfo.eta;
  }
}
