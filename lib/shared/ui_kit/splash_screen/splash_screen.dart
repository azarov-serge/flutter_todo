import 'package:flutter/material.dart';
import '../spinner/spinner.dart';

/// Виджет splash screen с логотипом и спиннером
class SplashScreen extends StatelessWidget {
  /// Сообщение для отображения рядом со спиннером
  final String? message;

  /// Размер спиннера
  final double spinnerSize;

  /// Цвет спиннера
  final Color? spinnerColor;

  /// Стиль текста логотипа
  final TextStyle? logoTextStyle;

  /// Стиль текста сообщения
  final TextStyle? messageTextStyle;

  /// Цвет фона
  final Color? backgroundColor;

  /// Расстояние между логотипом и спиннером
  final double logoSpinnerSpacing;

  /// Расстояние между спиннером и сообщением
  final double spinnerMessageSpacing;

  const SplashScreen({
    super.key,
    this.message,
    this.spinnerSize = 24.0,
    this.spinnerColor,
    this.logoTextStyle,
    this.messageTextStyle,
    this.backgroundColor,
    this.logoSpinnerSpacing = 48.0,
    this.spinnerMessageSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Стиль для логотипа
    final defaultLogoStyle = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: theme.primaryColor,
      letterSpacing: 2.0,
    );

    // Стиль для сообщения
    final defaultMessageStyle = TextStyle(
      fontSize: 16,
      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип TODO
              Text('TODO', style: logoTextStyle ?? defaultLogoStyle),

              SizedBox(height: logoSpinnerSpacing),

              // Спиннер с сообщением или без
              if (message != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spinner(size: spinnerSize, color: spinnerColor),
                    SizedBox(width: spinnerMessageSpacing),
                    Text(
                      message!,
                      style: messageTextStyle ?? defaultMessageStyle,
                    ),
                  ],
                ),
              ] else ...[
                Spinner(size: spinnerSize, color: spinnerColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет splash screen с анимацией появления
class AnimatedSplashScreen extends StatefulWidget {
  /// Сообщение для отображения рядом со спиннером
  final String? message;

  /// Размер спиннера
  final double spinnerSize;

  /// Цвет спиннера
  final Color? spinnerColor;

  /// Стиль текста логотипа
  final TextStyle? logoTextStyle;

  /// Стиль текста сообщения
  final TextStyle? messageTextStyle;

  /// Цвет фона
  final Color? backgroundColor;

  /// Расстояние между логотипом и спиннером
  final double logoSpinnerSpacing;

  /// Расстояние между спиннером и сообщением
  final double spinnerMessageSpacing;

  /// Длительность анимации появления
  final Duration animationDuration;

  const AnimatedSplashScreen({
    super.key,
    this.message,
    this.spinnerSize = 24.0,
    this.spinnerColor,
    this.logoTextStyle,
    this.messageTextStyle,
    this.backgroundColor,
    this.logoSpinnerSpacing = 48.0,
    this.spinnerMessageSpacing = 16.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Запускаем анимацию
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Стиль для логотипа
    final defaultLogoStyle = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: theme.primaryColor,
      letterSpacing: 2.0,
    );

    // Стиль для сообщения
    final defaultMessageStyle = TextStyle(
      fontSize: 16,
      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
    );

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип TODO
                Text('TODO', style: widget.logoTextStyle ?? defaultLogoStyle),

                SizedBox(height: widget.logoSpinnerSpacing),

                // Спиннер с сообщением или без
                if (widget.message != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spinner(
                        size: widget.spinnerSize,
                        color: widget.spinnerColor,
                      ),
                      SizedBox(width: widget.spinnerMessageSpacing),
                      Text(
                        widget.message!,
                        style: widget.messageTextStyle ?? defaultMessageStyle,
                      ),
                    ],
                  ),
                ] else ...[
                  Spinner(size: widget.spinnerSize, color: widget.spinnerColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
