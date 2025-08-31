import 'package:eventstrat_app_analytics/src/utils/get_uuid.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  late final String sessionId;

  SessionManager._internal() {
    sessionId = getUUID();
  }
}
