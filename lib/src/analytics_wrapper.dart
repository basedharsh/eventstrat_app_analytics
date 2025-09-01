import 'tracking/analytics_config.dart';
import 'tracking/event_manager.dart';
import 'constants/event_actions.dart';

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
    String? methodChannelName,
  }) {
    final config = AnalyticsConfig(
      targetProduct: targetProduct,
      apiEndpoint: apiEndpoint,
      userEmail: userEmail,
      userCohort: userCohort,
      headers: headers,
      enableDebugMode: enableDebugMode,
      deviceIdStrategy: deviceIdStrategy,
      methodChannelName: methodChannelName,
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

  static Future<void> sync() async {
    if (!_isInitialized) {
      throw StateError('EventstratAnalytics not initialized.');
    }
    await EventManager.sync();
  }
}
