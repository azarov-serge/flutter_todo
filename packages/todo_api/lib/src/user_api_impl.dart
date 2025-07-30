import 'dart:convert';
import 'dart:math';

import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'package:todo_api/src/hive_client/hive_client.dart';
import 'package:todo_api/src/hive_client/hive_models/user_hive_model.dart';

class UserApiImpl implements UserApi {
  final HiveClient _hiveClient = hiveClient;

  @override
  Future<List<UserModel>> fetchList(Query<Null> query) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Получаем всех пользователей из Hive
    final users = _hiveClient.userBox.values.toList();

    // Конвертируем в UserModel и убираем пароли
    return users.map((user) => UserModel.fromJson(user.toJson())).toList();
  }

  @override
  Future<UserModel> fetchItem(Query<String> query) async {
    final userId = query.state.data;

    if (userId == null) {
      throw Exception('User ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final user = _hiveClient.userBox.get(userId);

    if (user == null) {
      throw Exception('User not found');
    }

    // Возвращаем пользователя без пароля
    final userJson = user.toJson();
    userJson['password'] = '';

    return UserModel.fromJson(userJson);
  }

  @override
  Future<UserModel> create(Query<UserModel> query) async {
    final userData = query.state.data;

    if (userData == null) {
      throw Exception('User data is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Проверяем, не существует ли уже пользователь с таким логином
    final existingUsers = _hiveClient.userBox.values
        .where((user) => user.login == userData.login);
    if (existingUsers.isNotEmpty) {
      throw Exception('User with this login already exists');
    }

    // Создаем нового пользователя (пароль генерируется случайно)
    final userHive = UserHiveModel(
      id: _generateId(),
      login: userData.login,
      password: _createPasswordHash(
          'default_password'), // Используем дефолтный пароль
      createdAt: DateTime.now(),
    );

    _hiveClient.userBox.put(userHive.id, userHive);

    // Возвращаем созданного пользователя без пароля
    final userJson = userHive.toJson();
    userJson['password'] = '';

    return UserModel.fromJson(userJson);
  }

  @override
  Future<UserModel> update(Query<UserModel> query) async {
    final userData = query.state.data;

    if (userData == null) {
      throw Exception('User data is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Проверяем, существует ли пользователь
    final existingUser = _hiveClient.userBox.get(userData.id);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    // Проверяем, не занят ли логин другим пользователем
    final usersWithSameLogin = _hiveClient.userBox.values.where(
        (user) => user.login == userData.login && user.id != userData.id);
    if (usersWithSameLogin.isNotEmpty) {
      throw Exception('User with this login already exists');
    }

    // Обновляем пользователя (пароль остается прежним)
    final updatedUser = UserHiveModel(
      id: userData.id,
      login: userData.login,
      password: existingUser.password, // Сохраняем существующий пароль
      createdAt: existingUser.createdAt,
    );

    _hiveClient.userBox.put(updatedUser.id, updatedUser);

    // Возвращаем обновленного пользователя без пароля
    final userJson = updatedUser.toJson();
    userJson['password'] = '';

    return UserModel.fromJson(userJson);
  }

  @override
  Future<bool> delete(Query<String> query) async {
    final userId = query.state.data;

    if (userId == null) {
      throw Exception('User ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Проверяем, существует ли пользователь
    final existingUser = _hiveClient.userBox.get(userId);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    // Удаляем пользователя
    _hiveClient.userBox.delete(userId);

    // Удаляем все токены аутентификации для этого пользователя
    final authItems =
        _hiveClient.authBox.values.where((auth) => auth.userId == userId);
    for (final auth in authItems) {
      _hiveClient.authBox.delete(auth.id);
    }

    return true;
  }

  /// Создает хеш пароля
  String _createPasswordHash(String password) {
    const salt = '1234567890';
    final reversed = password.split('').reversed.join('');
    return reversed + salt;
  }

  /// Генерирует уникальный ID
  String _generateId() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }
}
