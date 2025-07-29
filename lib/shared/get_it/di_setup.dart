import 'get_it.dart';

/// Настройка dependency injection
class DISetup {
  /// Инициализация всех зависимостей
  static Future<void> setup() async {
    await initializeDependencies();
  }

  /// Очистка зависимостей (для тестов)
  static Future<void> reset() async {
    await resetDependencies();
  }
}
