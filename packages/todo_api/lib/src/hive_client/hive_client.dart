import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import 'hive_models/hive_models.dart';

class HiveClient {
  late final Box<AuthHiveModel> authBox;
  late final Box<UserHiveModel> userBox;
  late final Box<CategoryHiveModel> categoriesBox;
  late final Box<TaskHiveModel> tasksBox;

  Future<void> hiveOpenBox() async {
    authBox = await Hive.openBox('auth');
    userBox = await Hive.openBox('user');
    categoriesBox = await Hive.openBox('categories');
    tasksBox = await Hive.openBox('tasks');
  }
}

final hiveClient = HiveClient();
