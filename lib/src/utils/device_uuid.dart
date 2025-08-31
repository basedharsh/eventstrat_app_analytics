import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../tracking/analytics_config.dart';

class DeviceUUID {
  static const _prefsKey = 'device_uuid';
  static const _fallbackPrefsKey = 'device_uuid_fallback';

  static Future<String> getDeviceUUID({AnalyticsConfig? config}) async {
    final strategy = config?.deviceIdStrategy ?? DeviceIdStrategy.hardwareId;

    switch (strategy) {
      case DeviceIdStrategy.methodChannel:
        return _getMethodChannelUUID(
          config?.methodChannelName ?? 'default_channel',
        );
      case DeviceIdStrategy.hardwareId:
        return _getHardwareUUID();
      case DeviceIdStrategy.generated:
        return _getGeneratedUUID();
    }
  }

  static Future<String> _getMethodChannelUUID(String channelName) async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_prefsKey);
    if (uuid != null && uuid.isNotEmpty) {
      return uuid;
    }

    try {
      final channel = MethodChannel(channelName);
      uuid = await channel.invokeMethod<String>('getDeviceUUID');
      if (uuid != null && uuid.isNotEmpty) {
        await prefs.setString(_prefsKey, uuid);
        return uuid;
      }
    } catch (e) {
      // Fallback to hardware ID if method channel fails
      return _getHardwareUUID();
    }

    return '';
  }

  static Future<String> _getHardwareUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_prefsKey);
    if (uuid != null && uuid.isNotEmpty) {
      return uuid;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      if (deviceId.isNotEmpty) {
        await prefs.setString(_prefsKey, deviceId);
        return deviceId;
      }
    } catch (e) {
      // Fallback to generated UUID
      return _getGeneratedUUID();
    }

    return '';
  }

  static Future<String> _getGeneratedUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_fallbackPrefsKey);
    if (uuid != null && uuid.isNotEmpty) {
      return uuid;
    }

    uuid = const Uuid().v4();
    await prefs.setString(_fallbackPrefsKey, uuid);
    return uuid;
  }
}
