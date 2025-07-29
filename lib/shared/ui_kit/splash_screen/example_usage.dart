import 'package:flutter/material.dart';
import 'splash_screen.dart';

/// Пример использования splash screen
class SplashScreenExample extends StatefulWidget {
  const SplashScreenExample({super.key});

  @override
  State<SplashScreenExample> createState() => _SplashScreenExampleState();
}

class _SplashScreenExampleState extends State<SplashScreenExample> {
  bool _showSplash = false;
  bool _showAnimatedSplash = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(message: _message);
    }

    if (_showAnimatedSplash) {
      return AnimatedSplashScreen(message: _message);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Splash Screen Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Различные варианты splash screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Базовые splash screen
            _buildSection('Базовые splash screen', [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSplash = true;
                    _message = null;
                  });
                },
                child: const Text('Показать базовый splash'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSplash = true;
                    _message = 'Загрузка приложения...';
                  });
                },
                child: const Text('Splash с сообщением'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSplash = true;
                    _message = 'Инициализация данных...';
                  });
                },
                child: const Text('Splash с инициализацией'),
              ),
            ]),

            const SizedBox(height: 32),

            // Анимированные splash screen
            _buildSection('Анимированные splash screen', [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnimatedSplash = true;
                    _message = null;
                  });
                },
                child: const Text('Показать анимированный splash'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnimatedSplash = true;
                    _message = 'Загрузка приложения...';
                  });
                },
                child: const Text('Анимированный splash с сообщением'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnimatedSplash = true;
                    _message = 'Инициализация данных...';
                  });
                },
                child: const Text('Анимированный splash с инициализацией'),
              ),
            ]),

            const SizedBox(height: 32),

            // Кастомные splash screen
            _buildSection('Кастомные splash screen', [
              _buildCustomSplashExample(),
              const SizedBox(height: 16),
              _buildThemedSplashExample(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildCustomSplashExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Кастомный splash screen',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'С кастомными цветами и стилями',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomSplashScreen(),
                  ),
                );
              },
              child: const Text('Показать кастомный splash'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedSplashExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Темный splash screen',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'С темной темой и светлыми элементами',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DarkSplashScreen(),
                  ),
                );
              },
              child: const Text('Показать темный splash'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Кастомный splash screen с нестандартными стилями
class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      message: 'Загрузка с кастомными стилями...',
      spinnerSize: 32,
      spinnerColor: Colors.purple,
      logoTextStyle: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: Colors.purple,
        letterSpacing: 4.0,
        shadows: [
          Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26),
        ],
      ),
      messageTextStyle: const TextStyle(
        fontSize: 18,
        color: Colors.purple,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.purple[50],
      logoSpinnerSpacing: 64,
      spinnerMessageSpacing: 20,
    );
  }
}

/// Темный splash screen
class DarkSplashScreen extends StatelessWidget {
  const DarkSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      message: 'Загрузка в темной теме...',
      spinnerSize: 28,
      spinnerColor: Colors.white,
      logoTextStyle: const TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 3.0,
      ),
      messageTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
      backgroundColor: Colors.black87,
      logoSpinnerSpacing: 56,
      spinnerMessageSpacing: 16,
    );
  }
}

/// Пример использования splash screen в реальном приложении
class SplashScreenInAppExample extends StatefulWidget {
  const SplashScreenInAppExample({super.key});

  @override
  State<SplashScreenInAppExample> createState() =>
      _SplashScreenInAppExampleState();
}

class _SplashScreenInAppExampleState extends State<SplashScreenInAppExample> {
  bool _isLoading = true;
  String _status = 'Инициализация приложения...';

  @override
  void initState() {
    super.initState();
    _simulateAppInitialization();
  }

  void _simulateAppInitialization() async {
    // Симуляция инициализации приложения
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Загрузка конфигурации...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Подключение к серверу...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Загрузка данных...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AnimatedSplashScreen(
        message: _status,
        spinnerSize: 28,
        spinnerColor: Theme.of(context).primaryColor,
        logoTextStyle: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 2.0,
        ),
        messageTextStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        animationDuration: const Duration(milliseconds: 1000),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Главное приложение')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Приложение загружено!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Добро пожаловать в TODO приложение',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
