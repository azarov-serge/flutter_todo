import 'package:todo_models/todo_models.dart';

/// Базовый класс для всех действий с категориями
abstract class CategoryAction {
  const CategoryAction();
}

/// Действие для установки списка категорий
class SetCategoriesAction extends CategoryAction {
  final Map<String, CategoryModel> categories;

  const SetCategoriesAction(this.categories);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetCategoriesAction && other.categories == categories;
  }

  @override
  int get hashCode => categories.hashCode;

  @override
  String toString() => 'SetCategoriesAction(categories: $categories)';
}

/// Действие для добавления категории
class AddCategoryAction extends CategoryAction {
  final CategoryModel category;

  const AddCategoryAction(this.category);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddCategoryAction && other.category == category;
  }

  @override
  int get hashCode => category.hashCode;

  @override
  String toString() => 'AddCategoryAction(category: $category)';
}

/// Действие для обновления категории
class UpdateCategoryAction extends CategoryAction {
  final CategoryModel category;

  const UpdateCategoryAction(this.category);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateCategoryAction && other.category == category;
  }

  @override
  int get hashCode => category.hashCode;

  @override
  String toString() => 'UpdateCategoryAction(category: $category)';
}

/// Действие для удаления категории
class RemoveCategoryAction extends CategoryAction {
  final String categoryId;

  const RemoveCategoryAction(this.categoryId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoveCategoryAction && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;

  @override
  String toString() => 'RemoveCategoryAction(categoryId: $categoryId)';
}

/// Действие для очистки всех категорий
class ClearCategoriesAction extends CategoryAction {
  const ClearCategoriesAction();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearCategoriesAction;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'ClearCategoriesAction()';
}
