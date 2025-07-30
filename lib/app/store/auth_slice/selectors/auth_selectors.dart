import '../state/auth_state.dart';
import 'package:todo_models/todo_models.dart';

/// Селекторы для аутентификации
class AuthSelectors {
  /// Получить текущего пользователя
  static UserModel? getCurrentUser(AuthState state) {
    return state.currentUser;
  }

  /// Проверить, аутентифицирован ли пользователь
  static bool isAuthenticated(AuthState state) {
    return state.isAuthenticated;
  }

  /// Получить токен
  static String? getToken(AuthState state) {
    return state.token;
  }

  /// Получить ID текущего пользователя
  static String? getCurrentUserId(AuthState state) {
    return state.currentUser?.id;
  }

  /// Получить логин текущего пользователя
  static String? getCurrentUserLogin(AuthState state) {
    return state.currentUser?.login;
  }

  /// Получить дату создания пользователя
  static DateTime? getCurrentUserCreatedAt(AuthState state) {
    return state.currentUser?.createdAt;
  }

  /// Проверить, есть ли токен
  static bool hasToken(AuthState state) {
    return state.token != null && state.token!.isNotEmpty;
  }

  /// Проверить, загружается ли что-то (можно расширить для интеграции с fetch slice)
  static bool isFetching(AuthState state) {
    // В будущем можно добавить интеграцию с fetch slice
    return false;
  }
}
