import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/faq/domain/repositories/faq_repository.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_event.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final FaqRepository faqRepository;

  FaqBloc({required this.faqRepository}) : super(FaqInitial()) {
    on<LoadFaqs>(_onLoadFaqs);
    on<LoadFaqsByCategory>(_onLoadFaqsByCategory);
    on<SearchFaqs>(_onSearchFaqs);
    on<MarkFaqAsHelpful>(_onMarkFaqAsHelpful);
    on<RestoreFaqs>(_onRestoreFaqs);
  }

  Future<void> _onLoadFaqs(LoadFaqs event, Emitter<FaqState> emit) async {
    emit(FaqLoading());

    final result = await faqRepository.getFaqs();

    result.fold(
      (failure) => emit(FaqError(failure.message)),
      (faqs) => emit(FaqLoaded(faqs)),
    );
  }

  Future<void> _onLoadFaqsByCategory(
    LoadFaqsByCategory event,
    Emitter<FaqState> emit,
  ) async {
    emit(FaqLoading());

    final result = await faqRepository.getFaqsByCategory(event.category);

    result.fold(
      (failure) => emit(FaqError(failure.message)),
      (faqs) => emit(FaqLoaded(faqs)),
    );
  }

  Future<void> _onSearchFaqs(SearchFaqs event, Emitter<FaqState> emit) async {
    emit(FaqLoading());

    final result = await faqRepository.searchFaqs(event.searchQuery);

    result.fold(
      (failure) => emit(FaqError(failure.message)),
      (faqs) => emit(FaqLoaded(faqs)),
    );
  }

  Future<void> _onMarkFaqAsHelpful(
    MarkFaqAsHelpful event,
    Emitter<FaqState> emit,
  ) async {
    if (state is! FaqLoaded) return;

    final currentState = state as FaqLoaded;

    // update the FAQ list optimistically
    final updatedFaqs = currentState.faqs.map((faq) {
      if (faq.id == event.faqId) {
        return faq.copyWith(helpfulCount: faq.helpfulCount + 1);
      }
      return faq;
    }).toList();

    emit(FaqHelpfulMarked(updatedFaqs));
    final result = await faqRepository.markFaqAsHelpful(event.faqId);

    result.fold((failure) => emit(FaqError(failure.message)), (response) {
      final faqs = currentState.faqs.map((faq) {
        if (faq.id == event.faqId) {
          return faq.copyWith(helpfulCount: response.newHelpfulCount);
        }
        return faq;
      }).toList();
      emit(FaqLoaded(faqs));
    });
  }

  void _onRestoreFaqs(RestoreFaqs event, Emitter<FaqState> emit) {
    if (state is FaqHelpfulMarked) {
      final currentState = state as FaqHelpfulMarked;
      emit(FaqLoaded(currentState.faqs));
    }
  }
}
