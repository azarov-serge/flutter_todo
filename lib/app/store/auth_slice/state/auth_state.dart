import 'package:todo_models/todo_models.dart';

/// Состояние аутентификации
class AuthState {
  final UserModel? currentUser;
  final bool isAuthenticated;
  final String? token;

  const AuthState({this.currentUser, this.isAuthenticated = false, this.token});

  /// Начальное состояние
  static const AuthState initial = AuthState();

  /// Копирование с изменениями
  AuthState copyWith({
    UserModel? currentUser,
    bool? isAuthenticated,
    String? token,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.currentUser == currentUser &&
        other.isAuthenticated == isAuthenticated &&
        other.token == token;
  }

  @override
  int get hashCode {
    return currentUser.hashCode ^ isAuthenticated.hashCode ^ token.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(currentUser: $currentUser, isAuthenticated: $isAuthenticated, token: $token)';
  }
}
