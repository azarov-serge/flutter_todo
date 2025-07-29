import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo_models/todo_models.dart';

import '../../app/store/app_slice/app_slice.dart';
import '../../app/store/category_slice/category_slice.dart';
import '../../app/store/fetch_slice/actions/fetch_actions.dart';

import '../../shared/ui_kit/ui_kit.dart';

const _userId = '1';

/// Страница создания/редактирования категории
class CategoryEditor extends StatefulWidget {
  /// Категория для редактирования (null для создания новой)
  final CategoryModel? category;

  const CategoryEditor({super.key, this.category});

  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  late TextEditingController _nameController;
  bool _isFetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CategoryEditorViewModel>(
      converter: (store) =>
          _CategoryEditorViewModel.fromStore(store, widget.category),
      builder: (context, viewModel) {
        return ErrorWrapper(
          error: _error,
          onClosePressed: () {
            setState(() {
              _error = null;
            });
          },
          child: _buildContent(viewModel),
        );
      },
    );
  }

  /// Строим контент страницы
  Widget _buildContent(_CategoryEditorViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Create category' : 'Edit category',
        ),
        actions: [
          if (_isFetching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _canSave() ? _saveCategory : null,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildForm(viewModel),
    );
  }

  /// Строим форму
  Widget _buildForm(_CategoryEditorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Поле названия
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category name *',
              border: OutlineInputBorder(),
              hintText: 'Enter category name',
            ),
            onChanged: (value) {
              setState(() {});
            },
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // Информация о категории (если редактирование)
          if (widget.category != null) ...[
            _buildCategoryInfo(widget.category!),
            const SizedBox(height: 24),
          ],

          // Кнопка сохранения
          ElevatedButton(
            onPressed: _canSave() && !_isFetching ? _saveCategory : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isFetching
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  )
                : Text(
                    widget.category == null
                        ? 'Create category'
                        : 'Save changes',
                  ),
          ),
        ],
      ),
    );
  }

  /// Строим информацию о категории
  Widget _buildCategoryInfo(CategoryModel category) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', category.id),
            _buildInfoRow('Created', _formatDate(category.createdAt)),
            _buildInfoRow(
              'User',
              category.userId.isEmpty ? 'No user' : category.userId,
            ),
          ],
        ),
      ),
    );
  }

  /// Строим строку информации
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Форматируем дату
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Проверяем, можно ли сохранить
  bool _canSave() {
    return _nameController.text.trim().isNotEmpty;
  }

  /// Сохраняем категорию
  void _saveCategory() async {
    if (!_canSave()) return;

    setState(() {
      _isFetching = true;
      _error = null;
    });

    try {
      final store = StoreProvider.of<AppState>(context, listen: false);
      final categorySlice = CategorySlice();

      final categoryData = CategoryModel.createEmpty().copyWith(
        name: _nameController.text.trim(),
        userId: _userId,
      );

      if (widget.category == null) {
        // Создание новой категории
        store.dispatch(categorySlice.thunks.createCategory(categoryData));

        // Показываем уведомление об успешном создании
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Обновление существующей категории
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
        );
        store.dispatch(categorySlice.thunks.updateCategory(updatedCategory));

        // Показываем уведомление об успешном обновлении
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated successfully!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error saving category: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }
}

/// ViewModel для страницы редактирования категории
class _CategoryEditorViewModel {
  final bool isFetching;
  final String? error;
  final Function(CategoryModel) createCategory;
  final Function(CategoryModel) updateCategory;
  final VoidCallback clearError;

  _CategoryEditorViewModel({
    required this.isFetching,
    required this.error,
    required this.createCategory,
    required this.updateCategory,
    required this.clearError,
  });

  factory _CategoryEditorViewModel.fromStore(
    Store<AppState> store,
    CategoryModel? category,
  ) {
    final categorySlice = CategorySlice();
    final fetchState = store.state.fetchState;

    // Определяем ключ для статуса
    final statusKey = category == null
        ? 'create_category'
        : 'update_category_${category.id}';

    return _CategoryEditorViewModel(
      isFetching: fetchState.status(statusKey).isFetching,
      error: fetchState.status(statusKey).error.isNotEmpty
          ? fetchState.status(statusKey).error
          : null,
      createCategory: (categoryData) =>
          store.dispatch(categorySlice.thunks.createCategory(categoryData)),
      updateCategory: (categoryData) =>
          store.dispatch(categorySlice.thunks.updateCategory(categoryData)),
      clearError: () => store.dispatch(FetchClearErrorAction(statusKey)),
    );
  }
}
