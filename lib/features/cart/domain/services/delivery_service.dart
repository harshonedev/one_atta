import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';

/// Service for handling delivery-related operations in the cart
/// This provides a direct interface for the cart bloc without usecases
abstract class DeliveryService {
  /// Check if delivery is available for a pincode and get delivery information
  ///
  /// [pincode] - The delivery pincode to check
  /// [orderValue] - The total order value in INR
  /// [weight] - The total weight in grams (optional, defaults to 1000g)
  /// [isExpress] - Whether express delivery is requested (optional, defaults to false)
  ///
  /// Returns [DeliveryInfoEntity] if delivery is available,
  /// Returns null if delivery is not available,
  /// Returns [Failure] if an error occurs
  Future<Either<Failure, DeliveryInfoEntity?>> checkDeliveryAvailability({
    required String pincode,
    required double orderValue,
    int weight = 1000,
    bool isExpress = false,
  });

  /// Calculate delivery charges for current cart
  ///
  /// [pincode] - The delivery pincode
  /// [orderValue] - The total cart value
  /// [weight] - The total cart weight (optional)
  /// [isExpress] - Whether express delivery is requested
  ///
  /// Returns [ZoneInfoEntity] with delivery charges and details
  Future<Either<Failure, ZoneInfoEntity>> calculateDeliveryCharges({
    required String pincode,
    required double orderValue,
    int weight = 1000,
    bool isExpress = false,
  });

  /// Check if Cash on Delivery (COD) is available for a pincode
  ///
  /// [pincode] - The delivery pincode to check
  ///
  /// Returns true if COD is available, false otherwise
  Future<Either<Failure, bool>> isCodAvailable(String pincode);

  /// Get estimated delivery time for a pincode
  ///
  /// [pincode] - The delivery pincode
  /// [isExpress] - Whether express delivery is requested
  ///
  /// Returns [EtaEntity] with delivery time estimates
  Future<Either<Failure, EtaEntity>> getDeliveryEta({
    required String pincode,
    bool isExpress = false,
  });

  /// Check if free delivery is applicable for current order
  ///
  /// [pincode] - The delivery pincode
  /// [orderValue] - The total order value
  ///
  /// Returns true if free delivery is applicable
  Future<Either<Failure, bool>> isFreeDeliveryApplicable({
    required String pincode,
    required double orderValue,
  });

  /// Get the minimum order value required for free delivery
  ///
  /// [pincode] - The delivery pincode
  ///
  /// Returns the free delivery threshold amount
  Future<Either<Failure, double>> getFreeDeliveryThreshold(String pincode);
}
