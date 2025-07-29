import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo_models/todo_models.dart';

import '../../app/store/app_slice/app_slice.dart';
import '../../app/store/task_slice/task_slice.dart';
import '../../app/store/fetch_slice/actions/fetch_actions.dart';
import '../../shared/ui_kit/ui_kit.dart';

/// Страница создания/редактирования задачи
class TaskEditor extends StatefulWidget {
  /// Задача для редактирования (null для создания новой)
  final TaskModel? task;

  const TaskEditor({super.key, this.task});

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isFetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _descriptionController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _TaskEditorViewModel>(
      converter: (store) => _TaskEditorViewModel.fromStore(store, widget.task),
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
  Widget _buildContent(_TaskEditorViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create task' : 'Edit task'),
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
              onPressed: _canSave() ? _saveTask : null,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildForm(viewModel),
    );
  }

  /// Строим форму
  Widget _buildForm(_TaskEditorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Поле названия
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Task name *',
              border: OutlineInputBorder(),
              hintText: 'Enter task name',
            ),
            onChanged: (value) {
              setState(() {});
            },
            autofocus: true,
          ),
          const SizedBox(height: 16),

          // Поле описания
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              hintText: 'Enter task description (optional)',
            ),
            maxLines: 4,
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 24),

          // Информация о задаче (если редактирование)
          if (widget.task != null) ...[
            _buildTaskInfo(widget.task!),
            const SizedBox(height: 24),
          ],

          // Кнопка сохранения
          ElevatedButton(
            onPressed: _canSave() && !_isFetching ? _saveTask : null,
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
                : Text(widget.task == null ? 'Create task' : 'Save changes'),
          ),
        ],
      ),
    );
  }

  /// Строим информацию о задаче
  Widget _buildTaskInfo(TaskModel task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', task.id),
            _buildInfoRow('Created', _formatDate(task.createdAt)),
            _buildInfoRow(
              'Category',
              task.categoryId.isEmpty ? 'No category' : task.categoryId,
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

  /// Сохраняем задачу
  void _saveTask() async {
    if (!_canSave()) return;

    setState(() {
      _isFetching = true;
      _error = null;
    });

    try {
      final store = StoreProvider.of<AppState>(context, listen: false);
      final taskSlice = TaskSlice();

      final taskData = TaskModel.createEmpty().copyWith(
        name: _nameController.text.trim(),
      );

      if (widget.task == null) {
        // Создание новой задачи
        store.dispatch(taskSlice.thunks.createTask(taskData));
      } else {
        // Обновление существующей задачи
        final updatedTask = widget.task!.copyWith(
          name: _nameController.text.trim(),
        );
        store.dispatch(taskSlice.thunks.updateTask(updatedTask));
      }

      // Возвращаемся назад
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Error saving task: ${e.toString()}';
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

/// ViewModel для страницы редактирования задачи
class _TaskEditorViewModel {
  final bool isFetching;
  final String? error;
  final Function(TaskModel) createTask;
  final Function(TaskModel) updateTask;
  final VoidCallback clearError;

  _TaskEditorViewModel({
    required this.isFetching,
    required this.error,
    required this.createTask,
    required this.updateTask,
    required this.clearError,
  });

  factory _TaskEditorViewModel.fromStore(
    Store<AppState> store,
    TaskModel? task,
  ) {
    final taskSlice = TaskSlice();
    final fetchState = store.state.fetchState;

    // Определяем ключ для статуса
    final statusKey = task == null ? 'create_task' : 'update_task_${task.id}';

    return _TaskEditorViewModel(
      isFetching: fetchState.status(statusKey).isFetching,
      error: fetchState.status(statusKey).error.isNotEmpty
          ? fetchState.status(statusKey).error
          : null,
      createTask: (taskData) =>
          store.dispatch(taskSlice.thunks.createTask(taskData)),
      updateTask: (taskData) =>
          store.dispatch(taskSlice.thunks.updateTask(taskData)),
      clearError: () => store.dispatch(FetchClearErrorAction(statusKey)),
    );
  }
}
