import 'package:equatable/equatable.dart';
import 'package:one_atta/features/contact/domain/entities/contact_entity.dart';

abstract class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {
  const ContactInitial();
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class ContactLoaded extends ContactState {
  final ContactEntity contact;

  const ContactLoaded(this.contact);

  @override
  List<Object?> get props => [contact];
}

class ContactError extends ContactState {
  final String message;

  const ContactError(this.message);

  @override
  List<Object?> get props => [message];
}
