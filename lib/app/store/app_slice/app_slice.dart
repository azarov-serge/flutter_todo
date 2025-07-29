import 'package:redux/redux.dart';
import '../fetch_slice/state/fetch_state.dart';
import '../fetch_slice/actions/fetch_actions.dart';
import '../fetch_slice/reducer/fetch_reducer.dart';
import '../task_slice/state/task_state.dart';
import '../task_slice/actions/task_actions.dart';
import '../task_slice/reducer/task_reducer.dart';
import '../category_slice/state/category_state.dart';
import '../category_slice/actions/category_actions.dart';
import '../category_slice/reducer/category_reducer.dart';

/// Основное состояние приложения
class AppState {
  final FetchState fetchState;
  final TaskState taskState;
  final CategoryState categoryState;

  const AppState({
    this.fetchState = const FetchState(),
    this.taskState = const TaskState(),
    this.categoryState = const CategoryState(),
  });

  /// Создание копии с изменениями
  AppState copyWith({
    FetchState? fetchState,
    TaskState? taskState,
    CategoryState? categoryState,
  }) {
    return AppState(
      fetchState: fetchState ?? this.fetchState,
      taskState: taskState ?? this.taskState,
      categoryState: categoryState ?? this.categoryState,
    );
  }

  /// Создание пустого состояния
  factory AppState.initial() => const AppState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.fetchState == fetchState &&
        other.taskState == taskState &&
        other.categoryState == categoryState;
  }

  @override
  int get hashCode => Object.hash(fetchState, taskState, categoryState);

  @override
  String toString() =>
      'AppState(fetchState: $fetchState, taskState: $taskState, categoryState: $categoryState)';
}

/// Основной редюсер приложения
Reducer<AppState> appReducer = combineReducers<AppState>([
  TypedReducer<AppState, FetchAction>(_fetchReducer),
  TypedReducer<AppState, TaskAction>(_taskReducer),
  TypedReducer<AppState, CategoryAction>(_categoryReducer),
]);

/// Редюсер для обработки fetch actions
AppState _fetchReducer(AppState state, FetchAction action) {
  return state.copyWith(fetchState: fetchReducer(state.fetchState, action));
}

/// Редюсер для обработки task actions
AppState _taskReducer(AppState state, TaskAction action) {
  return state.copyWith(taskState: taskReducer(state.taskState, action));
}

/// Редюсер для обработки category actions
AppState _categoryReducer(AppState state, CategoryAction action) {
  return state.copyWith(
    categoryState: categoryReducer(state.categoryState, action),
  );
}
