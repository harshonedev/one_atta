import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';
import 'package:one_atta/features/coupons/data/datasources/coupon_remote_data_source.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';
import 'package:one_atta/features/coupons/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;
  final Logger logger = Logger();

  CouponRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, List<CouponEntity>>> getAvailableCoupons({
    double? orderAmount,
    List<String>? itemIds,
  }) async {
    try {
      final tokenResult = await authRepository.getToken();
      return await tokenResult.fold((failure) async => Left(failure), (
        token,
      ) async {
        if (token == null) {
          return Left(UnauthorizedFailure('User not authenticated'));
        }
        try {
          final coupons = await remoteDataSource.getAvailableCoupons(
            token: token,
            orderAmount: orderAmount,
            itemIds: itemIds,
          );
          logger.i('Retrieved ${coupons.length} available coupons');
          return Right(coupons.map((model) => model.toEntity()).toList());
        } catch (e) {
          logger.e('Failed to get available coupons: $e');
          return Left(ServerFailure(e.toString()));
        }
      });
    } catch (e) {
      logger.e('Unexpected error getting coupons: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponValidationEntity>> validateCoupon({
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  }) async {
    try {
      final tokenResult = await authRepository.getToken();
      return await tokenResult.fold((failure) async => Left(failure), (
        token,
      ) async {
        if (token == null) {
          return Left(UnauthorizedFailure('User not authenticated'));
        }
        try {
          final validation = await remoteDataSource.validateCoupon(
            token: token,
            couponCode: couponCode,
            orderAmount: orderAmount,
            itemIds: itemIds,
          );
          logger.i('Validated coupon $couponCode: ${validation.isValid}');
          return Right(validation.toEntity());
        } catch (e) {
          logger.e('Failed to validate coupon $couponCode: $e');
          return Left(ServerFailure(e.toString()));
        }
      });
    } catch (e) {
      logger.e('Unexpected error validating coupon: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponValidationEntity>> applyCoupon({
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  }) async {
    try {
      final tokenResult = await authRepository.getToken();
      return await tokenResult.fold((failure) async => Left(failure), (
        token,
      ) async {
        if (token == null) {
          return Left(UnauthorizedFailure('User not authenticated'));
        }
        try {
          final application = await remoteDataSource.applyCoupon(
            token: token,
            couponCode: couponCode,
            orderAmount: orderAmount,
            itemIds: itemIds,
          );
          logger.i(
            'Applied coupon $couponCode: discount ${application.discountAmount}',
          );
          return Right(application.toEntity());
        } catch (e) {
          logger.e('Failed to apply coupon $couponCode: $e');
          return Left(ServerFailure(e.toString()));
        }
      });
    } catch (e) {
      logger.e('Unexpected error applying coupon: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> getCouponByCode(
    String couponCode,
  ) async {
    try {
      final tokenResult = await authRepository.getToken();
      return await tokenResult.fold((failure) async => Left(failure), (
        token,
      ) async {
        if (token == null) {
          return Left(UnauthorizedFailure('User not authenticated'));
        }
        try {
          final coupon = await remoteDataSource.getCouponByCode(
            token: token,
            couponCode: couponCode,
          );
          logger.i('Retrieved coupon details for $couponCode');
          return Right(coupon.toEntity());
        } catch (e) {
          logger.e('Failed to get coupon $couponCode: $e');
          return Left(ServerFailure(e.toString()));
        }
      });
    } catch (e) {
      logger.e('Unexpected error getting coupon: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
