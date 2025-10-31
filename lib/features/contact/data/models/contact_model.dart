import 'package:one_atta/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    super.supportEmail,
    super.salesEmail,
    super.infoEmail,
    super.supportPhone,
    super.salesPhone,
    super.whatsappNumber,
    super.officeAddress,
    super.socialMedia,
    super.businessHours,
    super.website,
    super.mapLink,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] as String,
      supportEmail: json['supportEmail'] as String?,
      salesEmail: json['salesEmail'] as String?,
      infoEmail: json['infoEmail'] as String?,
      supportPhone: json['supportPhone'] as String?,
      salesPhone: json['salesPhone'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      officeAddress: json['officeAddress'] != null
          ? OfficeAddressModel.fromJson(
              json['officeAddress'] as Map<String, dynamic>,
            )
          : null,
      socialMedia: json['socialMedia'] != null
          ? SocialMediaModel.fromJson(
              json['socialMedia'] as Map<String, dynamic>,
            )
          : null,
      businessHours: json['businessHours'] != null
          ? BusinessHoursModel.fromJson(
              json['businessHours'] as Map<String, dynamic>,
            )
          : null,
      website: json['website'] as String?,
      mapLink: json['mapLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'supportEmail': supportEmail,
      'salesEmail': salesEmail,
      'infoEmail': infoEmail,
      'supportPhone': supportPhone,
      'salesPhone': salesPhone,
      'whatsappNumber': whatsappNumber,
      'officeAddress': officeAddress != null
          ? (officeAddress as OfficeAddressModel).toJson()
          : null,
      'socialMedia': socialMedia != null
          ? (socialMedia as SocialMediaModel).toJson()
          : null,
      'businessHours': businessHours != null
          ? (businessHours as BusinessHoursModel).toJson()
          : null,
      'website': website,
      'mapLink': mapLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      supportEmail: supportEmail,
      salesEmail: salesEmail,
      infoEmail: infoEmail,
      supportPhone: supportPhone,
      salesPhone: salesPhone,
      whatsappNumber: whatsappNumber,
      officeAddress: officeAddress,
      socialMedia: socialMedia,
      businessHours: businessHours,
      website: website,
      mapLink: mapLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class OfficeAddressModel extends OfficeAddressEntity {
  const OfficeAddressModel({
    super.addressLine1,
    super.addressLine2,
    super.city,
    super.state,
    super.postalCode,
    super.country,
  });

  factory OfficeAddressModel.fromJson(Map<String, dynamic> json) {
    return OfficeAddressModel(
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

class SocialMediaModel extends SocialMediaEntity {
  const SocialMediaModel({
    super.facebook,
    super.instagram,
    super.twitter,
    super.linkedin,
    super.youtube,
  });

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      linkedin: json['linkedin'] as String?,
      youtube: json['youtube'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'linkedin': linkedin,
      'youtube': youtube,
    };
  }
}

class BusinessHoursModel extends BusinessHoursEntity {
  const BusinessHoursModel({
    super.monday,
    super.tuesday,
    super.wednesday,
    super.thursday,
    super.friday,
    super.saturday,
    super.sunday,
  });

  factory BusinessHoursModel.fromJson(Map<String, dynamic> json) {
    return BusinessHoursModel(
      monday: json['monday'] as String?,
      tuesday: json['tuesday'] as String?,
      wednesday: json['wednesday'] as String?,
      thursday: json['thursday'] as String?,
      friday: json['friday'] as String?,
      saturday: json['saturday'] as String?,
      sunday: json['sunday'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
    };
  }
}
