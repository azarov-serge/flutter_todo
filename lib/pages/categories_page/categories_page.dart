import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo_models/todo_models.dart';

import '../../app/store/app_slice/app_slice.dart';
import '../../app/store/category_slice/category_slice.dart';
import '../../app/store/fetch_slice/actions/fetch_actions.dart';
import '../../app/routes.dart';
import '../../shared/ui_kit/ui_kit.dart';

const userId = '1';

/// Страница для отображения и управления категориями
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    _loadCategoriesIfNeeded();
  }

  /// Загружаем категории, если их нет
  void _loadCategoriesIfNeeded() {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final categorySlice = CategorySlice();
    final categories = categorySlice.getCategories(store.state.categoryState);

    if (categories.isEmpty) {
      store.dispatch(categorySlice.thunks.fetchCategories(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CategoriesViewModel>(
      converter: (store) => _CategoriesViewModel.fromStore(store),
      builder: (context, viewModel) {
        return ErrorWrapper(
          error: viewModel.error,
          onClosePressed: viewModel.clearError,
          child: _buildContent(viewModel),
        );
      },
    );
  }

  /// Строим контент страницы
  Widget _buildContent(_CategoriesViewModel viewModel) {
    if (viewModel.isLoading) {
      return SplashScreen(message: 'Loading categories...');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => AppRoutes.goToCreateCategory(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadCategories(userId),
          ),
        ],
      ),
      body: _buildCategoriesList(viewModel),
    );
  }

  /// Строим список категорий
  Widget _buildCategoriesList(_CategoriesViewModel viewModel) {
    if (viewModel.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No categories',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Click + to add a category',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.categories.length,
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        return _buildCategoryCard(category, viewModel);
      },
    );
  }

  /// Строим карточку категории
  Widget _buildCategoryCard(
    CategoryModel category,
    _CategoriesViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Created: ${_formatDate(category.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () => AppRoutes.goToTasks(context, categoryId: category.id),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'tasks':
                AppRoutes.goToTasks(context, categoryId: category.id);
                break;
              case 'edit':
                AppRoutes.goToEditCategory(context, category);
                break;
              case 'delete':
                _showDeleteCategoryDialog(context, category, viewModel);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'tasks',
              child: Row(
                children: [
                  Icon(Icons.task, size: 16),
                  SizedBox(width: 8),
                  Text('View Tasks'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Форматируем дату
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Диалог удаления категории
  void _showDeleteCategoryDialog(
    BuildContext context,
    CategoryModel category,
    _CategoriesViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.deleteCategory(category.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// ViewModel для страницы категорий
class _CategoriesViewModel {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final Function(String) loadCategories;
  final Function(CategoryModel) createCategory;
  final Function(CategoryModel) updateCategory;
  final Function(String) deleteCategory;
  final VoidCallback clearError;

  _CategoriesViewModel({
    required this.categories,
    required this.isLoading,
    required this.error,
    required this.loadCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.clearError,
  });

  factory _CategoriesViewModel.fromStore(Store<AppState> store) {
    final categorySlice = CategorySlice();
    final fetchState = store.state.fetchState;

    return _CategoriesViewModel(
      categories: categorySlice.getCategories(store.state.categoryState),
      isLoading: fetchState
          .status(categorySlice.thunks.categoriesQuery.state.key)
          .isFetching,
      error:
          fetchState
              .status(categorySlice.thunks.categoriesQuery.state.key)
              .error
              .isNotEmpty
          ? fetchState
                .status(categorySlice.thunks.categoriesQuery.state.key)
                .error
          : null,
      loadCategories: (String userId) =>
          store.dispatch(categorySlice.thunks.fetchCategories(userId)),
      createCategory: (category) =>
          store.dispatch(categorySlice.thunks.createCategory(category)),
      updateCategory: (category) =>
          store.dispatch(categorySlice.thunks.updateCategory(category)),
      deleteCategory: (categoryId) =>
          store.dispatch(categorySlice.thunks.deleteCategory(categoryId)),
      clearError: () => store.dispatch(
        FetchClearErrorAction(categorySlice.thunks.categoriesQuery.state.key),
      ),
    );
  }
}
