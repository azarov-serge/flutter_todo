import 'package:redux/redux.dart';
import 'package:todo_models/todo_models.dart';
import '../state/task_state.dart';
import '../actions/task_actions.dart';

/// Редюсер для обработки действий с задачами
Reducer<TaskState> taskReducer = (state, action) {
  if (action is SetTasksAction) {
    final taskMap = <String, TaskModel>{
      for (var task in action.tasks) task.id: task,
    };
    return state.copyWith(tasks: taskMap);
  }

  if (action is AddTaskAction) {
    final newTasks = <String, TaskModel>{
      ...state.tasks,
      action.task.id: action.task,
    };
    return state.copyWith(tasks: newTasks);
  }

  if (action is UpdateTaskAction) {
    final newTasks = <String, TaskModel>{
      ...state.tasks,
      action.task.id: action.task,
    };
    return state.copyWith(tasks: newTasks);
  }

  if (action is RemoveTaskAction) {
    final newTasks = <String, TaskModel>{...state.tasks};
    newTasks.remove(action.taskId);
    return state.copyWith(tasks: newTasks);
  }

  if (action is ClearTasksAction) {
    return state.copyWith(tasks: <String, TaskModel>{});
  }

  return state;
};
