import 'package:flutter/material.dart';
import 'verifier.dart';

/// Пример использования Verifier виджета
class VerifierExample extends StatelessWidget {
  const VerifierExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verifier Example',
      home: Verifier(
        child: Scaffold(
          appBar: AppBar(title: const Text('Protected Page')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Welcome to the protected area!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'You are authenticated and can access this content.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Пример использования Verifier в существующем приложении
class AppWithVerifier extends StatelessWidget {
  const AppWithVerifier({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App with Verifier',
      home: Verifier(child: const HomePage()),
    );
  }
}

/// Пример защищенной домашней страницы
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Здесь можно добавить логику выхода
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: const Center(child: Text('This is a protected home page')),
    );
  }
}
