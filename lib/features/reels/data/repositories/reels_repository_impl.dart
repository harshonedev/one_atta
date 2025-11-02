import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source.dart';
import 'package:one_atta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:one_atta/features/reels/data/models/reel_model.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';
import 'package:one_atta/features/reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource remoteDataSource;
  final ReelsLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ReelsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, ReelsFeedEntity>> getReelsFeed({
    int? limit,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we should use cache
      final isCacheValid = await localDataSource.isCacheValid();

      if (!forceRefresh && isCacheValid && cursor == null) {
        // Return cached data if valid and not pagination
        final cachedReels = await localDataSource.getCachedReels();
        final cachedCursor = await localDataSource.getCachedCursor();

        if (cachedReels.isNotEmpty) {
          return Right(
            ReelsFeedEntity(
              reels: cachedReels,
              nextCursor: cachedCursor,
              hasMore: cachedCursor != null,
            ),
          );
        }
      }

      // Fetch from remote
      final result = await remoteDataSource.getReelsFeed(
        limit: limit,
        cursor: cursor,
      );

      // Cache the results if it's the first page
      if (cursor == null) {
        final reelModels = result.reels
            .map((reel) => reel as ReelModel)
            .toList();
        await localDataSource.cacheReels(reelModels, cursor: result.nextCursor);
      }

      return Right(result);
    } on Failure catch (failure) {
      // If network fails and we have cache, return cache
      if (!forceRefresh && cursor == null) {
        final cachedReels = await localDataSource.getCachedReels();
        if (cachedReels.isNotEmpty) {
          return Right(
            ReelsFeedEntity(
              reels: cachedReels,
              nextCursor: await localDataSource.getCachedCursor(),
              hasMore: false, // No more data available offline
            ),
          );
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get reels feed: $e'));
    }
  }

  @override
  Future<Either<Failure, ReelDetailEntity>> getReelDetails(String id) async {
    try {
      final result = await remoteDataSource.getReelDetails(id);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get reel details: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> incrementViewCount(String id) async {
    try {
      // Public endpoint - no authentication required
      final result = await remoteDataSource.incrementViewCount(id);

      // Update cache if successful
      await localDataSource.updateReelViewCount(id, result);

      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to increment view count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReelEntity>>> getReelsByBlend(
    String blendId, {
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getReelsByBlend(
        blendId,
        limit: limit,
      );
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get reels by blend: $e'));
    }
  }

  @override
  Future<Either<Failure, ReelSearchResultEntity>> searchReels(
    String query, {
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.searchReels(query, limit: limit);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to search reels: $e'));
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

      // Update cache if successful
      await localDataSource.updateReelLikeStatus(
        reelId,
        result.isLiked,
        result.likesCount,
      );

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
