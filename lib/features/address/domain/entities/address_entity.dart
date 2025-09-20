import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  const GeoLocation({required this.type, required this.coordinates});

  @override
  List<Object?> get props => [type, coordinates];
}

class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String recipientName;
  final String primaryPhone;
  final String? secondaryPhone;
  final GeoLocation? geo;
  final bool isDefault;
  final String? instructions;
  final bool deleted;
  final String fullAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.recipientName,
    required this.primaryPhone,
    this.secondaryPhone,
    this.geo,
    required this.isDefault,
    this.instructions,
    required this.deleted,
    required this.fullAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
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
    deleted,
    fullAddress,
    createdAt,
    updatedAt,
  ];
}
