import 'dart:convert';
import 'dart:math';

import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'package:todo_api/src/hive_client/hive_client.dart';
import 'package:todo_api/src/hive_client/hive_models/auth_hive_model.dart';
import 'package:todo_api/src/hive_client/hive_models/user_hive_model.dart';

class AuthApiImpl implements AuthApi {
  final HiveClient _hiveClient = hiveClient;

  // Константы для токенов
  static const int _defaultRefreshMs = 1000 * 60 * 5; // 5 minutes
  static const int _defaultAccessMs = 1000 * 60 * 1; // 1 minute
  static const String _salt = '1234567890';

  @override
  Future<String?> checkAuth(Query<Null> query) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Проверяем наличие токена аутентификации
    if (_hiveClient.authBox.isEmpty) {
      return null;
    }

    final authItems = _hiveClient.authBox.values.toList();
    if (authItems.isEmpty) {
      return null;
    }

    final authItem = authItems.first;
    final now = DateTime.now().millisecondsSinceEpoch;
    final tokenExpiry =
        authItem.createdAt.millisecondsSinceEpoch + authItem.accessMs;

    // Проверяем, не истек ли токен
    if (now > tokenExpiry) {
      // Пытаемся обновить токен
      try {
        await _refreshToken(authItem.userId);
        return authItem.userId;
      } catch (e) {
        // Если не удалось обновить, очищаем токен
        _hiveClient.authBox.clear();
        return null;
      }
    }

    return authItem.userId;
  }

  @override
  Future<String> signIn(Query<SignInData> query) async {
    final data = query.state.data;

    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Ищем пользователя по логину
    final users =
        _hiveClient.userBox.values.where((user) => user.login == data.login);
    final user = users.isEmpty ? null : users.first;

    if (user == null) {
      throw Exception('User not found');
    }

    // Проверяем пароль
    final hashedPassword = _createPasswordHash(data.password);
    if (user.password != hashedPassword) {
      throw Exception('Invalid password');
    }

    // Создаем токен аутентификации
    final authItem = AuthHiveModel(
      id: _generateId(),
      userId: user.id,
      createdAt: DateTime.now(),
      refreshMs: _defaultRefreshMs,
      accessMs: _defaultAccessMs,
    );

    _hiveClient.authBox.put(authItem.id, authItem);

    return user.id;
  }

  @override
  Future<String> signUp(Query<SignUpData> query) async {
    final data = query.state.data;
    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Проверяем, не существует ли уже пользователь с таким логином
    final existingUsers =
        _hiveClient.userBox.values.where((user) => user.login == data.login);
    if (existingUsers.isNotEmpty) {
      throw Exception('User already exists');
    }

    // Создаем нового пользователя
    final userHive = _registerUser(
      login: data.login,
      password: data.password,
    );

    return userHive.id;
  }

  @override
  Future<void> signOut(Query<String> query) async {
    final data = query.state.data;
    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Удаляем все токены для данного пользователя
    final authItems =
        _hiveClient.authBox.values.where((auth) => auth.userId == data);
    for (final auth in authItems) {
      _hiveClient.authBox.delete(auth.id);
    }
  }

  @override
  Future<void> updateRefreshToken() async {
    final authItems = _hiveClient.authBox.values;
    if (authItems.isNotEmpty) {
      await _refreshToken(authItems.first.userId);
    }
  }

  /// Обновляет токен аутентификации
  Future<void> _refreshToken(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Ищем существующий токен
    final authItems =
        _hiveClient.authBox.values.where((auth) => auth.userId == userId);
    if (authItems.isEmpty) {
      throw Exception('User is not authenticated');
    }

    final authItem = authItems.first;
    final now = DateTime.now().millisecondsSinceEpoch;
    final refreshExpiry =
        authItem.createdAt.millisecondsSinceEpoch + authItem.refreshMs;

    // Проверяем, не истек ли refresh токен
    if (now > refreshExpiry) {
      // Удаляем истекший токен
      _hiveClient.authBox.delete(authItem.id);
      throw Exception('Token is expired');
    }

    // Обновляем токен
    final updatedAuthItem = AuthHiveModel(
      id: authItem.id,
      userId: authItem.userId,
      createdAt: DateTime.now(),
      refreshMs: _defaultRefreshMs,
      accessMs: _defaultAccessMs,
    );

    _hiveClient.authBox.put(updatedAuthItem.id, updatedAuthItem);
  }

  /// Создает хеш пароля
  String _createPasswordHash(String password) {
    final reversed = password.split('').reversed.join('');
    return reversed + _salt;
  }

  /// Генерирует уникальный ID
  String _generateId() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Регистрирует нового пользователя
  UserHiveModel _registerUser({
    required String login,
    required String password,
  }) {
    final hashedPassword = _createPasswordHash(password);
    final userHive = UserHiveModel(
      id: _generateId(),
      login: login,
      password: hashedPassword,
      createdAt: DateTime.now().toIso8601String(),
    );

    _hiveClient.userBox.put(userHive.id, userHive);

    // Создаем токен аутентификации для нового пользователя
    final authItem = AuthHiveModel(
      id: _generateId(),
      userId: userHive.id,
      createdAt: DateTime.now(),
      refreshMs: _defaultRefreshMs,
      accessMs: _defaultAccessMs,
    );

    _hiveClient.authBox.put(authItem.id, authItem);

    return userHive;
  }
}

final authApi = AuthApiImpl();
