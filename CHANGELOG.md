## 0.0.6
* api call format change

## 0.0.5

* **Unified Log Prefix**: Added `ANALYTICS:` prefix to all log messages for consistent identification
* **Improved Backend Sync Messaging**: Changed sync success message to "Events synced with backend successfully" for clarity
* **Better Log Readability**: Standardized log format across all components
* **Production-Ready**: All logs properly prefixed and labeled for easy filtering in log aggregation systems

## 0.0.4

* **Comprehensive Debug Logging**: Added detailed debug logging throughout the package (only shows when `enableDebugMode: true`)
* **Enhanced Error Handling**: All error conditions now include full context and error messages
* **Event Tracking Improvements**: 
  - Detailed event parameter logging
  - Event queue tracking
  - Success/failure status for each operation
* **Firebase Analytics Enhancements**:
  - Detailed Firebase event logging with all parameters
  - User ID and property setting with error context
  - Firebase initialization status logging
  - Comprehensive error messages for all Firebase operations
* **Network Debugging**:
  - API endpoint request/response logging
  - Server response status and body logging
  - Dio error details (error type, response status, response body)
  - Network sync progress tracking
  - SessionId logging for debugging request tracking
* **Device Info Logging**:
  - Platform-specific device information (Android/iOS)
  - Device ID and model tracking
  - Fallback mechanism logging
  - Device info retrieval error handling
* **Local Storage**:
  - Event persistence tracking with queue count
  - Event queue count monitoring
  - File creation and cleanup logging
  - Event decode/encode error handling
* **Log Levels Implemented**:
  - [ERROR] - Error conditions with full context and stack traces
  - [SUCCESS] - Successful operations with relevant data
  - [INFO] - Operational progress and flow information
  - [WARNING] - Conditions needing attention
* **API Request Format Update**: Changed multipart form data format to include sessionId in data field alongside file upload
* **New Documentation**: Added DEBUG_LOGGING.md with complete logging reference guide and examples
* Removed unnecessary logs for production builds
* All logging is conditional and disabled by default
* No performance impact in production

## 0.0.3
* Removed logs for vapt issue

## 0.0.2

* Added Firebase Analytics integration
* Events now sent to both backend API and Firebase
* Added `enableFirebase` parameter in initialize
* Bug fix: Fixed user_cohort storage key inconsistency
* Added Firebase user properties and userId support



## 0.0.1

* Initial release
* Multi-app analytics support with configurable backends
* Device identification strategies (hardware ID, method channel, generated UUID)
* Local storage with automatic sync to backend
* Session management with UUID generation
* Offline support - events stored locally when offline
* Debug mode with comprehensive logging
* Type-safe event constants and categories