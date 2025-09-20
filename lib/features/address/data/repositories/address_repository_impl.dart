import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/address/data/datasources/address_remote_data_source.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/address/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
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
      final result = await remoteDataSource.createAddress(
        label: label,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        landmark: landmark,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        recipientName: recipientName,
        primaryPhone: primaryPhone,
        secondaryPhone: secondaryPhone,
        geo: geo,
        isDefault: isDefault,
        instructions: instructions,
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> getAllAddresses() async {
    try {
      final result = await remoteDataSource.getAllAddresses();
      final entities = result.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(
    String addressId,
  ) async {
    try {
      final result = await remoteDataSource.getAddressById(addressId);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
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
      final result = await remoteDataSource.updateAddress(
        addressId: addressId,
        label: label,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        landmark: landmark,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        recipientName: recipientName,
        primaryPhone: primaryPhone,
        secondaryPhone: secondaryPhone,
        geo: geo,
        isDefault: isDefault,
        instructions: instructions,
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> deleteAddress(String addressId) async {
    try {
      final result = await remoteDataSource.deleteAddress(addressId);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
