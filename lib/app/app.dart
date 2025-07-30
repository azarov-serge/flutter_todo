import 'package:flutter/material.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'routes.dart';
import '../pages/pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем глобальный ключ навигации
    final navigatorKey = getIt.get<GlobalKey<NavigatorState>>();

    return MaterialApp(
      title: 'Todo App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
      },
    );
  }
}
