import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:redux/redux.dart';

/// Базовый класс для действий fetch
abstract class FetchAction {
  const FetchAction();
}

/// Начало запроса
class FetchStartAction extends FetchAction {
  final String key;

  const FetchStartAction(this.key);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchStartAction && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FetchStartAction(key: $key)';
}

/// Успешное завершение
class FetchSuccessAction extends FetchAction {
  final String key;

  const FetchSuccessAction(this.key);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchSuccessAction && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FetchSuccessAction(key: $key)';
}

/// Ошибка
class FetchFailureAction extends FetchAction {
  final String key;
  final String error;

  const FetchFailureAction(this.key, this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchFailureAction &&
        other.key == key &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(key, error);

  @override
  String toString() => 'FetchFailureAction(key: $key, error: $error)';
}

/// Сброс статуса
class FetchResetAction extends FetchAction {
  final String key;

  const FetchResetAction(this.key);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchResetAction && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FetchResetAction(key: $key)';
}

/// Очистка ошибки
class FetchClearErrorAction extends FetchAction {
  final String key;

  const FetchClearErrorAction(this.key);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchClearErrorAction && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FetchClearErrorAction(key: $key)';
}

class FetchActions {
  /// Сбросить ошибку по ключу
  void clearError(Store<AppState> store, String key) {
    store.dispatch(FetchClearErrorAction(key));
  }

  /// Сбросить состояние по ключу
  void resetState(Store<AppState> store, String key) {
    store.dispatch(FetchResetAction(key));
  }
}
