enum DeviceIdStrategy {
  methodChannel, // existing method channel approach
  hardwareId, // Use device_info_plus for actual hardware ID
  generated, // Generate and persist a UUID
}

class AnalyticsConfig {
  final String targetProduct;
  final String apiEndpoint;
  final String? userEmail;
  final String? userCohort;
  final Map<String, String>? headers;
  final bool enableDebugMode;
  final DeviceIdStrategy deviceIdStrategy;
  final String? methodChannelName;

  const AnalyticsConfig({
    required this.targetProduct,
    required this.apiEndpoint,
    this.userEmail,
    this.userCohort,
    this.headers,
    this.enableDebugMode = false,
    this.deviceIdStrategy = DeviceIdStrategy.hardwareId,
    this.methodChannelName,
  });

  AnalyticsConfig copyWith({
    String? targetProduct,
    String? apiEndpoint,
    String? userEmail,
    String? userCohort,
    Map<String, String>? headers,
    bool? enableDebugMode,
    DeviceIdStrategy? deviceIdStrategy,
    String? methodChannelName,
  }) {
    return AnalyticsConfig(
      targetProduct: targetProduct ?? this.targetProduct,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      userEmail: userEmail ?? this.userEmail,
      userCohort: userCohort ?? this.userCohort,
      headers: headers ?? this.headers,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      deviceIdStrategy: deviceIdStrategy ?? this.deviceIdStrategy,
      methodChannelName: methodChannelName ?? this.methodChannelName,
    );
  }
}
