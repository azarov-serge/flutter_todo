import 'package:todo_models/todo_models.dart';

/// Базовый класс для действий аутентификации
abstract class AuthAction {
  const AuthAction();
}

/// Действие для установки пользователя
class SetUserAction extends AuthAction {
  final UserModel user;

  const SetUserAction(this.user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetUserAction && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'SetUserAction(user: $user)';
}

/// Действие для установки токена
class SetTokenAction extends AuthAction {
  final String token;

  const SetTokenAction(this.token);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetTokenAction && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'SetTokenAction(token: $token)';
}

/// Действие для установки статуса аутентификации
class SetAuthenticatedAction extends AuthAction {
  final bool isAuthenticated;

  const SetAuthenticatedAction(this.isAuthenticated);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetAuthenticatedAction &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode => isAuthenticated.hashCode;

  @override
  String toString() =>
      'SetAuthenticatedAction(isAuthenticated: $isAuthenticated)';
}

/// Действие для установки ошибки
class SetAuthErrorAction extends AuthAction {
  final String? error;

  const SetAuthErrorAction(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetAuthErrorAction && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'SetAuthErrorAction(error: $error)';
}

/// Действие для очистки ошибки
class ClearAuthErrorAction extends AuthAction {
  const ClearAuthErrorAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearAuthErrorAction;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'ClearAuthErrorAction()';
}

/// Действие для выхода из системы
class SignOutAction extends AuthAction {
  const SignOutAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignOutAction;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'SignOutAction()';
}

/// Действие для сброса состояния аутентификации
class ResetAuthStateAction extends AuthAction {
  const ResetAuthStateAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResetAuthStateAction;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'ResetAuthStateAction()';
}
