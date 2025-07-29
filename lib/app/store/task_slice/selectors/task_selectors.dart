import 'package:todo_models/todo_models.dart';
import '../state/task_state.dart';

/// Селекторы для удобного доступа к данным задач
extension TaskSelectors on TaskState {
  /// Получить задачу по ID
  TaskModel? getTaskById(String taskId) => tasks[taskId];

  /// Получить все задачи как список
  List<TaskModel> get tasksList => tasks.values.toList();

  /// Получить задачи по категории
  List<TaskModel> getTasksByCategory(String categoryId) {
    return tasks.values.where((task) => task.categoryId == categoryId).toList();
  }

  /// Проверить, есть ли задачи
  bool get hasTasks => tasks.isNotEmpty;

  /// Получить количество задач
  int get tasksCount => tasks.length;

  /// Получить количество задач в категории
  int getTasksCountByCategory(String categoryId) {
    return tasks.values.where((task) => task.categoryId == categoryId).length;
  }
}
