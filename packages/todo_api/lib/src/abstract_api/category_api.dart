import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

abstract class CategoryApi {
  /// TODO: PaginationQuery
  Future<List<CategoryModel>> fetchList(Query<String> query);
  Future<CategoryModel> fetchItem(Query<String> query);
  Future<CategoryModel> create(Query<CategoryModel> query);
  Future<CategoryModel> update(Query<CategoryModel> query);
  Future<void> delete(Query<String> query);
}
