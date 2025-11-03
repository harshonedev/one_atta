import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/contact/domain/repositories/contact_repository.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_event.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository repository;

  ContactBloc({required this.repository}) : super(const ContactInitial()) {
    on<LoadContactDetails>(_onLoadContactDetails);
  }

  Future<void> _onLoadContactDetails(
    LoadContactDetails event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());

    final result = await repository.getContactDetails();

    result.fold(
      (failure) => emit(ContactError(failure.message, failure: failure)),
      (contact) => emit(ContactLoaded(contact)),
    );
  }
}
