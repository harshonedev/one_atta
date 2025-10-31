import 'package:one_atta/features/address/domain/entities/address_entity.dart';

class GeoLocationModel extends GeoLocation {
  const GeoLocationModel({required super.type, required super.coordinates});

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(
        (json['coordinates'] as List).map((e) => e.toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }

  GeoLocation toEntity() {
    return GeoLocation(type: type, coordinates: coordinates);
  }
}

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.userId,
    required super.label,
    required super.addressLine1,
    super.addressLine2,
    super.landmark,
    required super.city,
    required super.state,
    required super.postalCode,
    required super.country,
    required super.recipientName,
    required super.primaryPhone,
    super.secondaryPhone,
    super.geo,
    required super.isDefault,
    super.instructions,
    required super.deleted,
    required super.fullAddress,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      label: json['label'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? 'India',
      recipientName: json['recipient_name'] ?? '',
      primaryPhone: json['primary_phone'] ?? '',
      secondaryPhone: json['secondary_phone'],
      geo: json['geo'] != null ? GeoLocationModel.fromJson(json['geo']) : null,
      isDefault: json['is_default'] ?? false,
      instructions: json['instructions'],
      deleted: json['deleted'] ?? false,
      fullAddress: json['full_address'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'label': label,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'recipient_name': recipientName,
      'primary_phone': primaryPhone,
      'secondary_phone': secondaryPhone,
      'geo': geo != null ? (geo as GeoLocationModel).toJson() : null,
      'is_default': isDefault,
      'instructions': instructions,
      'deleted': deleted,
      'full_address': fullAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts model to create/update request JSON
  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> json = {
      'label': label,
      'address_line1': addressLine1,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'recipient_name': recipientName,
      'primary_phone': primaryPhone,
    };

    // Add optional fields only if they're not null
    if (addressLine2 != null) json['address_line2'] = addressLine2;
    if (landmark != null) json['landmark'] = landmark;
    if (country != 'India') json['country'] = country;
    if (secondaryPhone != null) json['secondary_phone'] = secondaryPhone;
    if (geo != null) json['geo'] = (geo as GeoLocationModel).toJson();
    if (isDefault) json['is_default'] = isDefault;
    if (instructions != null) json['instructions'] = instructions;

    return json;
  }

  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      userId: userId,
      label: label,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      landmark: landmark,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      recipientName: recipientName,
      primaryPhone: primaryPhone,
      secondaryPhone: secondaryPhone,
      geo: geo,
      isDefault: isDefault,
      instructions: instructions,
      deleted: deleted,
      fullAddress: fullAddress,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
