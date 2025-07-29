import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'package:todo_api/src/hive_client/hive_client.dart';
import 'package:todo_api/src/hive_client/hive_models/task_hive_model.dart';

class TaskApiImpl implements TaskApi {
  final HiveClient _hiveClient = hiveClient;
  @override
  Future<List<TaskModel>> fetchList(Query<String> query) async {
    final categoryId = query.state.data;

    if (categoryId == null) {
      throw Exception('Category ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 1900));

    final List<TaskModel> tasks = [];
    if (_hiveClient.tasksBox.length == 0) {
      return tasks;
    }

    final values = _hiveClient.tasksBox.values.toList();

    for (var value in values) {
      if (value.categoryId == categoryId) {
        tasks.add(TaskModel.fromJson(value.toJson()));
      }
    }

    if (tasks.isNotEmpty) {
      tasks.sort((a, b) {
        int aMicroseconds = a.createdAt.microsecondsSinceEpoch;
        int bMicroseconds = b.createdAt.microsecondsSinceEpoch;

        return aMicroseconds.compareTo(bMicroseconds);
      });
    }

    return tasks;
  }

  @override
  Future<TaskModel> fetchItem(Query<String> query) async {
    final taskId = query.state.data;

    if (taskId == null) {
      throw Exception('Task ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final task = _hiveClient.tasksBox.get(taskId);

    if (task == null) {
      throw Exception('Task not found');
    }

    return TaskModel.fromJson(task.toJson());
  }

  @override
  Future<TaskModel> create(Query<TaskModel> query) async {
    final task = query.state.data;

    if (task == null) {
      throw Exception('Task is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final newTask = TaskHiveModel(name: task.name, categoryId: task.categoryId);

    _hiveClient.tasksBox.put(newTask.id, newTask);

    return TaskModel.fromJson(newTask.toJson());
  }

  @override
  Future<TaskModel> update(Query<TaskModel> query) async {
    final task = query.state.data;

    if (task == null) {
      throw Exception('Task is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final currentTask = _hiveClient.tasksBox.get(task.id);

    if (currentTask == null) {
      throw Exception('Task not found');
    }

    final updatedTask = TaskHiveModel(
      id: task.id,
      createdAt: task.createdAt,
      name: task.name,
      categoryId: currentTask.categoryId,
    );

    _hiveClient.tasksBox.put(updatedTask.id, updatedTask);

    return TaskModel.fromJson(updatedTask.toJson());
  }

  @override
  Future<void> delete(Query<String> query) async {
    final taskId = query.state.params['id'];

    if (taskId == null) {
      throw Exception('Task ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    _hiveClient.tasksBox.delete(taskId);
  }
}
