import 'package:redux/redux.dart';
import 'package:flutter_todo/app/store/app_slice/app_slice.dart';

import 'state/fetch_state.dart';
import 'actions/fetch_actions.dart';
import 'reducer/fetch_reducer.dart';
import 'thunks/fetch_thunks.dart';

/// Класс для управления fetch состоянием
class FetchSlice {
  /// Экземпляр FetchActions
  final FetchActions actions = FetchActions();

  /// Экземпляр FetchThunks
  final FetchThunks thunks = FetchThunks();

  /// Получить начальное состояние
  FetchState get initialState => FetchState.initial();

  /// Получить редюсер
  Reducer<FetchState> get reducer => fetchReducer;

  /// Получить state
  FetchState getState(Store<AppState> store) {
    return store.state.fetchState;
  }
}
