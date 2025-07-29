import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'package:todo_api/src/hive_client/hive_client.dart';
import 'package:todo_api/src/hive_client/hive_models/auth_hive_model.dart';
import 'package:todo_api/src/hive_client/hive_models/user_hive_model.dart';

class AuthApiImpl implements AuthApi {
  final HiveClient _hiveClient = hiveClient;
  @override
  Future<String?> checkAuth(Query<Null> query) async {
    print('${query.state.method}: ${query.state.baseUrl}');
    await Future.delayed(const Duration(milliseconds: 1900));

    if (_hiveClient.authBox.length == 0) {
      return null;
    }

    final values = _hiveClient.authBox.values.toList();

    return values[0].id;
  }

  /// Return userId
  @override
  Future<String> signIn(Query<SignInData> query) async {
    final data = query.state.data;

    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (_hiveClient.userBox.length == 0) {
      throw Exception('User not found');
    }

    final users =
        _hiveClient.userBox.values.where((user) => user.login == data.login);

    final user = users.isEmpty ? null : users.first;

    // ignore: unnecessary_null_comparison
    if (user == null) {
      throw Exception('User not found');
    }

    if (user.password != data.password) {
      throw Exception('Incorrect password');
    }
    _hiveClient.authBox.add(AuthHiveModel(id: user.id));

    return user.id;
  }

  /// Return userId
  @override
  Future<String> signUp(Query<SignUpData> query) async {
    final data = query.state.data;

    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    if (_hiveClient.userBox.length == 0) {
      final userHive = _registerUser(
        login: data.login,
        password: data.password,
      );

      return userHive.id;
    }

    final existUser = _hiveClient.userBox.values
        .firstWhere((user) => user.login == data.login);

    // ignore: unnecessary_null_comparison
    if (existUser != null) {
      throw Exception('User already exists');
    }

    final userHive = _registerUser(login: data.login, password: data.password);

    return userHive.id;
  }

  @override
  Future<void> signOut(Query<String> query) async {
    final data = query.state.data;

    if (data == null) {
      throw Exception('Data is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    _hiveClient.authBox.clear();
  }

  UserHiveModel _registerUser({
    required String login,
    required String password,
  }) {
    final userHive = UserHiveModel(login: login, password: password);
    _hiveClient.userBox.put(userHive.id, userHive);
    _hiveClient.authBox.add(AuthHiveModel(id: userHive.id));

    return userHive;
  }
}
