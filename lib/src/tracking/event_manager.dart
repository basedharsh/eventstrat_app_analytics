import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/event_actions.dart';
import '../storage/firebase_events_action_invoker.dart';
import '../tracking/event_firebase_dto.dart';
import '../tracking/analytics_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'firebase_analytics_service.dart';

class EventManager {
  static AnalyticsConfig? _config;
  static AnalyticsEventsActionInvoker? _invoker;

  static void initialize(AnalyticsConfig config) {
    _config = config;
    _invoker = AnalyticsEventsActionInvoker(
      apiEndpoint: config.apiEndpoint,
      headers: config.headers,
    );
    //TO ENABLE FIREBASE
    FirebaseAnalyticsService.initialize(enabled: config.enableFirebase);
  }

  static Future<void> updateUser({String? email, String? cohort}) async {
    if (_config == null) {
      log('Analytics: EventManager not initialized');
      return;
    }

    _config = _config!.copyWith(userEmail: email, userCohort: cohort);

    final prefs = await SharedPreferences.getInstance();
    if (email != null) {
      await prefs.setString('user_email', email);
      // Set userId in Firebase Analytics
      await FirebaseAnalyticsService.setUserId(email);
    }
    if (cohort != null) {
      await prefs.setString('user_cohort', cohort);
      await FirebaseAnalyticsService.setUserProperty(
          name: 'cohort', value: cohort);
    }

    if (_config!.enableDebugMode) {
      log('Analytics: User info updated: email=$email, cohort=$cohort');
    }
  }

  static Future<void> sendEventFirebase({
    required String eventName,
    required String screenName,
    String? miscellaneous,
    String? targetProduct,
    String eventAction = EventAction.click,
    String? eventCategory,
  }) async {
    if (_config == null || _invoker == null) {
      log(
        'Analytics: EventManager not initialized. Call EventManager.initialize() first.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final email =
        prefs.getString('user_email') ?? _config!.userEmail ?? 'guest';
    final cohort =
        prefs.getString('user_cohort') ?? _config!.userCohort ?? 'guest';
    EventFirebaseDto eventDTO = EventFirebaseDto(
      eventName: eventName,
      email: email,
      screenName: screenName,
      miscellaneous: miscellaneous,
      eventAction: eventAction,
      targetProduct: targetProduct ?? _config!.targetProduct,
      eventCategory: eventCategory ?? "",
      cohort: cohort,
      version: packageInfo.version,
    );
    log(
      " Analytics: Target Product : ${targetProduct ?? _config!.targetProduct}, Sending event: $eventName, Screen: $screenName, Action: $eventAction, Category: $eventCategory, Email: $email, Cohort: $cohort, Version: ${packageInfo.version}, Miscellaneous: $miscellaneous",
    );

    await _invoker!.storeEventToLocal(
      eventData: await eventDTO.toJson(config: _config),
    );
// Log event to Firebase Analytics
    await FirebaseAnalyticsService.logEvent(
      eventName: eventName,
      screenName: screenName,
      eventAction: eventAction,
      eventCategory: eventCategory,
      email: email,
      cohort: cohort,
    );
  }

  static Future<void> sync({Map<String, String>? headers}) async {
    if (_invoker == null) {
      log('Analytics: EventManager not initialized');
      return;
    }
    await _invoker!.syncEventsToDB(additionalHeaders: headers);
  }
}
