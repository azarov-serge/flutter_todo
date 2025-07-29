import 'package:flutter/material.dart';
import 'package:todo_models/todo_models.dart';

import '../pages/pages.dart';

/// Класс для управления роутами приложения
class AppRoutes {
  // Основные роуты
  static const String home = '/';
  static const String categories = '/';
  static const String categoryCreate = '/create';
  static const String categoryEdit = '/edit';
  static const String tasks = '/tasks';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/edit';

  /// Генератор роутов
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const CategoriesPage(),
          settings: settings,
        );

      case categoryCreate:
        return MaterialPageRoute(
          builder: (_) => const CategoryEditor(),
          settings: settings,
        );

      case categoryEdit:
        final category = settings.arguments as CategoryModel;
        return MaterialPageRoute(
          builder: (_) => CategoryEditor(category: category),
          settings: settings,
        );

      case tasks:
        final categoryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TasksPage(categoryId: categoryId),
          settings: settings,
        );

      case taskCreate:
        return MaterialPageRoute(
          builder: (_) => const TaskEditor(),
          settings: settings,
        );

      case taskEdit:
        final task = settings.arguments as TaskModel;
        return MaterialPageRoute(
          builder: (_) => TaskEditor(task: task),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const CategoriesPage(),
          settings: settings,
        );
    }
  }

  /// Навигация к домашней странице (категории)
  static void goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(home, (route) => false);
  }

  /// Навигация к списку категорий
  static void goToCategories(BuildContext context) {
    Navigator.of(context).pushNamed(categories);
  }

  /// Навигация к созданию категории
  static void goToCreateCategory(BuildContext context) {
    Navigator.of(context).pushNamed(categoryCreate);
  }

  /// Навигация к редактированию категории
  static void goToEditCategory(BuildContext context, CategoryModel category) {
    Navigator.of(context).pushNamed(categoryEdit, arguments: category);
  }

  /// Навигация к списку задач
  static void goToTasks(BuildContext context, {String? categoryId}) {
    Navigator.of(context).pushNamed(tasks, arguments: categoryId);
  }

  /// Навигация к созданию задачи
  static void goToCreateTask(BuildContext context) {
    Navigator.of(context).pushNamed(taskCreate);
  }

  /// Навигация к редактированию задачи
  static void goToEditTask(BuildContext context, TaskModel task) {
    Navigator.of(context).pushNamed(taskEdit, arguments: task);
  }

  /// Навигация назад
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Навигация назад с результатом
  static void goBackWithResult(BuildContext context, dynamic result) {
    Navigator.of(context).pop(result);
  }
}
