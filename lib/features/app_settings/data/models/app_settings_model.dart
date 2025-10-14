import 'package:one_atta/features/app_settings/domain/entities/app_settings_entity.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.id,
    required super.termsAndConditionsUrl,
    required super.privacyPolicyUrl,
    required super.supportEmail,
    required super.supportPhone,
    required super.appVersion,
    required super.maintenanceMode,
    required super.maintenanceMessage,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['_id'] as String,
      termsAndConditionsUrl: json['termsAndConditionsUrl'] as String? ?? '',
      privacyPolicyUrl: json['privacyPolicyUrl'] as String? ?? '',
      supportEmail: json['supportEmail'] as String? ?? '',
      supportPhone: json['supportPhone'] as String? ?? '',
      appVersion: json['appVersion'] as String? ?? '',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: json['maintenanceMessage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'termsAndConditionsUrl': termsAndConditionsUrl,
      'privacyPolicyUrl': privacyPolicyUrl,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'appVersion': appVersion,
      'maintenanceMode': maintenanceMode,
      'maintenanceMessage': maintenanceMessage,
    };
  }
}
