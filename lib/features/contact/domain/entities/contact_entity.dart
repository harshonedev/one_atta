import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id;
  final String? supportEmail;
  final String? salesEmail;
  final String? infoEmail;
  final String? supportPhone;
  final String? salesPhone;
  final String? whatsappNumber;
  final OfficeAddressEntity? officeAddress;
  final SocialMediaEntity? socialMedia;
  final BusinessHoursEntity? businessHours;
  final String? website;
  final String? mapLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContactEntity({
    required this.id,
    this.supportEmail,
    this.salesEmail,
    this.infoEmail,
    this.supportPhone,
    this.salesPhone,
    this.whatsappNumber,
    this.officeAddress,
    this.socialMedia,
    this.businessHours,
    this.website,
    this.mapLink,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    supportEmail,
    salesEmail,
    infoEmail,
    supportPhone,
    salesPhone,
    whatsappNumber,
    officeAddress,
    socialMedia,
    businessHours,
    website,
    mapLink,
    createdAt,
    updatedAt,
  ];
}

class OfficeAddressEntity extends Equatable {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const OfficeAddressEntity({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
    ].where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    country,
  ];
}

class SocialMediaEntity extends Equatable {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;
  final String? youtube;

  const SocialMediaEntity({
    this.facebook,
    this.instagram,
    this.twitter,
    this.linkedin,
    this.youtube,
  });

  @override
  List<Object?> get props => [facebook, instagram, twitter, linkedin, youtube];
}

class BusinessHoursEntity extends Equatable {
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;
  final String? saturday;
  final String? sunday;

  const BusinessHoursEntity({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  String? getHoursForDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return monday;
      case 'tuesday':
        return tuesday;
      case 'wednesday':
        return wednesday;
      case 'thursday':
        return thursday;
      case 'friday':
        return friday;
      case 'saturday':
        return saturday;
      case 'sunday':
        return sunday;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];
}
