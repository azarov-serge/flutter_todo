import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

abstract class TaskApi {
  /// TODO: PaginationQuery
  Future<List<TaskModel>> fetchList(Query<String> query);
  Future<TaskModel> fetchItem(Query<String> query);
  Future<TaskModel> create(Query<TaskModel> query);
  Future<TaskModel> update(Query<TaskModel> query);
  Future<void> delete(Query<String> query);
}
