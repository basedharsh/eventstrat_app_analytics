# Analytics Package - Detailed Debug Logging Guide

This document outlines all the detailed debug logging added to the EventStrat App Analytics package. All logs are conditional and only display when `enableDebugMode: true` is set during initialization.

## Initialization & Configuration

### EventManager
- **[INFO]** Firebase Analytics initialization status

### FirebaseAnalyticsService
- **[SUCCESS]** Firebase Analytics initialized successfully

## User Management

### EventManager.updateUser()
- **[ERROR]** EventManager not initialized when attempting to update user
- **[SUCCESS]** Email saved to SharedPreferences with value
- **[ERROR]** Failed to save email to SharedPreferences
- **[SUCCESS]** Cohort saved to SharedPreferences with value
- **[ERROR]** Failed to save cohort to SharedPreferences
- **[SUCCESS]** User info updated with email and cohort
- **[ERROR]** Unexpected error during updateUser with full error message

### FirebaseAnalyticsService.setUserId()
- **[WARNING]** Firebase Analytics not enabled when trying to set userId
- **[SUCCESS]** Firebase userId set successfully with the userId value
- **[ERROR]** Firebase setUserId failed with error details

### FirebaseAnalyticsService.setUserProperty()
- **[WARNING]** Firebase Analytics not enabled when trying to set property
- **[SUCCESS]** Firebase user property set successfully (name=value)
- **[ERROR]** Firebase setUserProperty failed with error details

## Event Tracking

### EventManager.sendEventFirebase()
- **[ERROR]** EventManager not initialized when trying to send event
- **[INFO]** Detailed event sending info: target product, event name, screen, action, category, email, cohort, version, and misc data
- **[SUCCESS]** Event stored locally with event name
- **[ERROR]** Error in sendEventFirebase with event name and error details

### FirebaseAnalyticsService.logEvent()
- **[WARNING]** Firebase Analytics not enabled when trying to log event
- **[SUCCESS]** Firebase event logged successfully with:
  - Event name
  - Screen name
  - Action
  - Category
  - Email
  - Cohort
- **[ERROR]** Firebase logEvent failed with event name and error details

## Event DTO Conversion

### EventFirebaseDto.toJson()
- **[INFO]** Android device info retrieved (ID and Model)
- **[INFO]** iOS device info retrieved (ID and Model)
- **[ERROR]** Failed to get device info with error details
- **[SUCCESS]** Event DTO created successfully with full event data
- **[ERROR]** Failed to convert event to JSON with error details

## Event Synchronization

### AnalyticsEventsActionInvoker.storeEventToLocal()
- **[WARNING]** Failed to decode existing events, starting fresh
- **[SUCCESS]** Event stored locally with total event count in queue
- **[ERROR]** Failed to store event locally with error details

### AnalyticsEventsActionInvoker.syncEventsToDB()
- **[INFO]** No events to sync - queue is empty
- **[INFO]** Starting sync process with SessionId
- **[INFO]** Successfully decoded N events from storage
- **[ERROR]** Failed to decode analytics events with error details
- **[INFO]** Created temporary file for upload with file path
- **[INFO]** Sending N events to API endpoint
- **[SUCCESS]** Server response received with status code
- **[INFO]** Server response data (full response body)
- **[SUCCESS]** Events synced successfully and cleared from local storage
- **[ERROR]** Upload failed with error details
- **[ERROR]** Dio error details: error type, response status, response body
- **[INFO]** Temporary file cleaned up
- **[WARNING]** Failed to cleanup temporary file
- **[ERROR]** Unexpected error in syncEventsToDB

## Using Debug Mode

### Enable Debug Logging
```dart
EventstratAnalytics.initialize(
  targetProduct: 'YourApp',
  apiEndpoint: 'https://api.example.com/analytics',
  enableDebugMode: true,  // Enable all detailed logging
);
```

### Disable Debug Logging (Production)
```dart
EventstratAnalytics.initialize(
  targetProduct: 'YourApp',
  apiEndpoint: 'https://api.example.com/analytics',
  enableDebugMode: false,  // No logging in production
);
```

## Log Format

All logs follow a standard format:
```
Analytics: [LEVEL] Message details
```

Where LEVEL is one of:
- **[ERROR]** - Error conditions with full error messages
- **[SUCCESS]** - Successful operations with relevant data
- **[INFO]** - Informational messages about progress
- **[WARNING]** - Warning conditions that might need attention

## Benefits

1. **Comprehensive Error Tracking**: Every error is logged with detailed context
2. **Operation Flow Visibility**: Track the complete journey of events
3. **Performance Debugging**: Identify bottlenecks and network issues
4. **Firebase Integration Debugging**: Detailed Firebase Analytics logging
5. **Production Safe**: All logging is conditional and disabled by default

## Example Debug Output

```
Analytics: [INFO] Starting sync process. SessionId: 550e8400-e29b-41d4-a716-446655440000
Analytics: [INFO] Decoded 5 events from storage
Analytics: [INFO] Created temporary file for upload: /var/folders/1234/analytics_events.json
Analytics: [INFO] Sending 5 events to https://api.example.com/analytics
Analytics: [SUCCESS] Server response received. Status code: 200
Analytics: [INFO] Server response data: {"message": "Events received", "count": 5}
Analytics: [SUCCESS] Events synced successfully and cleared from local storage
Analytics: [INFO] Temporary file cleaned up
Analytics: [SUCCESS] Firebase event logged: button_clicked with parameters - screen: dashboard_screen, action: click, category: top_nav, email: user@example.com, cohort: premium_users
```
