import 'package:todo_models/todo_models.dart';

/// State for categories feature
/// Loading and error states are managed by RequestNotifier
class CategoryState {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final String? userId; // ID текущего пользователя

  const CategoryState({
    this.categories = const [],
    this.selectedCategoryId = '',
    this.userId,
  });

  /// Initial state
  factory CategoryState.initial() => const CategoryState();

  /// Copy with changes
  CategoryState copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    String? userId,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      userId: userId ?? this.userId,
    );
  }

  /// Get selected category by ID
  CategoryModel? get selectedCategory {
    if (selectedCategoryId.isEmpty) {
      return null;
    }
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'CategoryState(categories: ${categories.length}, selectedCategoryId: $selectedCategoryId, userId: $userId)';
  }
}
