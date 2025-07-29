import 'package:todo_models/todo_models.dart';

/// Базовый класс для действий с задачами
abstract class TaskAction {
  const TaskAction();
}

/// Установка списка задач
class SetTasksAction extends TaskAction {
  final List<TaskModel> tasks;

  const SetTasksAction(this.tasks);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetTasksAction && other.tasks == tasks;
  }

  @override
  int get hashCode => tasks.hashCode;

  @override
  String toString() => 'SetTasksAction(tasks: $tasks)';
}

/// Добавление задачи
class AddTaskAction extends TaskAction {
  final TaskModel task;

  const AddTaskAction(this.task);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddTaskAction && other.task == task;
  }

  @override
  int get hashCode => task.hashCode;

  @override
  String toString() => 'AddTaskAction(task: $task)';
}

/// Обновление задачи
class UpdateTaskAction extends TaskAction {
  final TaskModel task;

  const UpdateTaskAction(this.task);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateTaskAction && other.task == task;
  }

  @override
  int get hashCode => task.hashCode;

  @override
  String toString() => 'UpdateTaskAction(task: $task)';
}

/// Удаление задачи
class RemoveTaskAction extends TaskAction {
  final String taskId;

  const RemoveTaskAction(this.taskId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoveTaskAction && other.taskId == taskId;
  }

  @override
  int get hashCode => taskId.hashCode;

  @override
  String toString() => 'RemoveTaskAction(taskId: $taskId)';
}

/// Очистка задач
class ClearTasksAction extends TaskAction {
  const ClearTasksAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearTasksAction;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'ClearTasksAction()';
}
