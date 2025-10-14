import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/faq/domain/entities/faq_entity.dart';

abstract class FaqRepository {
  // Get all active FAQs
  Future<Either<Failure, List<FaqEntity>>> getFaqs();

  // Get FAQs by category
  Future<Either<Failure, List<FaqEntity>>> getFaqsByCategory(String category);

  // Search FAQs
  Future<Either<Failure, List<FaqEntity>>> searchFaqs(String searchQuery);

  // Mark FAQ as helpful
  Future<Either<Failure, FaqHelpfulMarkedResponse>> markFaqAsHelpful(
    String faqId,
  );
}
