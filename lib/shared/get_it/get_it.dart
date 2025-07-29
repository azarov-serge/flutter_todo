import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/category_slice/category_slice.dart';
import 'package:flutter_todo/app/store/fetch_slice/fetch_slice.dart';
import 'package:flutter_todo/app/store/store.dart';
import 'package:flutter_todo/app/store/task_slice/task_slice.dart';
import 'package:get_it/get_it.dart';
import 'package:redux/redux.dart';
import 'package:todo_api/todo_api.dart';

/// Глобальный инстанс GetIt для dependency injection
final GetIt getIt = GetIt.instance;

/// Инициализация всех зависимостей
Future<void> initializeDependencies() async {
  // Регистрация store
  getIt.registerSingleton<Store<AppState>>(createStore());

  // Регистрация API
  await initTodoApi();
  getIt.registerSingleton<AuthApi>(AuthApiImpl());
  getIt.registerSingleton<UserApi>(UserApiImpl());
  getIt.registerSingleton<CategoryApi>(CategoryApiImpl());
  getIt.registerSingleton<TaskApi>(TaskApiImpl());

  // Регистрация FetchSlice
  getIt.registerSingleton<FetchSlice>(FetchSlice());

  // Регистрация TaskSlice
  getIt.registerSingleton<TaskSlice>(TaskSlice());

  // Регистрация CategorySlice
  getIt.registerSingleton<CategorySlice>(CategorySlice());
}

/// Очистка всех зависимостей (для тестов)
Future<void> resetDependencies() async {
  await getIt.reset();
}
