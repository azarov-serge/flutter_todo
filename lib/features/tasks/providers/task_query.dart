import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

/// Query factory for task operations
class TaskQuery {
  /// Query for fetching all tasks
  static Query<String> tasks(String categoryId) {
    return Query<String>(
      state: QueryState(baseUrl: '/tasks', method: 'GET', urlParam: categoryId),
    );
  }

  /// Query for fetching a specific task by ID
  static Query<String> task(String id) {
    return Query<String>(
      state: QueryState(baseUrl: '/tasks', method: 'GET', urlParam: id),
    );
  }

  /// Query for creating a new task
  static Query<TaskModel> creationTask(TaskModel task) {
    return Query<TaskModel>(
      state: QueryState(
        baseUrl: '/tasks',
        method: 'POST',
        data: task,
        id: task.id,
      ),
    );
  }

  /// Query for updating an existing task
  static Query<TaskModel> updationTask(TaskModel task) {
    return Query<TaskModel>(
      state: QueryState(
        baseUrl: '/tasks',
        method: 'PUT',
        data: task,
        urlParam: task.id,
      ),
    );
  }

  /// Query for deleting a task
  static Query<String> deletionTask(String id) {
    return Query<String>(
      state: QueryState(
        baseUrl: '/tasks',
        method: 'DELETE',
        params: {'id': id},
      ),
    );
  }
}
