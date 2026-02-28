import 'tracking/analytics_config.dart';
import 'tracking/event_manager.dart';
import 'constants/event_actions.dart';
import 'package:flutter/foundation.dart';

class EventstratAnalytics {
  static bool _isInitialized = false;

  static void initialize({
    required String targetProduct,
    required String apiEndpoint,
    String? userEmail,
    String? userCohort,
    Map<String, String>? headers,
    bool enableDebugMode = false,
    DeviceIdStrategy deviceIdStrategy = DeviceIdStrategy.hardwareId,
    bool enableFirebase = false,
    bool enableBackendSync = true,
    String? methodChannelName,
    String? encryptionKey,
  }) {
    // Firebase is allowed only in production (release) builds.
    final effectiveEnableFirebase = enableFirebase && kReleaseMode;

    if (!enableBackendSync && !effectiveEnableFirebase) {
      throw StateError(
        'Invalid analytics configuration: both backend sync and Firebase analytics are disabled. Firebase is only enabled in release builds. Enable at least one destination.',
      );
    }

    final config = AnalyticsConfig(
      targetProduct: targetProduct,
      apiEndpoint: apiEndpoint,
      userEmail: userEmail,
      userCohort: userCohort,
      headers: headers,
      enableDebugMode: enableDebugMode,
      deviceIdStrategy: deviceIdStrategy,
      enableFirebase: effectiveEnableFirebase,
      enableBackendSync: enableBackendSync,
      methodChannelName: methodChannelName,
      encryptionKey: encryptionKey,
    );

    EventManager.initialize(config);
    _isInitialized = true;
  }

  static Future<void> updateUser({String? email, String? cohort}) async {
    if (!_isInitialized) {
      throw StateError('EventstratAnalytics not initialized.');
    }

    // Update EventManager's config
    await EventManager.updateUser(email: email, cohort: cohort);
  }

  static Future<void> track({
    required String event,
    required String screen,
    String action = EventAction.click,
    String? category,
    String? miscellaneous,
    String? targetProduct,
  }) async {
    if (!_isInitialized) {
      throw StateError(
        'EventstratAnalytics not initialized. Call initialize() first.',
      );
    }

    await EventManager.sendEventFirebase(
      eventName: event,
      screenName: screen,
      eventAction: action,
      eventCategory: category,
      miscellaneous: miscellaneous,
      targetProduct: targetProduct,
    );
  }

  static Future<void> sync({Map<String, String>? headers}) async {
    if (!_isInitialized) {
      throw StateError('EventstratAnalytics not initialized.');
    }
    await EventManager.sync(headers: headers);
  }
}
