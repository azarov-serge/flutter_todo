import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:redux/redux.dart';

import '../actions/fetch_actions.dart';

/// Класс для управления fetch thunks
class FetchThunks {
  /// Универсальный метод для выполнения запроса
  Future<void> request(
    Store<AppState> store, {
    required String key,
    required Future<void> Function() operation,
  }) async {
    store.dispatch(FetchStartAction(key));

    try {
      await operation();
      store.dispatch(FetchSuccessAction(key));
    } catch (error) {
      store.dispatch(FetchFailureAction(key, error.toString()));
    }
  }
}
