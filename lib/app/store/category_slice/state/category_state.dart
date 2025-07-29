import 'package:todo_models/todo_models.dart';

/// Состояние для управления категориями
class CategoryState {
  /// Карта категорий по ID
  final Map<String, CategoryModel> categories;

  const CategoryState({this.categories = const {}});

  /// Создание копии с изменениями
  CategoryState copyWith({Map<String, CategoryModel>? categories}) {
    return CategoryState(categories: categories ?? this.categories);
  }

  /// Начальное состояние
  static const CategoryState initial = CategoryState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryState && other.categories == categories;
  }

  @override
  int get hashCode => categories.hashCode;

  @override
  String toString() => 'CategoryState(categories: $categories)';
}
