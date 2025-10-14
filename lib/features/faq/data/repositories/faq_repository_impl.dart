import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/faq/data/datasources/faq_remote_data_source.dart';
import 'package:one_atta/features/faq/domain/entities/faq_entity.dart';
import 'package:one_atta/features/faq/domain/repositories/faq_repository.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;

  FaqRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FaqEntity>>> getFaqs() async {
    try {
      final result = await remoteDataSource.getFaqs();
      return Right(result.map((model) => model.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch FAQs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FaqEntity>>> getFaqsByCategory(
    String category,
  ) async {
    try {
      final result = await remoteDataSource.getFaqsByCategory(category);
      return Right(result.map((model) => model.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch FAQs by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FaqEntity>>> searchFaqs(
    String searchQuery,
  ) async {
    try {
      final result = await remoteDataSource.searchFaqs(searchQuery);
      return Right(result.map((model) => model.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to search FAQs: $e'));
    }
  }

  @override
  Future<Either<Failure, FaqHelpfulMarkedResponse>> markFaqAsHelpful(String faqId) async {
    try {
      final result = await remoteDataSource.markFaqAsHelpful(faqId);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to mark FAQ as helpful: $e'));
    }
  }
}
