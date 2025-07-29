import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:todo_api/todo_api.dart';
import 'package:todo_models/todo_models.dart';
import '../../fetch_slice/fetch_slice.dart';
import '../actions/task_actions.dart';

/// Thunk actions для асинхронных операций с задачами
class TaskThunks {
  final TaskApi taskApi = getIt.get<TaskApi>();
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();

  // Query для различных операций
  final Query<String> tasksQuery = Query(
    state: QueryState<String>(baseUrl: '/tasks'),
  );
  final Query<String> taskQuery = Query(
    state: QueryState<String>(baseUrl: '/tasks/'),
  );
  final Query<TaskModel> createTaskQuery = Query(
    state: QueryState<TaskModel>(
      baseUrl: '/tasks',
      method: 'POST',
      data: TaskModel.createEmpty(),
    ),
  );
  final Query<TaskModel> updateTaskQuery = Query(
    state: QueryState<TaskModel>(
      baseUrl: '/tasks/',
      method: 'UPDATE',
      data: TaskModel.createEmpty(),
    ),
  );
  final Query<String> deleteTaskQuery = Query(
    state: QueryState<String>(baseUrl: '/tasks'),
  );

  /// Получение списка задач
  ThunkAction<AppState> fetchTasks() {
    return (Store<AppState> store) async {
      Future<void> operation() async {
        final tasks = await taskApi.fetchList(tasksQuery);
        store.dispatch(SetTasksAction(tasks));
      }

      await fetchSlice.thunks.request(
        store,
        key: tasksQuery.state.key,
        operation: operation,
      );
    };
  }

  /// Получение задачи по ID
  ThunkAction<AppState> fetchTask(String taskId) {
    return (Store<AppState> store) async {
      // URL [GET] http://localhost:3000/tasks/1
      final query = taskQuery.copyWith(
        taskQuery.state.copyWith(urlParam: taskId),
      );

      Future<void> operation() async {
        final task = await taskApi.fetchItem(query);
        store.dispatch(AddTaskAction(task));
      }

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: operation,
      );
    };
  }

  /// Создание новой задачи
  ThunkAction<AppState> createTask(TaskModel task) {
    return (Store<AppState> store) async {
      // URL [POST] http://localhost:3000/tasks
      final query = createTaskQuery.copyWith(
        createTaskQuery.state.copyWith(data: task),
      );

      Future<void> operation() async {
        final createdTask = await taskApi.create(query);
        store.dispatch(AddTaskAction(createdTask));
      }

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: operation,
      );
    };
  }

  /// Обновление задачи
  ThunkAction<AppState> updateTask(TaskModel task) {
    return (Store<AppState> store) async {
      // URL [PUT] http://localhost:3000/tasks/1
      final query = updateTaskQuery.copyWith(
        updateTaskQuery.state.copyWith(data: task, urlParam: task.id),
      );

      Future<void> operation() async {
        final updatedTask = await taskApi.update(query);
        store.dispatch(UpdateTaskAction(updatedTask));
      }

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: operation,
      );
    };
  }

  /// Удаление задачи
  ThunkAction<AppState> deleteTask(String taskId) {
    return (Store<AppState> store) async {
      // URL [DELETE] http://localhost:3000/tasks?id=1
      final query = deleteTaskQuery.copyWith(
        deleteTaskQuery.state.copyWith(params: {'id': taskId}),
      );

      Future<void> operation() async {
        await taskApi.delete(query);
        store.dispatch(RemoveTaskAction(taskId));
      }

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: operation,
      );
    };
  }
}
