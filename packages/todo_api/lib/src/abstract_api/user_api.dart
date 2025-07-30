import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

abstract class UserApi {
  Future<List<UserModel>> fetchList(Query<Null> query);
  Future<UserModel> fetchItem(Query<String> query);
  Future<UserModel> create(Query<UserModel> query);
  Future<UserModel> update(Query<UserModel> query);
  Future<void> delete(Query<String> query);
}
