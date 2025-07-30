import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_models/todo_models.dart';
import 'package:todo_api/todo_api.dart';

import 'category_state.dart';
import 'category_query.dart';
import '../../../shared/providers/request_provider.dart';

/// Notifier for managing category state
class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryApi _categoryApi;
  final RequestNotifier _requestNotifier;

  CategoryNotifier(this._categoryApi, this._requestNotifier)
    : super(CategoryState.initial());

  /// Fetch all categories for current user
  Future<void> fetchCategories() async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    final query = CategoryQuery.categories(userId);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Fetch categories
      final categories = await _categoryApi.fetchList(query);

      // Update state on success
      state = state.copyWith(categories: categories);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Fetch category by id
  Future<void> fetchCategory(String id) async {
    final query = CategoryQuery.category(id);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Fetch category
      final category = await _categoryApi.fetchItem(query);

      // Update state on success
      state = state.copyWith(categories: [...state.categories, category]);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Create new category for current user
  Future<void> createCategory(CategoryModel category) async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    final query = CategoryQuery.creationCategory(category);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Create category
      final createdCategory = await _categoryApi.create(query);

      // Update state on success
      state = state.copyWith(
        categories: [...state.categories, createdCategory],
      );

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Update category
  Future<void> updateCategory(CategoryModel category) async {
    final query = CategoryQuery.updationCategory(category);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Update category
      final updatedCategory = await _categoryApi.update(query);

      // Update state on success
      final updatedCategories = state.categories.map((c) {
        return c.id == category.id ? updatedCategory : c;
      }).toList();

      state = state.copyWith(categories: updatedCategories);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    final query = CategoryQuery.deletionCategory(categoryId);
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Delete category
      await _categoryApi.delete(query);

      // Update state on success
      final updatedCategories = state.categories
          .where((c) => c.id != categoryId)
          .toList();
      state = state.copyWith(categories: updatedCategories);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Update user ID when user profile is loaded
  void updateUserId(String? userId) {
    state = state.copyWith(userId: userId);
  }

  /// Select category
  void selectCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  /// Reset state
  void reset() {
    state = CategoryState.initial();
  }
}

/// Provider for category notifier
final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
      final categoryApi = GetIt.instance.get<CategoryApi>();
      final requestNotifier = ref.watch(requestNotifierProvider.notifier);
      return CategoryNotifier(categoryApi, requestNotifier);
    });

/// Provider for categories list
final categoriesUserIdProvider = Provider<String?>(
  (ref) => ref.watch(categoryNotifierProvider).userId,
);

/// Provider for categories list
final categoriesProvider = Provider<List<CategoryModel>>(
  (ref) => ref.watch(categoryNotifierProvider).categories,
);

/// Provider for selected category
final selectedCategoryProvider = Provider<CategoryModel?>(
  (ref) => ref.watch(categoryNotifierProvider).selectedCategory,
);

/// Provider for category loading state - now uses RequestNotifier with userId
final categoryLoadingProvider = Provider<bool>((ref) {
  final categoryState = ref.watch(categoryNotifierProvider);
  final userId = categoryState.userId;
  if (userId == null) return false;
  final query = CategoryQuery.categories(userId);
  return ref.watch(requestStateProvider(query.state.key)).isLoading;
});

/// Provider for category error - now uses RequestNotifier with userId
final categoryErrorProvider = Provider<String?>((ref) {
  final categoryState = ref.watch(categoryNotifierProvider);
  final userId = categoryState.userId;
  if (userId == null) return null;
  final query = CategoryQuery.categories(userId);
  return ref.watch(requestStateProvider(query.state.key)).error;
});
