// import 'dart:io';

// void main() async {
//   // Create main export file
//   await File('eventstrat_app_analytics.dart').create();

//   // Create directories
//   final directories = [
//     'src/tracking',
//     'src/constants',
//     'src/storage',
//     'src/session',
//     'src/utils',
//     'src/router',
//   ];

//   for (final dir in directories) {
//     await Directory(dir).create(recursive: true);
//   }

//   // Create files
//   final files = [
//     // Tracking files
//     'src/tracking/event_manager.dart',
//     'src/tracking/event_firebase_dto.dart',
//     'src/tracking/analytics_config.dart',

//     // Constants files
//     'src/constants/event_actions.dart',
//     'src/constants/event_category.dart',
//     'src/constants/event_name.dart',
//     'src/constants/event_screen_name.dart',

//     // Storage files
//     'src/storage/firebase_events_action_invoker.dart',
//     'src/storage/json_encoding_decoding.dart',

//     // Session file
//     'src/session/session_manager.dart',

//     // Utils files
//     'src/utils/event_misc_value.dart',
//     'src/utils/get_uuid.dart',
//     'src/utils/device_uuid.dart',

//     // Router files
//     'src/router/analytics_go_route.dart',
//     'src/router/analytics_route_observer.dart',

//     // Wrapper file
//     'src/analytics_wrapper.dart',
//   ];

//   for (final filePath in files) {
//     await File(filePath).create();
//   }

//   print('Package structure created successfully!');
//   print(
//     'Created ${directories.length} directories and ${files.length + 1} files.',
//   );
// }
