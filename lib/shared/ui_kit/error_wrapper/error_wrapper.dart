import 'package:flutter/material.dart';

/// Widget for displaying errors in a dialog
class ErrorWrapper extends StatefulWidget {
  /// Error text
  final String? error;

  /// Callback when close button is pressed
  final VoidCallback? onClosePressed;

  /// Child widget
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
  Widget build(BuildContext context) {
    // Show dialog if error appears
    if (widget.error != null && widget.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
    }

    return widget.child;
  }

  /// Show error dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(widget.error!),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClosePressed?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
