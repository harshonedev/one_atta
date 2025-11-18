import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/core/network/network_info.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/refunds/data/datasources/refund_remote_data_source.dart';
import 'package:one_atta/features/refunds/domain/entities/refund_entity.dart';
import 'package:one_atta/features/refunds/domain/repositories/refund_repository.dart';

class RefundRepositoryImpl implements RefundRepository {
  final RefundRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  RefundRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, RefundEntity?>> getRefundByOrderId(
    String orderId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await authLocalDataSource.getToken();
        if (token == null) {
          return Left(ServerFailure('Authentication required'));
        }
        final refundModel = await remoteDataSource.getRefundByOrderId(
          token,
          orderId,
        );
        return Right(refundModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        // Return null if no refund found (not an error)
        return const Right(null);
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
