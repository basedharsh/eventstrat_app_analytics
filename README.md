# EventStrat App Analytics

A Flutter analytics package for tracking events across multiple applications with configurable backends and device identification strategies.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Device ID Strategies](#device-id-strategies)
- [Event Tracking Best Practices](#event-tracking-best-practices)
- [API Reference](#api-reference)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Features

- **Multi-app support**: Reusable across different applications with app-specific configurations
- **Configurable backends**: Support for custom API endpoints and headers
- **Device identification strategies**: Method channel, hardware ID, or generated UUID approaches
- **Local storage**: Events are stored locally and synced to backend
- **Session management**: Automatic session tracking with UUID generation
- **Offline support**: Events stored locally when offline, synced when connection available
- **Debug mode**: Comprehensive logging for development
- **Type-safe events**: Use constants for event names to prevent typos

## Installation

### Option 1: Local Development
```yaml
# pubspec.yaml
dependencies:
  eventstrat_app_analytics:
    path: ../path/to/eventstrat_app_analytics
```

### Option 2: Git Repository
```yaml
# pubspec.yaml
dependencies:
  eventstrat_app_analytics:
    git:
      url: https://github.com/basedharsh/eventstrat_app_analytics.git
      ref: main
```

### Option 3: pub.dev
```yaml
# pubspec.yaml
dependencies:
  eventstrat_app_analytics: ^1.0.0
```

## Quick Start

### 1. Initialize Analytics

```dart
import 'package:eventstrat_app_analytics/eventstrat_app_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize analytics
  EventstratAnalytics.initialize(
    targetProduct: 'MyApp',
    apiEndpoint: 'https://api.example.com/analytics',
    userEmail: 'user@email.com',
    userCohort: 'premium_users',
    enableDebugMode: true,
  );
  
  runApp(MyApp());
}
```

### 2. Create Event Constants

```dart
// lib/analytics/app_events.dart
class AppEvents {
  static const loginAttempted = 'login_attempted';
  static const dashboardViewed = 'dashboard_viewed';
  static const buttonClicked = 'button_clicked';
  static const featureUsed = 'feature_used';
  static const dataExported = 'data_exported';
}

// lib/analytics/app_screens.dart
class AppScreens {
  static const loginScreen = 'login_screen';
  static const dashboardScreen = 'dashboard_screen';
  static const settingsScreen = 'settings_screen';
}
```

### 3. Track Events

```dart
import 'package:eventstrat_app_analytics/eventstrat_app_analytics.dart';
import 'analytics/app_events.dart';
import 'analytics/app_screens.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onTap: () {
        // Track button click
        EventstratAnalytics.track(
          event: AppEvents.buttonClicked,
          screen: AppScreens.dashboardScreen,
          action: EventAction.click,
          category: EventCategory.topNav,
          miscellaneous: 'export_data_button',
        );
        
        // Your button action
        exportData();
      },
      child: Text('Export Data'),
    );
  }
}
```

## Configuration

### Basic Configuration

```dart
EventstratAnalytics.initialize(
  targetProduct: 'YourAppName',           // Required
  apiEndpoint: 'https://your-api.com',    // Required
  userEmail: 'user@email.com',            // Optional
  userCohort: 'premium_users',            // Optional
  enableDebugMode: false,                 // Optional, default false
);
```

### Advanced Configuration

```dart
EventstratAnalytics.initialize(
  targetProduct: 'YourAppName',
  apiEndpoint: 'https://your-api.com/analytics',
  userEmail: 'user@email.com',
  userCohort: 'beta_users',
  headers: {
    'Authorization': 'Bearer your-token',
    'Content-Type': 'application/json',
  },
  enableDebugMode: true,
  deviceIdStrategy: DeviceIdStrategy.hardwareId,
  methodChannelName: 'com.yourcompany.device_uuid',
);
```

## Usage

### Tracking Events

#### Basic Event Tracking
```dart
EventstratAnalytics.track(
  event: 'user_login',
  screen: 'login_screen',
);
```

#### Detailed Event Tracking
```dart
EventstratAnalytics.track(
  event: AppEvents.featureUsed,
  screen: AppScreens.dashboardScreen,
  action: EventAction.click,
  category: EventCategory.topNav,
  miscellaneous: 'additional_data',
  targetProduct: 'SpecificProduct', // Override default
);
```

### Manual Sync

```dart
// Force sync stored events to backend
await EventstratAnalytics.sync();

// Sync with custom headers
await EventstratAnalytics.sync(headers: {'Authorization': 'Bearer token'});
```

### Update User Information

```dart
await EventstratAnalytics.updateUser(
  email: 'new@email.com',
  cohort: 'premium_users',
);
```

### Using Built-in Constants

```dart
import 'package:eventstrat_app_analytics/eventstrat_app_analytics.dart';

EventstratAnalytics.track(
  event: 'button_clicked',
  screen: 'home_screen',
  action: EventAction.click,        // 'click'
  category: EventCategory.topNav,   // 'top_nav'
);
```

## Device ID Strategies

### Hardware ID (Recommended)
Uses actual device identifiers via `device_info_plus`:
```dart
deviceIdStrategy: DeviceIdStrategy.hardwareId,
```
- **Android**: Uses Android ID
- **iOS**: Uses identifierForVendor
- **Fallback**: Generates UUID if hardware ID unavailable

### Method Channel (Custom Implementation)
For apps with custom native device ID implementation:
```dart
deviceIdStrategy: DeviceIdStrategy.methodChannel,
methodChannelName: 'com.yourapp.device_uuid',
```

### Generated UUID
Creates and persists a random UUID:
```dart
deviceIdStrategy: DeviceIdStrategy.generated,
```

## Event Tracking Best Practices

### 1. Consistent Naming Convention
```dart
class AppEvents {
  // Use descriptive, consistent names
  static const userLoginAttempted = 'user_login_attempted';
  static const userLoginSuccessful = 'user_login_successful';
  static const userLoginFailed = 'user_login_failed';
  
  // Group related events
  static const dashboardViewed = 'dashboard_viewed';
  static const dashboardFiltered = 'dashboard_filtered';
  static const dashboardExported = 'dashboard_exported';
}
```

### 2. Meaningful Categories
```dart
EventstratAnalytics.track(
  event: AppEvents.buttonClicked,
  screen: 'settings_screen',
  category: EventCategory.bottomNav,  // Where the action occurred
  miscellaneous: 'save_preferences', // What specifically was done
);
```

### 3. Screen Tracking
```dart
class MyScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Track screen views
    EventstratAnalytics.track(
      event: 'screen_viewed',
      screen: 'settings_screen',
      action: EventAction.view,
      category: EventCategory.screen,
    );
  }
}
```

## API Reference

### EventstratAnalytics

#### `initialize()`
```dart
static void initialize({
  required String targetProduct,
  required String apiEndpoint,
  String? userEmail,
  String? userCohort,
  Map<String, String>? headers,
  bool enableDebugMode = false,
  DeviceIdStrategy deviceIdStrategy = DeviceIdStrategy.hardwareId,
  String? methodChannelName,
})
```

#### `track()`
```dart
static Future<void> track({
  required String event,
  required String screen,
  String action = EventAction.click,
  String? category,
  String? miscellaneous,
  String? targetProduct,
})
```

#### `sync()`
```dart
static Future<void> sync({Map<String, String>? headers})
```

#### `updateUser()`
```dart
static Future<void> updateUser({String? email, String? cohort})
```

### Constants

#### EventAction
- `EventAction.click` - User tap/click actions
- `EventAction.view` - Screen/content views
- `EventAction.scroll` - Scrolling actions
- `EventAction.route` - Navigation actions

#### EventCategory
- `EventCategory.screen` - Screen-related events
- `EventCategory.topNav` - Top navigation events
- `EventCategory.bottomNav` - Bottom navigation events
- `EventCategory.bottomSheet` - Bottom sheet events

#### DeviceIdStrategy
- `DeviceIdStrategy.hardwareId` - Use device hardware identifiers
- `DeviceIdStrategy.methodChannel` - Use custom method channel
- `DeviceIdStrategy.generated` - Use generated UUID

## Deployment

### Directory Structure
```
your_projects/
├── eventstrat_app_analytics/     # Analytics package
│   ├── pubspec.yaml
│   ├── lib/
│   └── README.md
├── app_one/                      # First application
│   └── pubspec.yaml
├── app_two/                      # Second application
│   └── pubspec.yaml
└── app_three/                    # Third application
    └── pubspec.yaml
```

### Version Management
Use Git tags for version control:
```bash
git tag v1.0.0
git push origin v1.0.0
```

Reference specific versions in apps:
```yaml
dependencies:
  eventstrat_app_analytics:
    git:
      url: https://github.com/basedharsh/eventstrat_app_analytics.git
      ref: v1.0.0
```

### Updating the Package
1. Make changes to the analytics package
2. Test with a development app
3. Create new version tag
4. Update apps to use new version

## Troubleshooting

### Common Issues

#### Package Not Found
```
Error: Could not find package eventstrat_app_analytics
```
**Solution**: Verify the path/git URL in pubspec.yaml and run `flutter pub get`

#### Initialization Error
```
StateError: EventstratAnalytics not initialized
```
**Solution**: Call `EventstratAnalytics.initialize()` before using `track()`

#### Device UUID Issues
```
Device UUID returns empty string
```
**Solutions**:
- Switch to `DeviceIdStrategy.generated`
- Check device permissions
- Verify method channel implementation (if using custom)

#### Sync Failures
```
Upload failed: Connection timeout
```
**Solutions**:
- Check API endpoint URL
- Verify network connectivity
- Check API authentication headers

### Debug Mode
Enable debug logging to troubleshoot issues:
```dart
EventstratAnalytics.initialize(
  // ... other config
  enableDebugMode: true,
);
```

This will output detailed logs showing:
- Event tracking attempts
- Storage operations
- Sync operations
- Error messages

### Best Practices for Production

1. **Disable debug mode**: Set `enableDebugMode: false` in production
2. **Handle initialization**: Always initialize analytics in `main()`
3. **Error handling**: Wrap tracking calls in try-catch if needed
4. **Testing**: Test analytics integration thoroughly before release
5. **Privacy**: Ensure compliance with privacy policies when tracking user data

## Example Apps

### EventStrat App Integration
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  EventstratAnalytics.initialize(
    targetProduct: 'EventStratApp',
    apiEndpoint: 'https://eventstrat-api.com/analytics',
    deviceIdStrategy: DeviceIdStrategy.hardwareId,
  );
  
  runApp(EventStratApp());
}

// eventstrat_events.dart
class EventStratEvents {
  static const eventCreated = 'event_created';
  static const eventViewed = 'event_viewed';
  static const eventRegistered = 'event_registered';
  static const strategyApplied = 'strategy_applied';
  static const dashboardOpened = 'dashboard_opened';
}
```

This package provides a robust, flexible analytics solution that can be easily integrated across multiple Flutter applications while maintaining consistency and reliability.