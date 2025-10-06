import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';

abstract class DeliveryRemoteDataSource {
  /// Check delivery availability by pincode via API
  ///
  /// Makes a POST request to `/api/app/delivery/check-pincode`
  ///
  /// [pincode] - The delivery pincode to check
  /// [orderValue] - The total order value in INR
  /// [weight] - The total weight in grams
  /// [isExpress] - Whether express delivery is requested
  ///
  /// Returns [DeliveryInfoEntity] if successful
  /// Throws [ServerException] if the API call fails
  /// Throws [NetworkException] if there's no internet connection
  Future<DeliveryInfoEntity?> checkDeliveryByPincode({
    required String pincode,
    required double orderValue,
    required int weight,
    bool isExpress = false,
  });

  /// Get delivery charges for a specific pincode
  ///
  /// [pincode] - The delivery pincode
  /// [orderValue] - The total order value in INR
  /// [weight] - The total weight in grams
  /// [isExpress] - Whether express delivery is requested
  ///
  /// Returns [ZoneInfoEntity] with delivery charges
  Future<ZoneInfoEntity> getDeliveryCharges({
    required String pincode,
    required double orderValue,
    required int weight,
    bool isExpress = false,
  });

  /// Check COD availability for a pincode
  ///
  /// [pincode] - The delivery pincode to check
  ///
  /// Returns true if COD is available
  Future<bool> isCodAvailable(String pincode);

  /// Get estimated delivery time
  ///
  /// [pincode] - The delivery pincode
  /// [isExpress] - Whether express delivery is requested
  ///
  /// Returns [EtaEntity] with delivery time estimates
  Future<EtaEntity> getEstimatedDeliveryTime({
    required String pincode,
    bool isExpress = false,
  });
}
