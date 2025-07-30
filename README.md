# Flutter Todo App

A modern Flutter application for task management with robust state management using Riverpod and feature-based architecture.

## Architecture Overview

### Riverpod State Management

The application uses **Riverpod** for state management, providing a modern, type-safe, and testable approach to managing application state.

#### Core Providers Structure

```dart
// Request State Management
final requestNotifierProvider = StateNotifierProvider<RequestNotifier, Map<String, RequestState>>((ref) {
  return RequestNotifier();
});

// Feature-specific Notifiers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    GetIt.instance.get<AuthStrategyManager>(),
    ref.watch(requestNotifierProvider.notifier),
    ref.watch(categoryNotifierProvider.notifier),
  );
});

final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(
    GetIt.instance.get<CategoryApi>(),
    ref.watch(requestNotifierProvider.notifier),
  );
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    GetIt.instance.get<TaskApi>(),
    ref.watch(requestNotifierProvider.notifier),
  );
});
```

### Feature-Based Architecture

The application follows a **feature-based architecture** where each feature is self-contained with its own views, providers, and models.

```
lib/
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   ├── auth_state.dart
│   │   │   ├── auth_notifier.dart
│   │   │   └── auth_query.dart
│   │   └── views/
│   │       └── auth_page/
│   ├── categories/
│   │   ├── providers/
│   │   │   ├── category_state.dart
│   │   │   ├── category_notifier.dart
│   │   │   └── category_query.dart
│   │   └── views/
│   │       ├── categories_page/
│   │       └── category_editor_page/
│   └── tasks/
│       ├── providers/
│       │   ├── task_state.dart
│       │   ├── task_notifier.dart
│       │   └── task_query.dart
│       └── views/
│           ├── tasks_page/
│           └── task_editor/
├── shared/
│   ├── providers/
│   │   ├── request_provider.dart
│   │   └── app_provider.dart
│   ├── widgets/
│   │   └── verifier/
│   └── ui_kit/
└── app/
    ├── app.dart
    └── routes.dart
```

### Request State Management (RequestNotifier)

The `RequestNotifier` is the central component for managing all API request states across the application.

**Key Features:**
- **Global Request Tracking**: Manages loading states, errors, and success states for all API calls
- **Query-based State Management**: Each request is identified by a unique query key
- **Automatic Error Handling**: Centralized error state management
- **Request Deduplication**: Prevents duplicate requests with the same key

**RequestNotifier Structure:**
```dart
class RequestNotifier extends StateNotifier<Map<String, RequestState>> {
  // Set loading state for specific request
  void setLoading(String key);
  
  // Set success state for specific request
  void setSuccess(String key);
  
  // Set error state for specific request
  void setError(String key, String error);
  
  // Clear error for specific request
  void clearError(String key);
  
  // Get request state by key
  RequestState getState(String key);
}
```

**RequestState Model:**
```dart
class RequestState {
  final bool isLoading;     // Request in progress
  final bool isCompleted;   // Request completed
  final String error;       // Error message (empty if no error)
}
```

**Usage Example:**
```dart
// In any notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  Future<void> fetchCategories() async {
    final query = CategoryQuery.categories(userId);
    final requestKey = query.state.key;

    try {
      _requestNotifier.setLoading(requestKey);
      final categories = await _categoryApi.fetchList(query);
      state = state.copyWith(categories: categories);
      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }
}

// In UI
final requestState = ref.watch(requestStateProvider(query.state.key));
if (requestState.isLoading) {
  // Show loading indicator
}
if (requestState.error.isNotEmpty) {
  // Show error
}
```

### Query Factory Pattern

The application uses a **Query Factory Pattern** to centralize API query definitions and improve type safety.

**Query Factory Structure:**
```dart
class CategoryQuery {
  // Get all categories for user
  static Query<List<CategoryModel>> categories(String userId) {
    return Query(
      method: 'GET',
      path: '/categories',
      params: {'userId': userId},
    );
  }
  
  // Get specific category
  static Query<CategoryModel> category(String id) {
    return Query(
      method: 'GET',
      path: '/categories/$id',
    );
  }
  
  // Create category
  static Query<CategoryModel> creationCategory(CategoryModel category) {
    return Query(
      method: 'POST',
      path: '/categories',
      body: category.toJson(),
    );
  }
}
```

### State Optimization

The application implements **state optimization** by removing redundant fields and relying on centralized state management.

**Optimized State Structure:**
```dart
class CategoryState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;  // Only ID, not full object
  final String? userId;              // User ID for filtering

  // Getter for selected category
  CategoryModel? get selectedCategory {
    if (selectedCategoryId == null) return null;
    return categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => null,
    );
  }
}
```

### Verifier Component

The `Verifier` is a Riverpod-based widget for authentication verification and conditional rendering.

**Features:**
- **Authentication Verification**: Automatically checks authentication status
- **Conditional Rendering**: Shows different content based on auth state
- **Loading States**: Displays splash screen during auth checks
- **Automatic Redirects**: Redirects to auth page if not authenticated

**Usage Example:**
```dart
class Verifier extends ConsumerStatefulWidget {
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final requestState = ref.watch(requestStateProvider(authQueryKey));

    if (requestState.isLoading) {
      return SplashScreen(message: 'Checking authentication...');
    }

    if (!isAuthenticated) {
      return AuthPage();
    }

    return child; // Show main app content
  }
}
```

### ErrorWrapper Component

The `ErrorWrapper` is a reusable widget for displaying error dialogs throughout the application.

**Features:**
- **Automatic Error Detection**: Automatically shows error dialogs when errors occur
- **Request State Integration**: Works seamlessly with RequestNotifier
- **Error Clearing**: Automatically clears errors when dialog is closed
- **Consistent UI**: Provides consistent error presentation across the app

**Usage Example:**
```dart
ErrorWrapper(
  error: requestState.error,
  onClosePressed: () {
    ref.read(requestNotifierProvider.notifier).clearError(query.state.key);
  },
  child: YourWidget(),
)
```

## Application Flow

### Authentication Flow

1. **App Launch**: Verifier checks authentication status
2. **Not Authenticated**: Redirects to AuthPage
3. **Sign In/Sign Up**: User authenticates via AuthPage
4. **Success**: Verifier shows main app content (CategoriesPage)
5. **Sign Out**: AuthNotifier updates state, Verifier redirects to AuthPage

### Data Flow

1. **User Action**: User performs action (create, edit, delete)
2. **Notifier Update**: Feature notifier updates state via RequestNotifier
3. **API Call**: Request is made to backend
4. **State Update**: Success/error state is updated
5. **UI Update**: UI automatically updates based on state changes

### Navigation Flow

1. **CategoriesPage**: Main page showing user's categories
2. **CategoryEditorPage**: Create/edit categories
3. **TasksPage**: View tasks for specific category
4. **TaskEditorPage**: Create/edit tasks
5. **Navigation Drawer**: User profile and sign out

## Key Features

- ✅ **Modern State Management**: Riverpod for type-safe state management
- ✅ **Feature-Based Architecture**: Modular, maintainable code structure
- ✅ **Centralized Request Management**: RequestNotifier for all API calls
- ✅ **Query Factory Pattern**: Type-safe API query definitions
- ✅ **State Optimization**: Efficient state management without redundancy
- ✅ **Authentication Flow**: Seamless auth verification and redirects
- ✅ **Error Handling**: Comprehensive error management with ErrorWrapper
- ✅ **Pull-to-Refresh**: Refresh data by swiping down
- ✅ **Real-time Validation**: Form validation with immediate feedback

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
