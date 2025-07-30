# Flutter Todo App

A modern Flutter application for task management with robust state management and error handling.

## Architecture Overview

### Store & Slices Architecture

The application uses Redux pattern with a modular slice-based architecture for state management.

#### Core Store Structure

```dart
class AppState {
  final AuthState authState;
  final TaskState taskState;
  final CategoryState categoryState;
  final FetchState fetchState;
}
```

#### Slice Pattern

Each slice is responsible for a specific domain of the application:

- **AuthSlice**: Authentication and user management
- **TaskSlice**: Task CRUD operations
- **CategorySlice**: Category management
- **FetchSlice**: Global request state management

#### Fetch Slice (Core Component)

The `FetchSlice` is the central component for managing all API request states across the application.

**Key Features:**
- **Global Request Tracking**: Manages loading states, errors, and success states for all API calls
- **Query-based State Management**: Each request is identified by a unique query key
- **Automatic Error Handling**: Centralized error state management
- **Request Deduplication**: Prevents duplicate requests with the same key

**FetchSlice Structure:**
```dart
class FetchSlice {
  final FetchActions actions;
  final FetchThunks thunks;
  
  // Get request status by query key
  QueryStatus status(String key);
  
  // Clear error for specific request
  void clearError(Store<AppState> store, String key);
  
  // Reset state for specific request
  void resetState(Store<AppState> store, String key);
}
```

**QueryStatus Model:**
```dart
class QueryStatus {
  final bool isFetching;    // Request in progress
  final bool isFetched;     // Request completed
  final String error;       // Error message (empty if no error)
}
```

**Usage Example:**
```dart
// In any slice
final fetchSlice = getIt.get<FetchSlice>();

// Track request state
await fetchSlice.thunks.request(
  store,
  key: 'unique_request_key',
  operation: () async {
    // API call logic
    final result = await apiCall();
    store.dispatch(SetDataAction(result));
  },
);

// Get request status
final status = fetchSlice.getState(store).status('unique_request_key');
if (status.isFetching) {
  // Show loading indicator
}
if (status.error.isNotEmpty) {
  // Show error
}
```

### Verifier Component

The `Verifier` is a utility component for form validation and data verification.

**Features:**
- **Real-time Validation**: Validates input as user types
- **Custom Validation Rules**: Supports custom validation logic
- **Error State Management**: Manages validation error states
- **Visual Feedback**: Provides immediate visual feedback for validation errors

**Usage Example:**
```dart
class FormVerifier {
  static String? validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Invalid email format';
    return null;
  }
  
  static String? validatePassword(String password) {
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
```

### ErrorWrapper Component

The `ErrorWrapper` is a reusable widget for displaying error dialogs throughout the application.

**Features:**
- **Automatic Error Detection**: Automatically shows error dialogs when errors occur
- **Customizable Error Messages**: Supports custom error messages
- **Error Clearing**: Automatically clears errors when dialog is closed
- **Consistent UI**: Provides consistent error presentation across the app

**Usage Example:**
```dart
ErrorWrapper(
  error: viewModel.error,
  onClosePressed: () {
    // Clear error when dialog is closed
    store.dispatch(ClearErrorAction());
  },
  child: YourFormWidget(),
)
```

**ErrorWrapper Behavior:**
- Monitors the `error` prop for changes
- Automatically displays error dialog when error is not null/empty
- Calls `onClosePressed` callback when user closes the dialog
- Prevents multiple dialogs from showing simultaneously

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
