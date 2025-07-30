import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';
import 'package:todo_api/todo_api.dart';

import '../strategy.dart';

/// Стратегия персистентной аутентификации с использованием Hive
class PersistStrategy implements Strategy {
  static const String _expiredToken = '-1';

  @override
  String get name => 'persist';

  @override
  String? get token => _getStoredToken();

  @override
  bool get isAuthenticated => token != null && token != _expiredToken;

  final String signInUrl;
  final AuthApi _authApi;

  PersistStrategy({required this.signInUrl, required AuthApi authApi})
    : _authApi = authApi;

  @override
  Future<bool> checkAuth() async {
    try {
      final query = Query<Null>(
        state: QueryState(
          baseUrl: '/auth/check',
          method: 'GET',
          key: 'check_auth',
        ),
      );

      final userId = await _authApi.checkAuth(query);
      final isAuthenticated = userId != null;

      if (isAuthenticated) {
        _setToken(userId);
      } else {
        _setToken(_expiredToken);
      }

      return isAuthenticated;
    } catch (e) {
      _setToken(_expiredToken);
      return false;
    }
  }

  @override
  Future<T> signIn<T, D>([D? config]) async {
    if (config == null) {
      throw Exception('Config is required');
    }
    // Извлекаем данные из конфига
    if (config is! SignInData) {
      throw Exception('Invalid config format');
    }

    final query = Query<SignInData>(
      state: QueryState(baseUrl: signInUrl, method: 'POST', data: config),
    );

    final userId = await _authApi.signIn(query);
    _setToken(userId);

    // Возвращаем пользователя без пароля
    return _createUserWithoutPassword(userId, query.state.data!.login) as T;
  }

  @override
  Future<T> signUp<T, D>([D? config]) async {
    if (config == null) {
      throw Exception('Config is required');
    }

    // Извлекаем данные из конфига
    if (config is! Query) {
      throw Exception('Invalid config format');
    }

    final query = config as Query<SignUpData>;

    final userId = await _authApi.signUp(query);
    _setToken(userId);

    // Возвращаем пользователя без пароля
    return _createUserWithoutPassword(userId, query.state.data!.login) as T;
  }

  @override
  Future<void> signOut() async {
    final query = Query<String>(
      state: QueryState(baseUrl: '/auth/signout', method: 'POST'),
    );

    await _authApi.signOut(query);
    _setToken('');
  }

  @override
  Future<void> refreshToken<T>([T? args]) async {
    final currentToken = token;
    if (currentToken != null && currentToken != _expiredToken) {
      // В текущей реализации AuthApi нет метода refreshToken,
      // поэтому используем checkAuth для обновления токена
      await checkAuth();
    }
  }

  @override
  void clear() {
    _setToken(_expiredToken);
  }

  /// Получает токен из локального хранилища
  String? _getStoredToken() {
    // В Flutter используем SharedPreferences или другое локальное хранилище
    // Для простоты используем статическую переменную
    return _storedToken;
  }

  /// Сохраняет токен в локальное хранилище
  void _setToken(String token) {
    // В Flutter используем SharedPreferences или другое локальное хранилище
    // Для простоты используем статическую переменную
    _storedToken = token;
  }

  /// Создает пользователя без пароля для возврата
  UserModel _createUserWithoutPassword(String userId, String login) {
    return UserModel(id: userId, login: login, createdAt: DateTime.now());
  }

  // Статическая переменная для хранения токена (в реальном приложении используйте SharedPreferences)
  static String? _storedToken;
}
