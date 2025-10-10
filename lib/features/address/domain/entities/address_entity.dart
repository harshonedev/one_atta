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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'recipientName': recipientName,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'geo': geo != null
          ? {'type': geo!.type, 'coordinates': geo!.coordinates}
          : null,
      'isDefault': isDefault,
      'instructions': instructions,
      'deleted': deleted,
      'fullAddress': fullAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      recipientName: json['recipientName'] as String,
      primaryPhone: json['primaryPhone'] as String,
      secondaryPhone: json['secondaryPhone'] as String?,
      geo: json['geo'] != null
          ? GeoLocation(
              type: json['geo']['type'] as String,
              coordinates: List<double>.from(
                json['geo']['coordinates'] as List,
              ),
            )
          : null,
      isDefault: json['isDefault'] as bool,
      instructions: json['instructions'] as String?,
      deleted: json['deleted'] as bool,
      fullAddress: json['fullAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

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
