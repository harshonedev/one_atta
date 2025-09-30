import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/address/data/datasources/address_remote_data_source.dart';
import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = ApiEndpoints.addresses;

  AddressRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<AddressModel> createAddress({
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
  }) async {
    final requestData = {
      'label': label,
      'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (landmark != null) 'landmark': landmark,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      if (country != null) 'country': country,
      'recipient_name': recipientName,
      'primary_phone': primaryPhone,
      if (secondaryPhone != null) 'secondary_phone': secondaryPhone,
      if (geo != null)
        'geo': {'type': geo.type, 'coordinates': geo.coordinates},
      if (isDefault != null) 'is_default': isDefault,
      if (instructions != null) 'instructions': instructions,
    };

    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: baseUrl,
      data: requestData,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AddressModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to create address',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<AddressModel>> getAllAddresses({required String token}) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: baseUrl,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List<dynamic>)
                  .map((address) => AddressModel.fromJson(address))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch addresses',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AddressModel> getAddressById(
    String addressId, {
    required String token,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$addressId',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AddressModel.fromJson(response.data['data'])
            : throw Exception(response.data['message'] ?? 'Address not found'),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AddressModel> updateAddress({
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
  }) async {
    final requestData = <String, dynamic>{};

    if (label != null) requestData['label'] = label;
    if (addressLine1 != null) requestData['address_line1'] = addressLine1;
    if (addressLine2 != null) requestData['address_line2'] = addressLine2;
    if (landmark != null) requestData['landmark'] = landmark;
    if (city != null) requestData['city'] = city;
    if (state != null) requestData['state'] = state;
    if (postalCode != null) requestData['postal_code'] = postalCode;
    if (country != null) requestData['country'] = country;
    if (recipientName != null) requestData['recipient_name'] = recipientName;
    if (primaryPhone != null) requestData['primary_phone'] = primaryPhone;
    if (secondaryPhone != null) requestData['secondary_phone'] = secondaryPhone;
    if (geo != null) {
      requestData['geo'] = {'type': geo.type, 'coordinates': geo.coordinates};
    }
    if (isDefault != null) requestData['is_default'] = isDefault;
    if (instructions != null) requestData['instructions'] = instructions;

    final response = await apiRequest.callRequest(
      method: HttpMethod.put,
      url: '$baseUrl/$addressId',
      data: requestData,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AddressModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to update address',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AddressModel> deleteAddress(
    String addressId, {
    required String token,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.delete,
      url: '$baseUrl/$addressId',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AddressModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to delete address',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AddressModel> setDefaultAddress(
    String addressId, {
    required String token,
  }) async {
    final requestData = <String, dynamic>{};

    requestData['is_default'] = true;

    final response = await apiRequest.callRequest(
      method: HttpMethod.put,
      url: '$baseUrl/$addressId',
      data: requestData,
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AddressModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to update address',
              ),
      ApiError() => throw response.failure,
    };
  }
}
