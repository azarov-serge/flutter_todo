import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_models/todo_models.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/task_notifier.dart';
import '../../providers/task_query.dart';
import '../../../../shared/providers/request_provider.dart';

/// Task creation/editing page
class TaskEditor extends ConsumerStatefulWidget {
  /// Task ID for editing (empty string for creating new)
  final String taskId;

  const TaskEditor({super.key, required this.taskId});

  @override
  ConsumerState<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<TaskEditor> {
  late TaskModel _task;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoadingTask = false;

  @override
  void initState() {
    super.initState();
    _initializeTask();
  }

  void _initializeTask() {
    if (widget.taskId.isEmpty) {
      // Creating new task
      final id = UniqueKey().toString();
      final categoryId = ref.read(taskNotifierProvider).categoryId ?? '';
      _task = TaskModel.createEmpty().copyWith(id: id, categoryId: categoryId);
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
    } else {
      // Editing existing task
      _task = TaskModel.createEmpty();
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _loadTaskIfNeeded();
    }
  }

  void _loadTaskIfNeeded() {
    final tasks = ref.read(tasksProvider);
    final existingTask = tasks.firstWhere(
      (task) => task.id == widget.taskId,
      orElse: () => TaskModel.createEmpty(),
    );

    if (existingTask.id.isNotEmpty) {
      // Task found in state
      setState(() {
        _task = existingTask;
        _nameController.text = existingTask.name;
        _descriptionController.text = ''; // Remove description
      });
    } else {
      // Task not found, load from server
      setState(() {
        _isLoadingTask = true;
      });
      // For now just clear state since fetchTask is not implemented
      setState(() {
        _isLoadingTask = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in tasks to update data
    final tasks = ref.watch(tasksProvider);
    final existingTask = tasks.firstWhere(
      (task) => task.id == widget.taskId,
      orElse: () => TaskModel.createEmpty(),
    );

    // If task found in state and we are loading it
    if (existingTask.id.isNotEmpty && _isLoadingTask) {
      setState(() {
        _task = existingTask;
        _nameController.text = existingTask.name;
        _descriptionController.text = ''; // Remove description
        _isLoadingTask = false;
      });
    }

    final query = TaskQuery.creationTask(_task);
    final requestState = ref.watch(requestStateProvider(query.state.key));
    final isLoading = requestState.isLoading || _isLoadingTask;

    return ErrorWrapper(
      error: requestState.error,
      onClosePressed: () {
        ref.read(requestNotifierProvider.notifier).clearError(query.state.key);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.taskId.isEmpty ? 'Create task' : 'Edit task'),
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
                onPressed: _canSave() ? _saveTask : null,
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

  /// Builds the form
  Widget _buildForm({required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextField(
            controller: _nameController,
            onChanged: (value) {
              setState(() {
                _task = _task.copyWith(name: value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Task name *',
              border: OutlineInputBorder(),
              hintText: 'Enter task name',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // Task information (if editing)
          if (widget.taskId.isNotEmpty && _task.id.isNotEmpty) ...[
            _buildTaskInfo(_task),
            const SizedBox(height: 24),
          ],

          // Save button
          ElevatedButton(
            onPressed: _canSave() && !isLoading ? _saveTask : null,
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
                : Text(widget.taskId.isEmpty ? 'Create task' : 'Save changes'),
          ),
        ],
      ),
    );
  }

  /// Builds task information
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

  /// Builds an info row
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

  /// Formats date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Checks if task can be saved
  bool _canSave() {
    return _task.name.trim().isNotEmpty;
  }

  /// Saves the task
  void _saveTask() async {
    if (!_canSave()) return;

    final taskNotifier = ref.read(taskNotifierProvider.notifier);

    final taskData = _task.copyWith(name: _task.name.trim());

    if (widget.taskId.isEmpty) {
      // Creating new task
      await taskNotifier.createTask(taskData);

      // Show success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Updating existing task
      final updatedTask = _task.copyWith(name: _task.name.trim());
      await taskNotifier.updateTask(updatedTask);

      // Show success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    // Go back
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
