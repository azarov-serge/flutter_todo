import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

import 'package:todo_api/src/abstract_api/abstract_api.dart';
import 'package:todo_api/src/hive_client/hive_client.dart';
import 'package:todo_api/src/hive_client/hive_models/category_hive_model.dart';

class CategoryApiImpl implements CategoryApi {
  final HiveClient _hiveClient = hiveClient;
  @override
  Future<List<CategoryModel>> fetchList(Query<String> query) async {
    final userId = query.state.urlParam;

    if (userId.isEmpty) {
      throw Exception('User ID is invalid');
    }

    await Future.delayed(const Duration(milliseconds: 1900));

    final List<CategoryModel> categories = [];
    if (_hiveClient.categoriesBox.length == 0) {
      return categories;
    }

    final values = _hiveClient.categoriesBox.values.toList();

    for (var value in values) {
      if (value.userId == userId) {
        categories.add(CategoryModel.fromJson(value.toJson()));
      }
    }

    if (categories.isNotEmpty) {
      categories.sort((a, b) {
        int aMicroseconds = a.createdAt.microsecondsSinceEpoch;
        int bMicroseconds = b.createdAt.microsecondsSinceEpoch;

        return aMicroseconds.compareTo(bMicroseconds);
      });
    }

    return categories;
  }

  @override
  Future<CategoryModel> fetchItem(Query<String> query) async {
    final categoryId = query.state.data;

    if (categoryId == null) {
      throw Exception('Category ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final category = _hiveClient.categoriesBox.get(categoryId);

    if (category == null) {
      throw Exception('Category not found');
    }

    return CategoryModel.fromJson(category.toJson());
  }

  @override
  Future<CategoryModel> create(Query<CategoryModel> query) async {
    final category = query.state.data;

    if (category == null) {
      throw Exception('Category is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final newCategory = CategoryHiveModel(
      name: category.name,
      userId: category.userId,
    );

    _hiveClient.categoriesBox.put(newCategory.id, newCategory);

    return CategoryModel.fromJson(newCategory.toJson());
  }

  @override
  Future<CategoryModel> update(Query<CategoryModel> query) async {
    final category = query.state.data;

    if (category == null) {
      throw Exception('Category is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    final currentCategory = _hiveClient.categoriesBox.get(category.id);

    if (currentCategory == null) {
      throw Exception('Category not found');
    }

    final updatedCategory = CategoryHiveModel(
      id: category.id,
      createdAt: category.createdAt.toIso8601String(),
      name: category.name,
      userId: currentCategory.userId,
    );

    await _hiveClient.categoriesBox.put(updatedCategory.id, updatedCategory);

    return CategoryModel.fromJson(updatedCategory.toJson());
  }

  @override
  Future<void> delete(Query<String> query) async {
    final categoryId = query.state.params['id'];

    if (categoryId == null) {
      throw Exception('Category ID is null');
    }

    await Future.delayed(const Duration(milliseconds: 900));

    _hiveClient.categoriesBox.delete(categoryId);
  }
}
