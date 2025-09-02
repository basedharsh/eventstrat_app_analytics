import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session/session_manager.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsEventsActionInvoker {
  final String apiEndpoint;
  final Map<String, String>? headers;
  final Dio _dio;

  AnalyticsEventsActionInvoker({
    required this.apiEndpoint,
    this.headers,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Future<void> storeEventToLocal({
    required Map<String, dynamic> eventData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String analyticsString = prefs.getString('analytics') ?? '';
    List<Map<String, dynamic>> decodedEvents = [];

    if (analyticsString.isNotEmpty) {
      try {
        final decodedJson = jsonDecode(analyticsString);
        decodedEvents =
            (decodedJson as List)
                .map((e) => e as Map<String, dynamic>)
                .toList();
      } catch (e) {
        decodedEvents = [];
      }
    }

    decodedEvents.add(eventData);
    String updatedAnalyticsString = jsonEncode(decodedEvents);
    await prefs.setString('analytics', updatedAnalyticsString);
  }

  Future<void> syncEventsToDB({Map<String, String>? additionalHeaders}) async {
    final prefs = await SharedPreferences.getInstance();
    String sessionId = SessionManager().sessionId;
    String analyticsString = prefs.getString('analytics') ?? '';

    if (analyticsString.isEmpty) {
      log('No events to sync');
      return;
    }

    List<Map<String, dynamic>> decodedEvents = [];
    try {
      final decodedJson = jsonDecode(analyticsString);
      decodedEvents =
          (decodedJson as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      log('Failed to decode analytics events: ${e.toString()}');
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/analytics_events.json";
      final file = await File(
        filePath,
      ).writeAsString(jsonEncode(decodedEvents));

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'analytics_events.json',
        ),
      });

      // Merge initialization headers with additional headers
      final Map<String, String> finalHeaders = {...(headers ?? {})};
      if (additionalHeaders != null) {
        finalHeaders.addAll(additionalHeaders);
      }

      final options = Options(headers: finalHeaders);

      final response = await _dio.post(
        "$apiEndpoint?sessionId=$sessionId",
        data: formData,
        options: options,
      );
      log("The response from server: ${response.data}");

      await prefs.remove('analytics');
      log('Analytics events synced successfully');
    } catch (e) {
      log('Upload failed: ${e.toString()}');
    } finally {
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/analytics_events.json";
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
