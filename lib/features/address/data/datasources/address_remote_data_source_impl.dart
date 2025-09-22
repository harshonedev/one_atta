import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/address/data/datasources/address_remote_data_source.dart';
import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio dio;
  static const String baseUrl = ApiEndpoints.addresses;
  final Logger logger = Logger();

  AddressRemoteDataSourceImpl({required this.dio});

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
    try {
      // Get authentication token
      dio.options.headers['Authorization'] = "Bearer $token";

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

      // Debug log to understand what data is being sent
      logger.i('🐛 DEBUG: Creating address with data: $requestData');

      final response = await dio.post(baseUrl, data: requestData);
      logger.i(
        '🐛 DEBUG: Response status: ${response.statusCode}, data: ${response.data}',
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data['success'] == true) {
        // Check if the response structure is as expected
        final addressData = response.data['data'];
        if (addressData == null) {
          logger.e('Response data is null');
          throw ServerFailure('Invalid response structure: missing data field');
        }

        // The address data is directly in the 'data' field, not nested under 'address'
        if (addressData is! Map<String, dynamic>) {
          logger.e('Invalid address data structure: $addressData');
          throw ServerFailure('Invalid response structure: data is not a Map');
        }

        logger.i('🐛 DEBUG: Parsing address from: $addressData');
        return AddressModel.fromJson(addressData);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to create address';
        logger.e(
          'Server error: $errorMessage (Status: ${response.statusCode})',
        );
        throw ServerFailure(errorMessage);
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
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AddressModel>> getAllAddresses({required String token}) async {
    try {
      // Get authentication token
      dio.options.headers['Authorization'] = "Bearer $token";

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
  Future<AddressModel> getAddressById(
    String addressId, {
    required String token,
  }) async {
    try {
      // Get authentication token

      dio.options.headers['Authorization'] = "Bearer $token";

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
    try {
      // Get authentication token
      dio.options.headers['Authorization'] = "Bearer $token";

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
      if (secondaryPhone != null) {
        updateData['secondary_phone'] = secondaryPhone;
      }
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
  Future<AddressModel> deleteAddress(
    String addressId, {
    required String token,
  }) async {
    try {
      // Get authentication token
      dio.options.headers['Authorization'] = "Bearer $token";

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

  @override
  Future<AddressModel> setDefaultAddress(
    String addressId, {
    required String token,
  }) async {
    try {
      // Get authentication token
      dio.options.headers['Authorization'] = "Bearer $token";
      final Map<String, dynamic> updateData = {'is_default': true};

      logger.i('Setting address as default: $addressId');

      final response = await dio.put('$baseUrl/$addressId', data: updateData);

      logger.i('Set default address response: ${response.data}');

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
          e.response?.data?['message'] ?? 'Failed to set default address';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
