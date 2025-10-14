import 'package:equatable/equatable.dart';

abstract class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object?> get props => [];
}

class LoadFaqs extends FaqEvent {
  const LoadFaqs();

  @override
  List<Object?> get props => [];
}

class LoadFaqsByCategory extends FaqEvent {
  final String category;

  const LoadFaqsByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class SearchFaqs extends FaqEvent {
  final String searchQuery;

  const SearchFaqs(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class MarkFaqAsHelpful extends FaqEvent {
  final String faqId;

  const MarkFaqAsHelpful(this.faqId);

  @override
  List<Object> get props => [faqId];
}

class RestoreFaqs extends FaqEvent {
  const RestoreFaqs();

  @override
  List<Object?> get props => [];
}
