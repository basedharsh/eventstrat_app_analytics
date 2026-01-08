import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalytics? _analytics;
  static bool _isEnabled = false;
  static bool _enableDebugMode = false;

  static void initialize(
      {required bool enabled, bool enableDebugMode = false}) {
    _isEnabled = enabled;
    _enableDebugMode = enableDebugMode;
    if (_isEnabled) {
      _analytics = FirebaseAnalytics.instance;
      if (_enableDebugMode) {
        log('ANALYTICS: [SUCCESS] Firebase Analytics initialized');
      }
    }
  }

  static Future<void> logEvent({
    required String eventName,
    required String screenName,
    String? eventAction,
    String? eventCategory,
    String? email,
    String? cohort,
  }) async {
    if (!_isEnabled || _analytics == null) {
      if (_enableDebugMode) {
        log('ANALYTICS: [WARNING] Firebase Analytics not enabled or not initialized');
      }
      return;
    }

    try {
      String firebaseEventName = eventName.toLowerCase();

      await _analytics!.logEvent(
        name: firebaseEventName,
        parameters: {
          'screen_name': screenName,
          if (eventAction != null) 'event_action': eventAction,
          if (eventCategory != null) 'event_category': eventCategory,
          if (email != null) 'user_email': email,
          if (cohort != null) 'user_cohort': cohort,
        },
      );

      if (_enableDebugMode) {
        log('ANALYTICS: [SUCCESS] Firebase event logged: $firebaseEventName with parameters - screen: $screenName, action: $eventAction, category: $eventCategory, email: $email, cohort: $cohort');
      }
    } catch (e) {
      if (_enableDebugMode) {
        log('ANALYTICS: [ERROR] Firebase logEvent failed for event: $eventName, Error: ${e.toString()}');
      }
    }
  }

  static Future<void> setUserId(String userId) async {
    if (!_isEnabled || _analytics == null) {
      if (_enableDebugMode) {
        log('ANALYTICS: [WARNING] Firebase Analytics not enabled or not initialized, cannot set userId: $userId');
      }
      return;
    }

    try {
      await _analytics!.setUserId(id: userId);
      if (_enableDebugMode) {
        log('ANALYTICS: [SUCCESS] Firebase userId set successfully: $userId');
      }
    } catch (e) {
      if (_enableDebugMode) {
        log('ANALYTICS: [ERROR] Firebase setUserId failed for userId: $userId, Error: ${e.toString()}');
      }
    }
  }

  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isEnabled || _analytics == null) {
      if (_enableDebugMode) {
        log('ANALYTICS: [WARNING] Firebase Analytics not enabled or not initialized, cannot set user property: $name=$value');
      }
      return;
    }

    try {
      await _analytics!.setUserProperty(name: name, value: value);
      if (_enableDebugMode) {
        log('ANALYTICS: [SUCCESS] Firebase user property set successfully: $name = $value');
      }
    } catch (e) {
      if (_enableDebugMode) {
        log('ANALYTICS: [ERROR] Firebase setUserProperty failed for property: $name=$value, Error: ${e.toString()}');
      }
    }
  }
}
