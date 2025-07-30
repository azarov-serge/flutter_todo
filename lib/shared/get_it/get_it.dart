import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_api/todo_api.dart';
import 'package:auth_strategy_manager/auth_strategy_manager.dart';

import '../../app/routes.dart';

/// Global GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencies() async {
  // Register global navigation key
  getIt.registerSingleton<GlobalKey<NavigatorState>>(
    GlobalKey<NavigatorState>(),
  );

  // Register APIs
  await initTodoApi();
  getIt.registerSingleton<AuthApi>(AuthApiImpl());
  getIt.registerSingleton<CategoryApi>(CategoryApiImpl());
  getIt.registerSingleton<TaskApi>(TaskApiImpl());
  getIt.registerSingleton<UserApi>(UserApiImpl());

  // Register authentication strategy
  final authApi = getIt.get<AuthApi>();
  final strategy = PersistStrategy(signInUrl: AppRoutes.auth, authApi: authApi);

  // Register AuthStrategyManager
  getIt.registerSingleton<AuthStrategyManager>(AuthStrategyManager([strategy]));
}

/// Clear all dependencies (for testing)
Future<void> clearDependencies() async {
  await getIt.reset();
}
