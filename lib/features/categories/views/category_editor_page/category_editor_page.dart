import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/features/categories/providers/category_query.dart';
import 'package:todo_models/todo_models.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/category_notifier.dart';
import '../../../../shared/providers/request_provider.dart';

/// Страница создания/редактирования категории
class CategoryEditorPage extends ConsumerStatefulWidget {
  /// ID категории для редактирования (пустая строка для создания новой)
  final String categoryId;

  const CategoryEditorPage({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryEditorPage> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<CategoryEditorPage> {
  late CategoryModel _category;
  late TextEditingController _nameController;
  bool _isLoadingCategory = false;

  @override
  void initState() {
    super.initState();
    _initializeCategory();
  }

  void _initializeCategory() {
    final userId = ref.read(categoriesUserIdProvider) ?? UniqueKey().toString();

    if (widget.categoryId.isEmpty) {
      // Создание новой категории
      final id = UniqueKey().toString();
      _category = CategoryModel.createEmpty().copyWith(id: id, userId: userId);
      _nameController = TextEditingController();
    } else {
      // Редактирование существующей категории
      _category = CategoryModel.createEmpty();
      _nameController = TextEditingController();
      _loadCategoryIfNeeded();
    }
  }

  void _loadCategoryIfNeeded() {
    final categories = ref.read(categoriesProvider);
    final existingCategory = categories.firstWhere(
      (category) => category.id == widget.categoryId,
      orElse: () => CategoryModel.createEmpty(),
    );

    if (existingCategory.id.isNotEmpty) {
      // Категория найдена в состоянии
      setState(() {
        _category = existingCategory;
        _nameController.text = existingCategory.name;
      });
    } else {
      // Категория не найдена, загружаем с сервера
      setState(() {
        _isLoadingCategory = true;
      });
      ref
          .read(categoryNotifierProvider.notifier)
          .fetchCategory(widget.categoryId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем изменения в категориях для обновления данных
    final categories = ref.watch(categoriesProvider);
    final existingCategory = categories.firstWhere(
      (cat) => cat.id == widget.categoryId,
      orElse: () => CategoryModel.createEmpty(),
    );

    // Если категория найдена в состоянии и мы её загружали
    if (existingCategory.id.isNotEmpty && _isLoadingCategory) {
      setState(() {
        _category = existingCategory;
        _nameController.text = existingCategory.name;
        _isLoadingCategory = false;
      });
    }

    final query = CategoryQuery.creationCategory(_category);
    final requestState = ref.watch(requestStateProvider(query.state.key));
    final isLoading =
        ref.watch(categoryLoadingProvider) ||
        requestState.isLoading ||
        _isLoadingCategory;

    return ErrorWrapper(
      error: requestState.error,
      onClosePressed: () {
        ref.read(requestNotifierProvider.notifier).clearError(query.state.key);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.categoryId.isEmpty ? 'Create category' : 'Edit category',
          ),
          actions: [
            if (isLoading)
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
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: _buildForm(isLoading: isLoading),
      ),
    );
  }

  /// Строим форму
  Widget _buildForm({required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Поле названия
          TextField(
            controller: _nameController,
            onChanged: (value) {
              setState(() {
                _category = _category.copyWith(name: value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Category name *',
              border: OutlineInputBorder(),
              hintText: 'Enter category name',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // Информация о категории (если редактирование)
          if (widget.categoryId.isNotEmpty && _category.id.isNotEmpty) ...[
            _buildCategoryInfo(_category),
            const SizedBox(height: 24),
          ],

          // Кнопка сохранения
          ElevatedButton(
            onPressed: _canSave() && !isLoading ? _saveCategory : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
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
                    widget.categoryId.isEmpty
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
    return _category.name.trim().isNotEmpty;
  }

  /// Сохраняем категорию
  void _saveCategory() async {
    if (!_canSave()) return;

    final categoryNotifier = ref.read(categoryNotifierProvider.notifier);

    final categoryData = _category.copyWith(name: _category.name.trim());

    if (widget.categoryId.isEmpty) {
      // Создание новой категории
      await categoryNotifier.createCategory(categoryData);

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
      final updatedCategory = _category.copyWith(name: _category.name.trim());
      await categoryNotifier.updateCategory(updatedCategory);

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

    // Возвращаемся назад
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
