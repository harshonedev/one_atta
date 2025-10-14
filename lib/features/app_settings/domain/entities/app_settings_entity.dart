class AppSettingsEntity {
  final String id;
  final String termsAndConditionsUrl;
  final String privacyPolicyUrl;
  final String supportEmail;
  final String supportPhone;
  final String appVersion;
  final bool maintenanceMode;
  final String maintenanceMessage;

  const AppSettingsEntity({
    required this.id,
    required this.termsAndConditionsUrl,
    required this.privacyPolicyUrl,
    required this.supportEmail,
    required this.supportPhone,
    required this.appVersion,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });
}
