import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

abstract class AddressRemoteDataSource {
  /// Creates a new address for the authenticated user
  Future<AddressModel> createAddress({
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
  Future<List<AddressModel>> getAllAddresses();

  /// Fetches a specific address by its ID for the authenticated user
  Future<AddressModel> getAddressById(String addressId);

  /// Updates an existing address for the authenticated user
  Future<AddressModel> updateAddress({
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
  Future<AddressModel> deleteAddress(String addressId);
}
