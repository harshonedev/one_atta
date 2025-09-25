import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';
import 'package:one_atta/features/reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ReelsRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, ReelsFeedEntity>> getReelsFeed({
    int? limit,
    String? cursor,
  }) async {
    try {
      final result = await remoteDataSource.getReelsFeed(
        limit: limit,
        cursor: cursor,
      );
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get reels feed: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> incrementViewCount(String id) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }
      final result = await remoteDataSource.incrementViewCount(token, id);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to increment view count: $e'));
    }
  }

  @override
  Future<Either<Failure, ReelLikeEntity>> toggleReelLike(String reelId) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }
      final result = await remoteDataSource.toggleReelLike(token, reelId);
      return Right(
        ReelLikeEntity(
          isLiked: result.isLiked,
          likesCount: result.likesCount,
          reelId: result.reelId,
        ),
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle reel like: $e'));
    }
  }

  @override
  Future<Either<Failure, ReelShareEntity>> shareReel(
    String reelId, {
    String shareType = 'link',
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }
      final result = await remoteDataSource.shareReel(
        token,
        reelId,
        shareType: shareType,
      );
      return Right(
        ReelShareEntity(
          shareUrl: result.shareUrl,
          sharesCount: result.sharesCount,
          shareType: result.shareType,
          reelId: result.reelId,
          sharedAt: result.sharedAt,
        ),
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to share reel: $e'));
    }
  }

  @override
  Future<Either<Failure, ReelLikeEntity>> getReelLikedStatus(
    String reelId,
  ) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }
      final result = await remoteDataSource.getReelLikedStatus(token, reelId);
      return Right(
        ReelLikeEntity(
          isLiked: result.isLiked,
          likesCount: result.likesCount,
          reelId: result.reelId,
        ),
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get reel liked status: $e'));
    }
  }
}
