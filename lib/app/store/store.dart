import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:get_it/get_it.dart';
import 'app_slice/app_slice.dart';

/// Создание store приложения
Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: const AppState(),
    middleware: [thunkMiddleware],
  );
}

/// Глобальный store (для совместимости с get_it)
Store<AppState> get store => GetIt.instance<Store<AppState>>();
