import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_models/todo_models.dart';

import '../../../../app/routes.dart';
import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/task_notifier.dart';
import '../../providers/task_query.dart';
import '../../../../shared/providers/request_provider.dart';

/// Страница задач
class TasksPage extends ConsumerStatefulWidget {
  /// ID категории для фильтрации задач (null для всех задач)
  final String? categoryId;

  const TasksPage({super.key, this.categoryId});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    print('TasksPage: categoryId: ${widget.categoryId}');
    // Ленивая инициализация загрузки задач
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.categoryId != null) {
          ref
              .read(taskNotifierProvider.notifier)
              .updateCategoryId(widget.categoryId);
          ref
              .read(taskNotifierProvider.notifier)
              .fetchTasks(widget.categoryId!);
        }
      });
    }

    final tasks = ref.watch(tasksProvider);
    final query = widget.categoryId != null
        ? TaskQuery.tasks(widget.categoryId!)
        : null;
    final requestState = query != null
        ? ref.watch(requestStateProvider(query.state.key))
        : null;

    return ErrorWrapper(
      error: requestState?.error,
      onClosePressed: () {
        if (query != null) {
          ref
              .read(requestNotifierProvider.notifier)
              .clearError(query.state.key);
        }
      },
      child: _buildContent(tasks, requestState?.isLoading ?? false),
    );
  }

  /// Строим контент страницы
  Widget _buildContent(List<TaskModel> tasks, bool isLoading) {
    if (isLoading && tasks.isEmpty) {
      return SplashScreen(message: 'Loading tasks...');
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
            icon: const Icon(Icons.add),
            onPressed: () => AppRoutes.goToCreateTask(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.categoryId != null) {
            await ref
                .read(taskNotifierProvider.notifier)
                .fetchTasks(widget.categoryId!);
          }
        },
        child: _buildTasksList(tasks),
      ),
    );
  }

  /// Строим список задач
  Widget _buildTasksList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
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
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  /// Строим карточку задачи
  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.task_alt),
        title: Text(
          task.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Created: ${_formatDate(task.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () => AppRoutes.goToEditTask(context, task),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                AppRoutes.goToEditTask(context, task);
                break;
              case 'delete':
                _showDeleteTaskDialog(context, task);
                break;
            }
          },
          itemBuilder: (context) => [
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Показываем диалог удаления задачи
  void _showDeleteTaskDialog(BuildContext context, TaskModel task) {
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
              ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
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
