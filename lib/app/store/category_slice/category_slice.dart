import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:todo_models/todo_models.dart';

import 'state/category_state.dart';
import 'actions/category_actions.dart';
import 'reducer/category_reducer.dart';
import 'thunks/category_thunks.dart';
import 'selectors/category_selectors.dart';
import '../fetch_slice/fetch_slice.dart';

/// Класс для управления категориями
class CategorySlice {
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();
  // Экземпляр CategoryThunks
  final CategoryThunks thunks = CategoryThunks();

  String get userId => '1';

  /// Получить статус загрузки категорий
  QueryStatus categoriesStatus(Store<AppState> store) {
    final fetchState = store.state.fetchState;
    final query = thunks.categoriesQuery.copyWith(
      thunks.categoriesQuery.state.copyWith(urlParam: userId),
    );

    return fetchState.status(query.state.key);
  }

  /// Получить статус загрузки категории по ID
  QueryStatus categoryStatus(Store<AppState> store, String categoryId) {
    final fetchState = store.state.fetchState;
    final query = thunks.categoryQuery.copyWith(
      thunks.categoryQuery.state.copyWith(urlParam: categoryId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус создания категории
  QueryStatus creatingCategoryStatus(Store<AppState> store, String categoryId) {
    final fetchState = store.state.fetchState;
    final query = thunks.createCategoryQuery.copyWith(
      thunks.createCategoryQuery.state.copyWith(id: categoryId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус обновления категории
  QueryStatus updatingCategoryStatus(Store<AppState> store, String categoryId) {
    final fetchState = store.state.fetchState;
    final query = thunks.updateCategoryQuery.copyWith(
      thunks.updateCategoryQuery.state.copyWith(urlParam: categoryId),
    );
    return fetchState.status(query.state.key);
  }

  /// Получить статус удаления категории
  QueryStatus deletingCategoryStatus(Store<AppState> store, String categoryId) {
    final fetchState = store.state.fetchState;
    final query = thunks.deleteCategoryQuery.copyWith(
      thunks.deleteCategoryQuery.state.copyWith(params: {'id': categoryId}),
    );
    return fetchState.status(query.state.key);
  }

  /// Сбросить ошибку для категорий
  void resetCategoriesError(Store<AppState> store, String userId) {
    final query = thunks.categoriesQuery.copyWith(
      thunks.categoriesQuery.state.copyWith(data: userId),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку для категории по ID
  void resetCategoryError(Store<AppState> store, String categoryId) {
    final query = thunks.categoryQuery.copyWith(
      thunks.categoryQuery.state.copyWith(urlParam: categoryId),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку создания категории
  void resetCreateCategoryError(Store<AppState> store, String categoryId) {
    final query = thunks.createCategoryQuery.copyWith(
      thunks.createCategoryQuery.state.copyWith(id: categoryId),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку обновления категории
  void resetUpdateCategoryError(Store<AppState> store, String categoryId) {
    final query = thunks.updateCategoryQuery.copyWith(
      thunks.updateCategoryQuery.state.copyWith(urlParam: categoryId),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Сбросить ошибку удаления категории
  void resetDeleteCategoryError(Store<AppState> store, String categoryId) {
    final query = thunks.deleteCategoryQuery.copyWith(
      thunks.deleteCategoryQuery.state.copyWith(params: {'id': categoryId}),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Получить список категорий
  List<CategoryModel> getCategories(CategoryState state) {
    return CategorySelectors.getCategories(state);
  }

  /// Получить категорию по ID
  CategoryModel? getCategoryById(CategoryState state, String categoryId) {
    return CategorySelectors.getCategoryById(state, categoryId);
  }

  /// Получить количество категорий
  int getCategoriesCount(CategoryState state) {
    return CategorySelectors.getCategoriesCount(state);
  }

  /// Проверить, есть ли категории
  bool hasCategories(CategoryState state) {
    return CategorySelectors.hasCategories(state);
  }

  /// Получить категории по пользователю
  List<CategoryModel> getCategoriesByUser(CategoryState state) {
    return CategorySelectors.getCategoriesByUser(state, userId);
  }

  /// Получить категорию по названию
  CategoryModel? getCategoryByName(CategoryState state, String name) {
    return CategorySelectors.getCategoryByName(state, name);
  }

  /// Получить категории с сортировкой по дате создания
  List<CategoryModel> getCategoriesSortedByCreatedAt(CategoryState state) {
    return CategorySelectors.getCategoriesSortedByCreatedAt(state);
  }

  /// Получить редюсер
  Reducer<CategoryState> get reducer => (CategoryState state, dynamic action) {
    if (action is CategoryAction) {
      return categoryReducer(state, action);
    }
    return state;
  };

  /// Получить начальное состояние
  CategoryState get initialState => CategoryState.initial;
}
