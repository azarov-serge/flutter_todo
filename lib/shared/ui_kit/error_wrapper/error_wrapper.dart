import 'package:flutter/material.dart';

/// Виджет для отображения ошибок в диалоге
class ErrorWrapper extends StatefulWidget {
  /// Текст ошибки
  final String? error;

  /// Callback при нажатии на кнопку закрытия
  final VoidCallback? onClosePressed;

  /// Дочерний виджет
  final Widget child;

  const ErrorWrapper({
    super.key,
    this.error,
    this.onClosePressed,
    required this.child,
  });

  @override
  State<ErrorWrapper> createState() => _ErrorWrapperState();
}

class _ErrorWrapperState extends State<ErrorWrapper> {
  @override
  void didUpdateWidget(ErrorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Показываем диалог если появилась ошибка
    if (widget.error != null &&
        widget.error != oldWidget.error &&
        widget.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
    }
  }

  /// Показать диалог с ошибкой
  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Ошибка',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.error!,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onClosePressed?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Закрыть',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
