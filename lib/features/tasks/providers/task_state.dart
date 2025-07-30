import 'package:todo_models/todo_models.dart';

/// State for tasks feature
/// Loading and error states are managed by RequestNotifier
class TaskState {
  final List<TaskModel> tasks;
  final String? selectedTaskId;
  final String? categoryId;

  const TaskState({
    this.tasks = const [],
    this.selectedTaskId,
    this.categoryId,
  });

  /// Initial state
  factory TaskState.initial() => const TaskState();

  /// Copy with changes
  TaskState copyWith({
    List<TaskModel>? tasks,
    String? selectedTaskId,
    String? categoryId,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  /// Get selected task by ID
  TaskModel? get selectedTask {
    if (selectedTaskId == null) return null;
    try {
      return tasks.firstWhere((t) => t.id == selectedTaskId);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'TaskState(tasks: ${tasks.length}, selectedTaskId: $selectedTaskId, categoryId: $categoryId)';
  }
}
