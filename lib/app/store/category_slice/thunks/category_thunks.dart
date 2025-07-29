import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:todo_api/todo_api.dart';
import 'package:todo_models/todo_models.dart';
import '../actions/category_actions.dart';
import '../../fetch_slice/fetch_slice.dart';

/// Thunk actions для асинхронных операций с категориями
class CategoryThunks {
  final CategoryApi categoryApi = getIt.get<CategoryApi>();
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();

  // Query для различных операций
  final Query<String> categoriesQuery = Query<String>(
    state: QueryState<String>(baseUrl: '/categories', key: 'categories'),
  );

  final Query<String> categoryQuery = Query(
    state: QueryState(baseUrl: '/categories/', key: 'category'),
  );

  final Query<CategoryModel> createCategoryQuery = Query(
    state: QueryState(baseUrl: '/categories', method: 'POST'),
  );

  final Query<CategoryModel> updateCategoryQuery = Query(
    state: QueryState(baseUrl: '/categories/', method: 'PUT'),
  );

  final Query<String> deleteCategoryQuery = Query(
    state: QueryState(baseUrl: '/categories', method: 'DELETE'),
  );

  /// Получение списка категорий
  ThunkAction<AppState> fetchCategories(String userId) {
    return (Store<AppState> store) async {
      final query = categoriesQuery.copyWith(
        categoriesQuery.state.copyWith(urlParam: userId),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          final categories = await categoryApi.fetchList(query);
          final categoriesMap = <String, CategoryModel>{};
          for (final category in categories) {
            categoriesMap[category.id] = category;
          }

          store.dispatch(SetCategoriesAction(categoriesMap));
        },
      );
    };
  }

  /// Получение категории по ID
  ThunkAction<AppState> fetchCategory(String categoryId) {
    return (Store<AppState> store) async {
      final query = categoryQuery.copyWith(
        categoryQuery.state.copyWith(urlParam: categoryId),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          final category = await categoryApi.fetchItem(query);
          store.dispatch(AddCategoryAction(category));
        },
      );
    };
  }

  /// Создание новой категории
  ThunkAction<AppState> createCategory(CategoryModel category) {
    return (Store<AppState> store) async {
      final query = Query<CategoryModel>(
        state: QueryState<CategoryModel>(
          baseUrl: '/categories',
          method: 'POST',
          data: category,
        ),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          final createdCategory = await categoryApi.create(query);
          store.dispatch(AddCategoryAction(createdCategory));
        },
      );
    };
  }

  /// Обновление категории
  ThunkAction<AppState> updateCategory(CategoryModel category) {
    print('updateCategory: $category');
    return (Store<AppState> store) async {
      final query = Query<CategoryModel>(
        state: QueryState<CategoryModel>(
          baseUrl: '/categories',
          method: 'PUT',
          urlParam: category.id,
          data: category,
        ),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          final updatedCategory = await categoryApi.update(query);
          print('updatedCategory: $updatedCategory');
          store.dispatch(UpdateCategoryAction(updatedCategory));
        },
      );
    };
  }

  /// Удаление категории
  ThunkAction<AppState> deleteCategory(String categoryId) {
    return (Store<AppState> store) async {
      final query = Query<String>(
        state: QueryState<String>(
          baseUrl: '/categories',
          method: 'DELETE',
          params: {'id': categoryId},
        ),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          await categoryApi.delete(query);
          store.dispatch(RemoveCategoryAction(categoryId));
        },
      );
    };
  }
}
