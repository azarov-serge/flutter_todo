import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

/// Виджет спиннера, который показывает индикатор загрузки
/// в зависимости от платформы (Material для Android, Cupertino для iOS)
class Spinner extends StatelessWidget {
  /// Размер спиннера
  final double? size;

  /// Цвет спиннера
  final Color? color;

  /// Толщина линии для Material спиннера
  final double strokeWidth;

  const Spinner({super.key, this.size, this.color, this.strokeWidth = 2.0});

  @override
  Widget build(BuildContext context) {
    // Определяем платформу
    final isIOS = Platform.isIOS;

    if (isIOS) {
      // Cupertino спиннер для iOS
      return CupertinoActivityIndicator(radius: (size ?? 20) / 2, color: color);
    } else {
      // Material спиннер для Android и других платформ
      return SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    }
  }
}

/// Виджет спиннера с текстом
class SpinnerWithText extends StatelessWidget {
  /// Текст рядом со спиннером
  final String text;

  /// Размер спиннера
  final double? spinnerSize;

  /// Цвет спиннера
  final Color? spinnerColor;

  /// Стиль текста
  final TextStyle? textStyle;

  /// Расстояние между спиннером и текстом
  final double spacing;

  /// Направление расположения элементов
  final Axis direction;

  const SpinnerWithText({
    super.key,
    required this.text,
    this.spinnerSize,
    this.spinnerColor,
    this.textStyle,
    this.spacing = 12.0,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontSize: 16,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );

    final children = [
      Spinner(size: spinnerSize, color: spinnerColor),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      Text(text, style: textStyle ?? defaultTextStyle),
    ];

    if (direction == Axis.vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    } else {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }
  }
}

/// Виджет спиннера с кастомным виджетом
class SpinnerWithWidget extends StatelessWidget {
  /// Виджет рядом со спиннером
  final Widget child;

  /// Размер спиннера
  final double? spinnerSize;

  /// Цвет спиннера
  final Color? spinnerColor;

  /// Расстояние между спиннером и виджетом
  final double spacing;

  /// Направление расположения элементов
  final Axis direction;

  const SpinnerWithWidget({
    super.key,
    required this.child,
    this.spinnerSize,
    this.spinnerColor,
    this.spacing = 12.0,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      Spinner(size: spinnerSize, color: spinnerColor),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      child,
    ];

    if (direction == Axis.vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    } else {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }
  }
}
