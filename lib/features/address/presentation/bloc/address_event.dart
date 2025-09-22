import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class RefreshAddresses extends AddressEvent {
  const RefreshAddresses();
}

class LoadAddressById extends AddressEvent {
  final String addressId;

  const LoadAddressById(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class CreateAddress extends AddressEvent {
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String? country;
  final String recipientName;
  final String primaryPhone;
  final String? secondaryPhone;
  final GeoLocation? geo;
  final bool? isDefault;
  final String? instructions;

  const CreateAddress({
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country,
    required this.recipientName,
    required this.primaryPhone,
    this.secondaryPhone,
    this.geo,
    this.isDefault,
    this.instructions,
  });

  @override
  List<Object?> get props => [
    label,
    addressLine1,
    addressLine2,
    landmark,
    city,
    state,
    postalCode,
    country,
    recipientName,
    primaryPhone,
    secondaryPhone,
    geo,
    isDefault,
    instructions,
  ];
}

class UpdateAddress extends AddressEvent {
  final String addressId;
  final String? label;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? recipientName;
  final String? primaryPhone;
  final String? secondaryPhone;
  final GeoLocation? geo;
  final bool? isDefault;
  final String? instructions;

  const UpdateAddress({
    required this.addressId,
    this.label,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.recipientName,
    this.primaryPhone,
    this.secondaryPhone,
    this.geo,
    this.isDefault,
    this.instructions,
  });

  @override
  List<Object?> get props => [
    addressId,
    label,
    addressLine1,
    addressLine2,
    landmark,
    city,
    state,
    postalCode,
    country,
    recipientName,
    primaryPhone,
    secondaryPhone,
    geo,
    isDefault,
    instructions,
  ];
}

class DeleteAddress extends AddressEvent {
  final String addressId;

  const DeleteAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}
