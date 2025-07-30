# @auth-strategy-manager/core

Core authentication strategy manager - the foundation for all authentication strategies.

## 🌍 Documentation in Other Languages

- [🇷🇺 Русский (Russian)](README_RU.md)
- [🇺🇸 English (Current)](README.md)

## Usage

```dart
import 'package:core/auth_strategy_manager.dart';
import 'package:core/strategy.dart';
import 'package:core/helpers/strategy_helper.dart';

// Create custom strategy
class CustomStrategy implements Strategy {
  @override
  String get name => 'custom';

  @override
  String? get token => null;

  @override
  bool get isAuthenticated => true;

  @override
  String? get startUrl => null;

  @override
  String? get signInUrl => null;

  @override
  Future<bool> checkAuth() async {
    // Your authentication logic
    return true;
  }

  @override
  Future<T> signIn<T, D>([D? config]) async {
    // Your sign in logic
    return {} as T;
  }

  @override
  Future<T> signUp<T, D>([D? config]) async {
    // Your sign up logic
    return {} as T;
  }

  @override
  Future<void> signOut() async {
    // Your sign out logic
    // Optionally clear storage
  }

  @override
  Future<void> refreshToken<T>([T? args]) async {
    // Your token refresh logic
  }

  @override
  void clear() {
    // Your reset logic
  }
}

// Using a custom strategy
final customStrategy = CustomStrategy();
final authManager = AuthStrategyManager([customStrategy]);

// Check authentication
final isAuthenticated = await customStrategy.checkAuth();

// Sign out
await customStrategy.signOut();

// Clear state
customStrategy.clear();
```

## API

### AuthStrategyManager

Main class for managing authentication strategies.

#### Constructor

```dart
AuthStrategyManager(List<Strategy> strategies)
```

Creates a new AuthStrategyManager instance with the provided strategies.

#### Properties

- `strategiesCount` - Total number of registered strategies
- `strategy` - Currently active strategy
- `startUrl` - URL to redirect after authentication

#### Methods

- `Future<bool> checkAuth()` - Check authentication status across all strategies. Returns true if any strategy is authenticated.
- `Future<void> setStrategies(List<Strategy> strategies)` - Replace all strategies with new ones
- `void use(String strategyName)` - Set the active strategy by name
- `void clear()` - Clear authentication state and reset all strategies

#### Usage Examples

```dart
// Create manager with strategies
final authManager = AuthStrategyManager([strategy1, strategy2]);

// Check if user is authenticated
final isAuthenticated = await authManager.checkAuth();

// Switch to specific strategy
authManager.use('custom');

// Get current active strategy
final currentStrategy = authManager.strategy;

// Clear all authentication data
authManager.clear();
```

### Strategy Interface

```dart
abstract class Strategy {
  String get name;
  String? get token;
  bool get isAuthenticated;
  String? get startUrl;
  String? get signInUrl;

  Future<bool> checkAuth();
  Future<T> signIn<T, D>([D? config]);
  Future<T> signUp<T, D>([D? config]);
  Future<void> signOut();
  Future<void> refreshToken<T>([T? args]);
  void clear();
}
```

### StrategyHelper

Helper class for managing authentication state.

#### Methods

- `Future<void> clearStorage()` - Clear local storage
- `Future<void> reset()` - Reset authentication state

## License

ISC
