import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/address/data/datasources/address_remote_data_source.dart';
import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio dio;
  static const String baseUrl = ApiEndpoints.addresses;

  AddressRemoteDataSourceImpl({required this.dio});

  @override
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
  }) async {
    try {
      // Create a temporary model to use toCreateJson method
      final tempModel = AddressModel(
        id: '',
        userId: '',
        label: label,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        landmark: landmark,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country ?? 'India',
        recipientName: recipientName,
        primaryPhone: primaryPhone,
        secondaryPhone: secondaryPhone,
        geo: geo,
        isDefault: isDefault ?? false,
        instructions: instructions,
        deleted: false,
        fullAddress: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await dio.post(baseUrl, data: tempModel.toCreateJson());

      if (response.statusCode == 201 && response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to create address',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to create address';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AddressModel>> getAllAddresses() async {
    try {
      final response = await dio.get(baseUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> addressesData = response.data['data'];
        return addressesData
            .map((addressJson) => AddressModel.fromJson(addressJson))
            .toList();
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch addresses',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch addresses';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AddressModel> getAddressById(String addressId) async {
    try {
      final response = await dio.get('$baseUrl/$addressId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch address',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message = e.response?.data?['message'] ?? 'Failed to fetch address';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
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
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      // Add only non-null fields to the update data
      if (label != null) updateData['label'] = label;
      if (addressLine1 != null) updateData['address_line1'] = addressLine1;
      if (addressLine2 != null) updateData['address_line2'] = addressLine2;
      if (landmark != null) updateData['landmark'] = landmark;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (postalCode != null) updateData['postal_code'] = postalCode;
      if (country != null) updateData['country'] = country;
      if (recipientName != null) updateData['recipient_name'] = recipientName;
      if (primaryPhone != null) updateData['primary_phone'] = primaryPhone;
      if (secondaryPhone != null)
        updateData['secondary_phone'] = secondaryPhone;
      if (geo != null) {
        updateData['geo'] = {'type': geo.type, 'coordinates': geo.coordinates};
      }
      if (isDefault != null) updateData['is_default'] = isDefault;
      if (instructions != null) updateData['instructions'] = instructions;

      final response = await dio.put('$baseUrl/$addressId', data: updateData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to update address',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to update address';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AddressModel> deleteAddress(String addressId) async {
    try {
      final response = await dio.delete('$baseUrl/$addressId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to delete address',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to delete address';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
