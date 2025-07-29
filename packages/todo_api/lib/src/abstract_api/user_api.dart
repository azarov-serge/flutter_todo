import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

abstract class UserApi {
  Future<UserModel> fetchItem(Query<String> query);
}
