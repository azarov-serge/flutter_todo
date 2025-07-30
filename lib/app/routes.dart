import 'package:flutter/material.dart';
import 'package:todo_models/todo_models.dart';

import '../features/shared/home/home_page.dart';
import '../features/categories/views/category_editor_page/category_editor_page.dart';
import '../features/tasks/views/tasks_page/tasks_page.dart';
import '../features/tasks/views/task_editor/task_editor.dart';
import '../features/auth/views/auth_page/auth_page.dart';

/// Application routes management class
class AppRoutes {
  // Main routes
  static const String home = '/';
  static const String categories = '/';
  static const String categoryCreate = '/create';
  static const String categoryEdit = '/edit';
  static const String tasks = '/tasks';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/edit';
  static const String auth = '/auth';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case categoryCreate:
        return MaterialPageRoute(
          builder: (_) => const CategoryEditorPage(categoryId: ''),
          settings: settings,
        );

      case categoryEdit:
        final categoryId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CategoryEditorPage(categoryId: categoryId),
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
          builder: (_) => const TaskEditor(taskId: ''),
          settings: settings,
        );

      case taskEdit:
        final taskId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TaskEditor(taskId: taskId),
          settings: settings,
        );

      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }

  /// Navigate to home page (categories)
  static void goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(home, (route) => false);
  }

  /// Navigate to categories list
  static void goToCategories(BuildContext context) {
    Navigator.of(context).pushNamed(categories);
  }

  /// Navigate to create category
  static void goToCreateCategory(BuildContext context) {
    Navigator.of(context).pushNamed(categoryCreate);
  }

  /// Navigate to edit category
  static void goToEditCategory(BuildContext context, String categoryId) {
    Navigator.of(context).pushNamed(categoryEdit, arguments: categoryId);
  }

  /// Navigate to tasks list
  static void goToTasks(BuildContext context, {String? categoryId}) {
    Navigator.of(context).pushNamed(tasks, arguments: categoryId);
  }

  /// Navigate to create task
  static void goToCreateTask(BuildContext context) {
    Navigator.of(context).pushNamed(taskCreate);
  }

  /// Navigate to edit task
  static void goToEditTask(BuildContext context, TaskModel task) {
    Navigator.of(context).pushNamed(taskEdit, arguments: task.id);
  }

  /// Navigate to auth page
  static void goToAuth(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(auth, (route) => false);
  }

  /// Navigate back
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navigate back with result
  static void goBackWithResult(BuildContext context, dynamic result) {
    Navigator.of(context).pop(result);
  }
}
