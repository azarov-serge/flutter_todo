import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo_models/todo_models.dart';

import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/task_slice/task_slice.dart';
import 'package:flutter_todo/app/store/fetch_slice/actions/fetch_actions.dart';
import 'package:flutter_todo/app/routes.dart';
import 'package:flutter_todo/shared/ui_kit/ui_kit.dart';

/// Страница задач
class TasksPage extends StatefulWidget {
  /// ID категории для фильтрации задач (null для всех задач)
  final String? categoryId;

  const TasksPage({super.key, this.categoryId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
    // Запускаем загрузку задач при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksIfNeeded();
    });
  }

  /// Загружаем задачи если их нет
  void _loadTasksIfNeeded() {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final taskSlice = TaskSlice();
    final tasks = taskSlice.getTasks(store);

    if (tasks.isEmpty) {
      store.dispatch(taskSlice.thunks.fetchTasks());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _TasksViewModel>(
      converter: (store) => _TasksViewModel.fromStore(store),
      builder: (context, viewModel) {
        return ErrorWrapper(
          error: viewModel.error,
          onClosePressed: () {
            viewModel.clearError();
          },
          child: _buildContent(viewModel),
        );
      },
    );
  }

  /// Строим контент страницы
  Widget _buildContent(_TasksViewModel viewModel) {
    // Показываем splash screen во время загрузки
    if (viewModel.isFetching) {
      return SplashScreen(
        message: 'Loading tasks...',
        spinnerSize: 28,
        spinnerColor: Theme.of(context).primaryColor,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId != null ? 'Tasks' : 'All Tasks'),
        leading: widget.categoryId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => AppRoutes.goBack(context),
              )
            : IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => AppRoutes.goToCreateTask(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.isFetching
                ? null
                : () {
                    viewModel.loadTasks();
                  },
          ),
          if (widget.categoryId == null)
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => AppRoutes.goToCategories(context),
            ),
        ],
      ),
      body: _buildTasksList(viewModel),
    );
  }

  /// Строим список задач
  Widget _buildTasksList(_TasksViewModel viewModel) {
    if (viewModel.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Click + to add a task',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.tasks.length,
      itemBuilder: (context, index) {
        final task = viewModel.tasks[index];
        return _buildTaskCard(task, viewModel);
      },
    );
  }

  /// Строим карточку задачи
  Widget _buildTaskCard(TaskModel task, _TasksViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.task_alt),
        title: Text(
          task.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Created: ${task.createdAt.toString().split(' ')[0]}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                AppRoutes.goToEditTask(context, task);
                break;
              case 'delete':
                _showDeleteTaskDialog(context, task, viewModel);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
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

  /// Показываем диалог удаления задачи
  void _showDeleteTaskDialog(
    BuildContext context,
    TaskModel task,
    _TasksViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text(
          'Are you sure you want to delete the task "${task.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// ViewModel для страницы задач
class _TasksViewModel {
  final List<TaskModel> tasks;
  final bool isFetching;
  final String? error;
  final VoidCallback loadTasks;
  final Function(TaskModel) createTask;
  final Function(TaskModel) updateTask;
  final Function(String) deleteTask;
  final VoidCallback clearError;

  _TasksViewModel({
    required this.tasks,
    required this.isFetching,
    required this.error,
    required this.loadTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.clearError,
  });

  factory _TasksViewModel.fromStore(Store<AppState> store) {
    final taskSlice = TaskSlice();
    final fetchState = store.state.fetchState;

    return _TasksViewModel(
      tasks: taskSlice.getTasks(store),
      isFetching: fetchState.status('tasks').isFetching,
      error: fetchState.status('tasks').error.isNotEmpty
          ? fetchState.status('tasks').error
          : null,
      loadTasks: () => store.dispatch(taskSlice.thunks.fetchTasks()),
      createTask: (task) => store.dispatch(taskSlice.thunks.createTask(task)),
      updateTask: (task) => store.dispatch(taskSlice.thunks.updateTask(task)),
      deleteTask: (taskId) =>
          store.dispatch(taskSlice.thunks.deleteTask(taskId)),
      clearError: () => store.dispatch(FetchClearErrorAction('tasks')),
    );
  }
}
