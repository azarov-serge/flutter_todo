import 'package:todo_models/todo_models.dart';
import '../state/category_state.dart';

/// Селекторы для получения данных из состояния категорий
class CategorySelectors {
  /// Получить список всех категорий
  static List<CategoryModel> getCategories(CategoryState state) {
    return state.categories.values.toList();
  }

  /// Получить категорию по ID
  static CategoryModel? getCategoryById(
    CategoryState state,
    String categoryId,
  ) {
    return state.categories[categoryId];
  }

  /// Получить количество категорий
  static int getCategoriesCount(CategoryState state) {
    return state.categories.length;
  }

  /// Проверить, есть ли категории
  static bool hasCategories(CategoryState state) {
    return state.categories.isNotEmpty;
  }

  /// Получить категории по пользователю
  static List<CategoryModel> getCategoriesByUser(
    CategoryState state,
    String userId,
  ) {
    return state.categories.values
        .where((category) => category.userId == userId)
        .toList();
  }

  /// Получить категорию по названию
  static CategoryModel? getCategoryByName(CategoryState state, String name) {
    try {
      return state.categories.values.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Получить категории с сортировкой по дате создания
  static List<CategoryModel> getCategoriesSortedByCreatedAt(
    CategoryState state,
  ) {
    final categories = state.categories.values.toList();
    categories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return categories;
  }
}
