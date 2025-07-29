import 'package:todo_models/todo_models.dart';

/// Состояние для управления задачами
class TaskState {
  final Map<String, TaskModel> tasks;

  const TaskState({this.tasks = const {}});

  /// Создание копии с изменениями
  TaskState copyWith({Map<String, TaskModel>? tasks}) {
    return TaskState(tasks: tasks ?? this.tasks);
  }

  /// Создание пустого состояния
  factory TaskState.initial() => const TaskState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskState && other.tasks == tasks;
  }

  @override
  int get hashCode => tasks.hashCode;

  @override
  String toString() => 'TaskState(tasks: $tasks)';
}
