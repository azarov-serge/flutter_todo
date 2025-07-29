# @auth-strategy-manager/core

Основной менеджер стратегий аутентификации — основа для всех стратегий аутентификации.

## 🌍 Документация на других языках

- [🇺🇸 English (Английский)](README.md)
- [🇷🇺 Русский (Текущий)](README_RU.md)

## Использование

```dart
import 'package:core/auth_strategy_manager.dart';
import 'package:core/strategy.dart';
import 'package:core/helpers/strategy_helper.dart';

// Создание кастомной стратегии
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
    // Ваша логика аутентификации
    return true;
  }

  @override
  Future<T> signIn<T, D>([D? config]) async {
    // Ваша логика входа
    return {} as T;
  }

  @override
  Future<T> signUp<T, D>([D? config]) async {
    // Ваша логика регистрации
    return {} as T;
  }

  @override
  Future<void> signOut() async {
    // Ваша логика выхода
    // Можно очистить storage
  }

  @override
  Future<void> refreshToken<T>([T? args]) async {
    // Ваша логика обновления токена
  }

  @override
  void clear() {
    // Ваша логика сброса
  }
}

// Использование кастомной стратегии
final customStrategy = CustomStrategy();
final authManager = AuthStrategyManager([customStrategy]);

// Проверка аутентификации
final isAuthenticated = await customStrategy.checkAuth();

// Выход из системы
await customStrategy.signOut();

// Очистка состояния
customStrategy.clear();
```

## API

### AuthStrategyManager

Главный класс для управления стратегиями аутентификации.

#### Конструктор

```dart
AuthStrategyManager(List<Strategy> strategies)
```

Создаёт новый экземпляр AuthStrategyManager с предоставленными стратегиями.

#### Свойства

- `strategiesCount` — Общее количество зарегистрированных стратегий
- `strategy` — Текущая активная стратегия
- `startUrl` — URL для перенаправления после аутентификации

#### Методы

- `Future<bool> checkAuth()` — Проверяет статус аутентификации по всем стратегиям. Возвращает true, если любая стратегия аутентифицирована.
- `Future<void> setStrategies(List<Strategy> strategies)` — Заменяет все стратегии новыми
- `void use(String strategyName)` — Устанавливает активную стратегию по имени
- `void clear()` — Очищает состояние аутентификации и сбрасывает все стратегии

#### Примеры использования

```dart
// Создание менеджера со стратегиями
final authManager = AuthStrategyManager([strategy1, strategy2]);

// Проверка аутентификации пользователя
final isAuthenticated = await authManager.checkAuth();

// Переключение на конкретную стратегию
authManager.use('custom');

// Получение текущей активной стратегии
final currentStrategy = authManager.strategy;

// Очистка всех данных аутентификации
authManager.clear();
```

### Интерфейс Strategy

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

Вспомогательный класс для управления состоянием аутентификации.

#### Методы

- `Future<void> clearStorage()` — Очистка локального хранилища
- `Future<void> reset()` — Сброс состояния аутентификации

## Лицензия

ISC 
