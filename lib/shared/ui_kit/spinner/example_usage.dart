import 'package:flutter/material.dart';
import 'spinner.dart';

/// Пример использования спиннеров
class SpinnerExample extends StatelessWidget {
  const SpinnerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spinner Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Различные варианты спиннеров',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Базовые спиннеры
            _buildSection('Базовые спиннеры', [
              const Spinner(),
              const SizedBox(width: 20),
              const Spinner(size: 30),
              const SizedBox(width: 20),
              const Spinner(size: 40, color: Colors.red),
              const SizedBox(width: 20),
              const Spinner(size: 50, color: Colors.blue, strokeWidth: 4),
            ]),

            const SizedBox(height: 32),

            // Спиннеры с текстом
            _buildSection('Спиннеры с текстом', [
              const SpinnerWithText(text: 'Загрузка...'),
              const SizedBox(height: 20),
              const SpinnerWithText(
                text: 'Сохранение данных',
                spinnerSize: 20,
                spinnerColor: Colors.green,
              ),
              const SizedBox(height: 20),
              const SpinnerWithText(
                text: 'Обновление',
                direction: Axis.vertical,
                spacing: 8,
              ),
            ]),

            const SizedBox(height: 32),

            // Спиннеры с кастомными виджетами
            _buildSection('Спиннеры с кастомными виджетами', [
              SpinnerWithWidget(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Кастомный виджет',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SpinnerWithWidget(
                direction: Axis.vertical,
                spacing: 8,
                child: Column(
                  children: [
                    const Icon(Icons.download, color: Colors.blue),
                    const Text('Загрузка файла'),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // Спиннеры в кнопках
            _buildSection('Спиннеры в кнопках', [
              ElevatedButton.icon(
                onPressed: null,
                icon: const Spinner(size: 16, color: Colors.white),
                label: const Text('Загрузка'),
              ),
              const SizedBox(width: 20),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Spinner(size: 16),
                label: const Text('Обработка'),
              ),
            ]),

            const SizedBox(height: 32),

            // Спиннеры в карточках
            _buildSection('Спиннеры в карточках', [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const SpinnerWithText(
                    text: 'Загрузка данных...',
                    spinnerSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Spinner(size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Загрузка профиля',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Пожалуйста, подождите...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        Wrap(spacing: 16, runSpacing: 16, children: children),
      ],
    );
  }
}

/// Пример использования спиннера в реальном приложении
class SpinnerInAppExample extends StatefulWidget {
  const SpinnerInAppExample({super.key});

  @override
  State<SpinnerInAppExample> createState() => _SpinnerInAppExampleState();
}

class _SpinnerInAppExampleState extends State<SpinnerInAppExample> {
  bool _isLoading = false;
  String _status = '';

  void _simulateLoading() async {
    setState(() {
      _isLoading = true;
      _status = 'Начинаем загрузку...';
    });

    // Симуляция загрузки
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Загружаем данные...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Обрабатываем информацию...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _status = 'Завершаем...';
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _status = 'Загрузка завершена!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Спиннер в приложении')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const Spinner(size: 40),
              const SizedBox(height: 16),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _simulateLoading,
              child: const Text('Начать загрузку'),
            ),
          ],
        ),
      ),
    );
  }
}
