import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_client/hive_models/auth_hive_model.dart';
import 'hive_client/hive_models/category_hive_model.dart';
import 'hive_client/hive_models/user_hive_model.dart';
import 'hive_client/hive_models/task_hive_model.dart';
import 'hive_client/hive_client.dart';

Future<void> initTodoApi() async {
  // Инициализируем Flutter binding перед использованием сервисов
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    Hive.initFlutter();
  } else {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();

    print('***** Hive path: ${appDocumentDir.path}');
    await Hive.initFlutter(appDocumentDir.path);
  }

  Hive.registerAdapter(AuthHiveModelAdapter());
  Hive.registerAdapter(UserHiveModelAdapter());
  Hive.registerAdapter(CategoryHiveModelAdapter());
  Hive.registerAdapter(TaskHiveModelAdapter());
  await hiveClient.hiveOpenBox();
}
