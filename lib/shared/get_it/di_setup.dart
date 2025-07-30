import 'get_it.dart';

/// Dependency injection setup
class DISetup {
  /// Initialize all dependencies
  static Future<void> setup() async {
    await setupDependencies();
  }

  /// Clear dependencies (for testing)
  static Future<void> reset() async {
    await clearDependencies();
  }
}
