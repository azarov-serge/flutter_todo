import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_models/todo_models.dart';
import 'package:todo_api/todo_api.dart';

import 'task_state.dart';
import 'task_query.dart';
import '../../../shared/providers/request_provider.dart';

/// Notifier for managing task state
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskApi _taskApi;
  final RequestNotifier _requestNotifier;

  TaskNotifier(this._taskApi, this._requestNotifier)
    : super(TaskState.initial());

  /// Fetch all tasks
  Future<void> fetchTasks(String categoryId) async {
    final query = TaskQuery.tasks(categoryId);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Fetch tasks
      final tasks = await _taskApi.fetchList(query);

      // Update state on success
      state = state.copyWith(tasks: tasks, categoryId: categoryId);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      // Update state on error
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Create new task
  Future<void> createTask(TaskModel task) async {
    final query = TaskQuery.creationTask(task);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Create task
      final createdTask = await _taskApi.create(query);

      // Update state on success
      state = state.copyWith(tasks: [...state.tasks, createdTask]);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Update task
  Future<void> updateTask(TaskModel task) async {
    final query = TaskQuery.updationTask(task);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Update task
      final updatedTask = await _taskApi.update(query);

      // Update state on success
      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? updatedTask : t;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        selectedTaskId: state.selectedTaskId,
      );

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    final query = TaskQuery.deletionTask(taskId);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Delete task
      await _taskApi.delete(TaskQuery.deletionTask(taskId));

      // Update state on success
      final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
      state = state.copyWith(
        tasks: updatedTasks,
        selectedTaskId: state.selectedTaskId == taskId
            ? null
            : state.selectedTaskId,
      );

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Select task
  void selectTask(TaskModel? task) {
    state = state.copyWith(selectedTaskId: task?.id);
  }

  /// Reset state
  void reset() {
    state = TaskState.initial();
  }

  /// Update category ID
  void updateCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }
}

/// Provider for task notifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((
  ref,
) {
  final taskApi = GetIt.instance.get<TaskApi>();
  final requestNotifier = ref.watch(requestNotifierProvider.notifier);
  return TaskNotifier(taskApi, requestNotifier);
});

/// Provider for tasks list
final tasksProvider = Provider<List<TaskModel>>(
  (ref) => ref.watch(taskNotifierProvider).tasks,
);

/// Provider for selected task
final selectedTaskProvider = Provider<TaskModel?>(
  (ref) => ref.watch(taskNotifierProvider).selectedTask,
);
