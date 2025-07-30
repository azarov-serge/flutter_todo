import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../shared/shared.dart';
import '../features/features.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Get global navigation key
    final navigatorKey = getIt.get<GlobalKey<NavigatorState>>();

    return Consumer(
      builder: (context, ref, child) {
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
              builder: (_) => const HomePage(),
              settings: settings,
            );
          },
        );
      },
    );
  }
}
