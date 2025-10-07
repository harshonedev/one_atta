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
  Future<Either<Failure, CouponValidationEntity>> applyCoupon({
    required String couponCode,
    required double orderAmount,
    required List<CouponItem> items,
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
            items: items,
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
  Future<Either<Failure, CouponEntity>> fetchCouponByCode({
    required String couponCode,
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
          final coupon = await remoteDataSource.fetchCouponByCode(
            token: token,
            couponCode: couponCode,
          );
          logger.i('Fetched coupon $couponCode: ${coupon.code}');
          return Right(coupon.toEntity());
        } on Failure catch (failure) {
          logger.e('API failure fetching coupon $couponCode: $failure');
          return Left(failure);
        } catch (e) {
          logger.e('Failed to fetch coupon $couponCode: $e');
          return Left(ServerFailure(e.toString()));
        }
      });
    } on Failure catch (failure) {
      logger.e('API failure fetching coupon by code: $failure');
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error fetching coupon by code: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
