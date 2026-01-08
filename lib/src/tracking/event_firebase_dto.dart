import 'dart:io';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eventstrat_app_analytics/src/constants/event_actions.dart';
import 'package:eventstrat_app_analytics/src/tracking/analytics_config.dart';
import 'package:eventstrat_app_analytics/src/utils/device_uuid.dart';
import 'package:eventstrat_app_analytics/src/utils/get_uuid.dart';

class EventFirebaseDto {
  String eventName;
  String email;
  String eventAction;
  String? eventCategory;
  String screenName;
  String? refId;
  String? miscellaneous;
  String targetProduct;
  String? cohort;
  String? version;

  EventFirebaseDto({
    required this.eventName,
    required this.email,
    required this.screenName,
    required this.targetProduct,
    this.miscellaneous,
    this.eventCategory,
    this.refId,
    this.eventAction = EventAction.click,
    this.cohort,
    this.version,
  });

  Future<Map<String, dynamic>> toJson({AnalyticsConfig? config}) async {
    try {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = getUUID();
      data['event_name'] = eventName;
      data['email'] = email;
      data['event_action'] = eventAction;
      data['event_category'] = eventCategory;
      data['screen_name'] = screenName;
      data['cohort'] = cohort;
      data['version'] = version ?? 'unknown';

      data['ref_id'] = refId;
      data['miscellaneous'] = miscellaneous;
      data['target_product'] = targetProduct;
      data["event_timestamp"] = DateTime.now().toString();

      String rawDeviceId = '';
      String deviceModel = '';

      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          rawDeviceId = androidInfo.id;
          deviceModel = androidInfo.model;
          if (config?.enableDebugMode ?? false) {
            log('ANALYTICS: [INFO] Android device info - ID: $rawDeviceId, Model: $deviceModel');
          }
        } else if (Platform.isIOS) {
          final uuid = await DeviceUUID.getDeviceUUID(config: config);
          if (uuid.isNotEmpty) {
            rawDeviceId = uuid;
          } else {
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            rawDeviceId = iosInfo.identifierForVendor ?? '';
          }
          deviceModel = (await deviceInfo.iosInfo).utsname.machine;
          if (config?.enableDebugMode ?? false) {
            log('ANALYTICS: [INFO] iOS device info - ID: $rawDeviceId, Model: $deviceModel');
          }
        }
      } catch (e) {
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [ERROR] Failed to get device info: ${e.toString()}');
        }
        rawDeviceId = 'unknown';
        deviceModel = 'unknown';
      }

      data["device_id"] = rawDeviceId;
      data["device_model"] = deviceModel;
      data["platform"] = Platform.isAndroid ? 'android' : 'ios';

      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [SUCCESS] Event DTO created: ${data.toString()}');
      }

      return data;
    } catch (e) {
      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [ERROR] Failed to convert event to JSON: ${e.toString()}');
      }
      rethrow;
    }
  }
}
