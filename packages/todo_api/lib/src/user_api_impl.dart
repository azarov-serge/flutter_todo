import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'hive_client/hive_client.dart';

class UserApiImpl implements UserApi {
  final HiveClient _hiveClient = hiveClient;

  @override
  Future<UserModel> fetchItem(Query<String> query) async {
    final userId = query.state.data;

    if (userId == null) {
      throw Exception('User ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (_hiveClient.authBox.length == 0) {
      throw Exception('User not found');
    }

    final user = _hiveClient.userBox.get(userId);

    if (user == null) {
      throw Exception('User not found');
    }

    return UserModel.fromJson(user.toJson());
  }
}
