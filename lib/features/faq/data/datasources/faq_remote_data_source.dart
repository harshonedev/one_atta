import 'package:one_atta/features/faq/data/models/faq_model.dart';

abstract class FaqRemoteDataSource {
  Future<List<FaqModel>> getFaqs();

  Future<List<FaqModel>> getFaqsByCategory(String category);

  Future<List<FaqModel>> searchFaqs(String searchQuery);

  Future<FaqHelpfulMarkedResponseModel> markFaqAsHelpful(String faqId);
}
