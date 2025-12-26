import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalytics? _analytics;
  static bool _isEnabled = false;

  static void initialize({required bool enabled}) {
    _isEnabled = enabled;
    if (_isEnabled) {
      _analytics = FirebaseAnalytics.instance;
      log('Analytics: Firebase Analytics initialized');
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
    if (!_isEnabled || _analytics == null) return;

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

      log('Analytics: Firebase event logged: $firebaseEventName');
    } catch (e) {
      log('Analytics: Firebase error: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      log('Firebase userId set: $userId');
    } catch (e) {
      log('Firebase setUserId error: $e');
    }
  }

  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
      log('Firebase user property set: $name = $value');
    } catch (e) {
      log('Firebase setUserProperty error: $e');
    }
  }
}
