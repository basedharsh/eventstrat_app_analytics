import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session/session_manager.dart';
import '../tracking/analytics_config.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsEventsActionInvoker {
  final String apiEndpoint;
  final Map<String, String>? headers;
  final Dio _dio;
  final AnalyticsConfig? config;

  AnalyticsEventsActionInvoker({
    required this.apiEndpoint,
    this.headers,
    Dio? dio,
    this.config,
  }) : _dio = dio ?? Dio();

  Future<void> storeEventToLocal({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String analyticsString = prefs.getString('analytics') ?? '';
      List<Map<String, dynamic>> decodedEvents = [];

      if (analyticsString.isNotEmpty) {
        try {
          final decodedJson = jsonDecode(analyticsString);
          decodedEvents = (decodedJson as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        } catch (e) {
          if (config?.enableDebugMode ?? false) {
            log('ANALYTICS: [WARNING] Failed to decode existing events, starting fresh: ${e.toString()}');
          }
          decodedEvents = [];
        }
      }

      decodedEvents.add(eventData);
      String updatedAnalyticsString = jsonEncode(decodedEvents);
      await prefs.setString('analytics', updatedAnalyticsString);

      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [SUCCESS] Event stored locally. Total events in queue: ${decodedEvents.length}');
      }
    } catch (e) {
      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [ERROR] Failed to store event locally: ${e.toString()}');
      }
    }
  }

  Future<void> syncEventsToDB({Map<String, String>? additionalHeaders}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String sessionId = SessionManager().sessionId;
      String analyticsString = prefs.getString('analytics') ?? '';

      if (analyticsString.isEmpty) {
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [INFO] No events to sync. Queue is empty.');
        }
        return;
      }

      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [INFO] Starting sync process. SessionId: $sessionId');
      }

      List<Map<String, dynamic>> decodedEvents = [];
      try {
        final decodedJson = jsonDecode(analyticsString);
        decodedEvents = (decodedJson as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [INFO] Decoded ${decodedEvents.length} events from storage');
        }
      } catch (e) {
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [ERROR] Failed to decode analytics events: ${e.toString()}');
        }
        return;
      }

      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = "${tempDir.path}/analytics_events.json";
        final file = File(filePath);
        await file.writeAsString(jsonEncode(decodedEvents));

        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [INFO] Created temporary file for upload: $filePath');
        }

        // --form 'data="{\"sessionId\":\"session123\"}";type=application/json'
        // --form 'file=@"/path/to/file"'
        final formData = FormData();

        final dataJson = jsonEncode({'sessionId': sessionId});
        formData.files.add(MapEntry(
          'data',
          MultipartFile.fromString(
            dataJson,
            filename: 'data',
            contentType: DioMediaType.parse('application/json'),
          ),
        ));

        // Add file field with proper content type
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: 'analytics_events.json',
            contentType: DioMediaType.parse('application/json'),
          ),
        ));

        // Merge initialization headers with additional headers
        final Map<String, String> finalHeaders = {...(headers ?? {})};
        if (additionalHeaders != null) {
          finalHeaders.addAll(additionalHeaders);
        }

        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [INFO] Sending ${decodedEvents.length} events to $apiEndpoint');
          log('ANALYTICS: [DEBUG] ========== SYNC REQUEST DETAILS START ==========');
          log('ANALYTICS: [DEBUG] File Path: ${file.path}');
          log('ANALYTICS: [DEBUG] File exists: ${await file.exists()}');
          log('ANALYTICS: [DEBUG] File size: ${await file.length()} bytes');
          log('ANALYTICS: [DEBUG] File name: analytics_events.json');
          log('ANALYTICS: [DEBUG] Content Type: application/json');
          log('ANALYTICS: [DEBUG] Session ID: $sessionId');
          log('ANALYTICS: [DEBUG] API Endpoint: $apiEndpoint');
          log('ANALYTICS: [DEBUG] Total Events: ${decodedEvents.length}');
          log('ANALYTICS: [DEBUG] Request Headers: $finalHeaders');
          log('ANALYTICS: [DEBUG] Additional Headers: $additionalHeaders');
          log('ANALYTICS: [DEBUG] Form Data Fields Count: ${formData.fields.length}');
          log('ANALYTICS: [DEBUG] Form Data Files Count: ${formData.files.length}');
          log('ANALYTICS: [DEBUG] Data Field Value: ${jsonEncode({
                'sessionId': sessionId
              })}');
          log('ANALYTICS: [DEBUG] Events Payload: ${jsonEncode(decodedEvents)}');
          log('ANALYTICS: [DEBUG] ========== SYNC REQUEST DETAILS END ==========');
        }

        final options = Options(headers: finalHeaders);

        final response = await _dio.post(
          apiEndpoint,
          data: formData,
          options: options,
        );

        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [SUCCESS] Server response received. Status code: ${response.statusCode}');
          log('ANALYTICS: [INFO] Server response data: ${response.data}');
        }

        await prefs.remove('analytics');
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [SUCCESS] Events synced with backend successfully');
        }
      } catch (e) {
        if (config?.enableDebugMode ?? false) {
          log('ANALYTICS: [ERROR] Upload failed: ${e.toString()}');
          if (e is DioException) {
            log('ANALYTICS: [ERROR] Dio error type: ${e.type}, Response status: ${e.response?.statusCode}');
            log('ANALYTICS: [ERROR] Response body: ${e.response?.data}');
          }
        }
      } finally {
        try {
          final tempDir = await getTemporaryDirectory();
          final filePath = "${tempDir.path}/analytics_events.json";
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            if (config?.enableDebugMode ?? false) {
              log('ANALYTICS: [INFO] Temporary file cleaned up');
            }
          }
        } catch (e) {
          if (config?.enableDebugMode ?? false) {
            log('ANALYTICS: [WARNING] Failed to cleanup temporary file: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      if (config?.enableDebugMode ?? false) {
        log('ANALYTICS: [ERROR] Unexpected error in syncEventsToDB: ${e.toString()}');
      }
    }
  }
}
