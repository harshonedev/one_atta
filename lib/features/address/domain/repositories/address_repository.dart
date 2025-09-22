import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

abstract class AddressRepository {
  /// Creates a new address for the authenticated user
  Future<Either<Failure, AddressEntity>> createAddress({
    required String token,
    required String label,
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String postalCode,
    String? country,
    required String recipientName,
    required String primaryPhone,
    String? secondaryPhone,
    GeoLocation? geo,
    bool? isDefault,
    String? instructions,
  });

  /// Fetches all non-deleted addresses for the authenticated user
  Future<Either<Failure, List<AddressEntity>>> getAllAddresses({
    required String token
  });

  /// Fetches a specific address by its ID for the authenticated user
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId, {required String token});

  /// Updates an existing address for the authenticated user
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String token,
    required String addressId,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? recipientName,
    String? primaryPhone,
    String? secondaryPhone,
    GeoLocation? geo,
    bool? isDefault,
    String? instructions,
  });

  /// Soft deletes an address (marks as deleted) for the authenticated user
  Future<Either<Failure, AddressEntity>> deleteAddress(String addressId, {
    required String token
  });
}
