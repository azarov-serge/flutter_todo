import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:todo_models/todo_models.dart';

import 'state/task_state.dart';
import 'actions/task_actions.dart';
import 'reducer/task_reducer.dart';
import 'thunks/task_thunks.dart';
import '../fetch_slice/fetch_slice.dart';

/// Класс для управления задачами
class TaskSlice {
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();
  // Экземпляр TaskThunks
  final TaskThunks thunks = TaskThunks();

  /// Получить статус загрузки задач
  QueryStatus tasksStatus(Store<AppState> store) {
    final fetchState = store.state.fetchState;

    return fetchState.status(thunks.tasksQuery.state.key);
  }

  /// Получить статус загрузки задачи по ID
  QueryStatus taskStatus(Store<AppState> store, String taskId) {
    final fetchState = store.state.fetchState;
    final query = thunks.taskQuery.copyWith(
      thunks.taskQuery.state.copyWith(id: taskId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус создания задачи
  QueryStatus creatingTaskStatus(Store<AppState> store, String taskId) {
    final fetchState = store.state.fetchState;
    final query = thunks.createTaskQuery.copyWith(
      thunks.createTaskQuery.state.copyWith(id: taskId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус обновления задачи
  QueryStatus updatingTaskStatus(Store<AppState> store, String taskId) {
    final fetchState = store.state.fetchState;
    final query = thunks.updateTaskQuery.copyWith(
      thunks.updateTaskQuery.state.copyWith(urlParam: taskId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус удаления задачи
  QueryStatus deletingTaskStatus(Store<AppState> store, String taskId) {
    final fetchState = store.state.fetchState;
    final query = thunks.deleteTaskQuery.copyWith(
      thunks.deleteTaskQuery.state.copyWith(params: {'id': taskId}),
    );
    return fetchState.status(query.state.key);
  }

  /// Сбросить ошибку для задач
  void resetTasksError(Store<AppState> store) {
    fetchSlice.actions.clearError(store, thunks.tasksQuery.state.key);
  }

  /// Сбросить ошибку для задачи по ID
  void resetTaskError(Store<AppState> store, String taskId) {
    final query = thunks.taskQuery.copyWith(
      thunks.taskQuery.state.copyWith(urlParam: taskId),
    );

    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку создания задачи
  void resetCreateTaskError(Store<AppState> store, String taskId) {
    final query = thunks.createTaskQuery.copyWith(
      thunks.createTaskQuery.state.copyWith(id: taskId),
    );

    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку обновления задачи
  void resetUpdateTaskError(Store<AppState> store, String taskId) {
    final query = thunks.updateTaskQuery.copyWith(
      thunks.updateTaskQuery.state.copyWith(urlParam: taskId),
    );

    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку удаления задачи
  void resetDeleteTaskError(Store<AppState> store, String taskId) {
    final query = thunks.deleteTaskQuery.copyWith(
      thunks.deleteTaskQuery.state.copyWith(params: {'id': taskId}),
    );

    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить состояние задач
  void resetTasksState(Store<AppState> store) {
    store.dispatch(ClearTasksAction());
    fetchSlice.actions.resetState(store, thunks.tasksQuery.state.key);
  }

  /// Сбросить состояние задачи по ID
  void resetTaskState(Store<AppState> store, String taskId) {
    store.dispatch(RemoveTaskAction(taskId));
    final query = thunks.taskQuery.copyWith(
      thunks.taskQuery.state.copyWith(urlParam: taskId),
    );

    fetchSlice.actions.resetState(store, query.state.key);
  }

  /// Сбросить состояние создания задачи
  void resetCreateTaskState(Store<AppState> store, String taskId) {
    store.dispatch(RemoveTaskAction(taskId));
    final query = thunks.createTaskQuery.copyWith(
      thunks.createTaskQuery.state.copyWith(id: taskId),
    );

    fetchSlice.actions.resetState(store, query.state.key);
  }

  /// Сбросить состояние обновления задачи
  void resetUpdateTaskState(Store<AppState> store, String taskId) {
    store.dispatch(RemoveTaskAction(taskId));
    final query = thunks.updateTaskQuery.copyWith(
      thunks.updateTaskQuery.state.copyWith(urlParam: taskId),
    );

    fetchSlice.actions.resetState(store, query.state.key);
  }

  /// Сбросить состояние удаления задачи
  void resetDeleteTaskState(Store<AppState> store, String taskId) {
    store.dispatch(RemoveTaskAction(taskId));
    final query = thunks.deleteTaskQuery.copyWith(
      thunks.deleteTaskQuery.state.copyWith(params: {'id': taskId}),
    );

    fetchSlice.actions.resetState(store, query.state.key);
  }

  /// Получить список задач
  List<TaskModel> getTasks(Store<AppState> store) {
    final taskState = store.state.taskState;
    return taskState.tasks.values.toList();
  }

  /// Получить задачу по ID
  TaskModel? getTaskById(Store<AppState> store, String taskId) {
    final taskState = store.state.taskState;
    return taskState.tasks[taskId];
  }

  /// Получить задачи по категории
  static List<TaskModel> getTasksByCategory(
    Store<AppState> store,
    String categoryId,
  ) {
    final taskState = store.state.taskState;
    return taskState.tasks.values
        .where((task) => task.categoryId == categoryId)
        .toList();
  }

  /// Проверить, есть ли задачи
  static bool hasTasks(Store<AppState> store) {
    final taskState = store.state.taskState;
    return taskState.tasks.isNotEmpty;
  }

  /// Получить количество задач
  static int getTasksCount(Store<AppState> store) {
    final taskState = store.state.taskState;
    return taskState.tasks.length;
  }

  /// Получить редюсер
  static Reducer<TaskState> get reducer => taskReducer;

  /// Получить состояние
  static TaskState getState(Store<AppState> store) {
    return store.state.taskState;
  }

  /// Получить начальное состояние
  static TaskState get initialState => TaskState.initial();
}
