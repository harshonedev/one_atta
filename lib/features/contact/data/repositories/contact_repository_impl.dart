import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:one_atta/features/contact/domain/entities/contact_entity.dart';
import 'package:one_atta/features/contact/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ContactEntity>> getContactDetails() async {
    try {
      final result = await remoteDataSource.getContactDetails();
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch contact details: $e'));
    }
  }
}
