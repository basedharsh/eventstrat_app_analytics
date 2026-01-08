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
      config: config,
    );
    //TO ENABLE FIREBASE
    FirebaseAnalyticsService.initialize(
        enabled: config.enableFirebase,
        enableDebugMode: config.enableDebugMode);
  }

  static Future<void> updateUser({String? email, String? cohort}) async {
    if (_config == null) {
      if (_config?.enableDebugMode ?? false) {
        log('Analytics: [ERROR] EventManager not initialized. Cannot update user info.');
      }
      return;
    }

    try {
      _config = _config!.copyWith(userEmail: email, userCohort: cohort);

      final prefs = await SharedPreferences.getInstance();
      if (email != null) {
        try {
          await prefs.setString('user_email', email);
          if (_config!.enableDebugMode) {
            log('Analytics: [SUCCESS] Email saved to preferences: $email');
          }
          // Set userId in Firebase Analytics
          await FirebaseAnalyticsService.setUserId(email);
        } catch (e) {
          if (_config!.enableDebugMode) {
            log('Analytics: [ERROR] Failed to save email to preferences: ${e.toString()}');
          }
        }
      }
      if (cohort != null) {
        try {
          await prefs.setString('user_cohort', cohort);
          if (_config!.enableDebugMode) {
            log('Analytics: [SUCCESS] Cohort saved to preferences: $cohort');
          }
          await FirebaseAnalyticsService.setUserProperty(
              name: 'cohort', value: cohort);
        } catch (e) {
          if (_config!.enableDebugMode) {
            log('Analytics: [ERROR] Failed to save cohort to preferences: ${e.toString()}');
          }
        }
      }

      if (_config!.enableDebugMode) {
        log('Analytics: [SUCCESS] User info updated: email=$email, cohort=$cohort');
      }
    } catch (e) {
      if (_config!.enableDebugMode) {
        log('Analytics: [ERROR] Unexpected error in updateUser: ${e.toString()}');
      }
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
      if (_config?.enableDebugMode ?? false) {
        log(
          'Analytics: [ERROR] EventManager not initialized. Call EventManager.initialize() first.',
        );
      }
      return;
    }

    try {
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

      if (_config!.enableDebugMode) {
        log(
          " Analytics: [INFO] Target Product : ${targetProduct ?? _config!.targetProduct}, Sending event: $eventName, Screen: $screenName, Action: $eventAction, Category: $eventCategory, Email: $email, Cohort: $cohort, Version: ${packageInfo.version}, Miscellaneous: $miscellaneous",
        );
      }

      await _invoker!.storeEventToLocal(
        eventData: await eventDTO.toJson(config: _config),
      );

      if (_config!.enableDebugMode) {
        log('Analytics: [SUCCESS] Event stored locally: $eventName');
      }

      // Log event to Firebase Analytics
      await FirebaseAnalyticsService.logEvent(
        eventName: eventName,
        screenName: screenName,
        eventAction: eventAction,
        eventCategory: eventCategory,
        email: email,
        cohort: cohort,
      );
    } catch (e) {
      if (_config!.enableDebugMode) {
        log('Analytics: [ERROR] Error in sendEventFirebase - Event: $eventName, Error: ${e.toString()}');
      }
    }
  }

  static Future<void> sync({Map<String, String>? headers}) async {
    if (_invoker == null) {
      if (_config?.enableDebugMode ?? false) {
        log('Analytics: EventManager not initialized');
      }
      return;
    }
    await _invoker!.syncEventsToDB(additionalHeaders: headers);
  }
}
