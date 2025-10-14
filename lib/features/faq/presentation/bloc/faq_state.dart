import 'package:equatable/equatable.dart';
import 'package:one_atta/features/faq/domain/entities/faq_entity.dart';

abstract class FaqState extends Equatable {
  const FaqState();

  @override
  List<Object?> get props => [];
}

class FaqInitial extends FaqState {}

class FaqLoading extends FaqState {}

class FaqLoaded extends FaqState {
  final List<FaqEntity> faqs;

  const FaqLoaded(this.faqs);

  @override
  List<Object> get props => [faqs];
}

class FaqError extends FaqState {
  final String message;

  const FaqError(this.message);

  @override
  List<Object> get props => [message];
}

class FaqHelpfulMarked extends FaqState {
  final List<FaqEntity> faqs;
  const FaqHelpfulMarked(this.faqs);

  @override
  List<Object> get props => [];
}
