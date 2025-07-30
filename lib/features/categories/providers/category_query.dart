import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

/// Query factory for category operations
class CategoryQuery {
  /// Query for fetching all categories
  static Query<String> categories(String userId) {
    // URL [GET] http://localhost:3000/categories/$userId
    return Query<String>(
      state: QueryState(
        baseUrl: '/categories',
        method: 'GET',
        urlParam: userId,
      ),
    );
  }

  /// Query for fetching a specific category by ID
  static Query<String> category(String id) {
    // URL [GET] http://localhost:3000/categories/$id
    return Query<String>(
      state: QueryState(baseUrl: '/categories/$id', method: 'GET'),
    );
  }

  /// Query for creating a new category
  static Query<CategoryModel> creationCategory(CategoryModel category) {
    // URL [POST] http://localhost:3000/categories
    return Query<CategoryModel>(
      state: QueryState(
        baseUrl: '/categories',
        method: 'POST',
        data: category,
        id: category.id,
      ),
    );
  }

  /// Query for updating an existing category
  static Query<CategoryModel> updationCategory(CategoryModel category) {
    // URL [PUT] http://localhost:3000/categories/$id
    return Query<CategoryModel>(
      state: QueryState(
        baseUrl: '/categories/',
        method: 'PUT',
        data: category,
        urlParam: category.id,
      ),
    );
  }

  /// Query for deleting a category
  static Query<String> deletionCategory(String id) {
    // URL [DELETE] http://localhost:3000/categories?id=$id
    return Query<String>(
      state: QueryState(
        baseUrl: '/categories',
        method: 'DELETE',
        params: {'id': id},
      ),
    );
  }
}
