import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/contact/domain/entities/contact_entity.dart';

abstract class ContactRepository {
  // Get public contact details
  Future<Either<Failure, ContactEntity>> getContactDetails();
}
