import 'package:todo_models/todo_models.dart';
import '../state/category_state.dart';
import '../actions/category_actions.dart';

/// Редюсер для обработки действий с категориями
CategoryState categoryReducer(CategoryState state, CategoryAction action) {
  if (action is SetCategoriesAction) {
    return state.copyWith(categories: action.categories);
  }

  if (action is AddCategoryAction) {
    final newCategories = Map<String, CategoryModel>.from(state.categories);
    newCategories[action.category.id] = action.category;
    return state.copyWith(categories: newCategories);
  }

  if (action is UpdateCategoryAction) {
    final newCategories = Map<String, CategoryModel>.from(state.categories);
    newCategories[action.category.id] = action.category;
    return state.copyWith(categories: newCategories);
  }

  if (action is RemoveCategoryAction) {
    final newCategories = Map<String, CategoryModel>.from(state.categories);
    newCategories.remove(action.categoryId);
    return state.copyWith(categories: newCategories);
  }

  if (action is ClearCategoriesAction) {
    return state.copyWith(categories: {});
  }

  return state;
}
