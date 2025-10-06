import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/data/datasources/delivery_remote_data_source.dart';
import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';
import 'package:one_atta/features/cart/domain/services/delivery_service.dart';

class DeliveryServiceImpl implements DeliveryService {
  final DeliveryRemoteDataSource remoteDataSource;

  DeliveryServiceImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DeliveryInfoEntity?>> checkDeliveryAvailability({
    required String pincode,
    required double orderValue,
    int weight = 1000,
    bool isExpress = false,
  }) async {
    try {
      final result = await remoteDataSource.checkDeliveryByPincode(
        pincode: pincode,
        orderValue: orderValue,
        weight: weight,
        isExpress: isExpress,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ZoneInfoEntity>> calculateDeliveryCharges({
    required String pincode,
    required double orderValue,
    int weight = 1000,
    bool isExpress = false,
  }) async {
    try {
      final result = await remoteDataSource.getDeliveryCharges(
        pincode: pincode,
        orderValue: orderValue,
        weight: weight,
        isExpress: isExpress,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isCodAvailable(String pincode) async {
    try {
      final result = await remoteDataSource.isCodAvailable(pincode);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EtaEntity>> getDeliveryEta({
    required String pincode,
    bool isExpress = false,
  }) async {
    try {
      final result = await remoteDataSource.getEstimatedDeliveryTime(
        pincode: pincode,
        isExpress: isExpress,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFreeDeliveryApplicable({
    required String pincode,
    required double orderValue,
  }) async {
    try {
      final deliveryInfo = await remoteDataSource.checkDeliveryByPincode(
        pincode: pincode,
        orderValue: orderValue,
        weight: 1000,
        isExpress: false,
      );

      if (deliveryInfo == null) {
        return const Right(false);
      }

      return Right(deliveryInfo.zoneInfo.isFreeDelivery);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getFreeDeliveryThreshold(
    String pincode,
  ) async {
    try {
      final deliveryInfo = await remoteDataSource.checkDeliveryByPincode(
        pincode: pincode,
        orderValue: 100.0, // Dummy order value for threshold check
        weight: 1000,
        isExpress: false,
      );

      if (deliveryInfo == null) {
        throw const ServerException(
          message: 'Delivery not available for this pincode',
        );
      }

      return Right(deliveryInfo.zoneInfo.freeDeliveryThreshold);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
