import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressesLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressLoaded extends AddressState {
  final AddressEntity address;

  const AddressLoaded(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressCreating extends AddressState {
  const AddressCreating();
}

class AddressCreated extends AddressState {
  final AddressEntity address;

  const AddressCreated(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressUpdating extends AddressState {
  const AddressUpdating();
}

class AddressUpdated extends AddressState {
  final AddressEntity address;

  const AddressUpdated(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressDeleting extends AddressState {
  const AddressDeleting();
}

class AddressDeleted extends AddressState {
  final AddressEntity address;

  const AddressDeleted(this.address);

  @override
  List<Object?> get props => [address];
}

class DefaultAddressSetting extends AddressState {
  const DefaultAddressSetting();
}

class DefaultAddressSet extends AddressState {
  final AddressEntity address;

  const DefaultAddressSet(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
