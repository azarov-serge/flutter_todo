import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/fetch_slice/fetch_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:todo_models/todo_models.dart';

import 'state/auth_state.dart';
import 'actions/auth_actions.dart';
import 'reducer/auth_reducer.dart';
import 'thunks/auth_thunks.dart';
import 'selectors/auth_selectors.dart';

/// Класс для управления аутентификацией
class AuthSlice {
  // Экземпляр AuthThunks с стратегией
  late final AuthThunks thunks;
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();

  AuthSlice() {
    thunks = AuthThunks();
  }

  /// Получить статус аутентификации
  bool isAuthenticated(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.isAuthenticated(authState);
  }

  /// Получить текущего пользователя
  UserModel? getCurrentUser(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.getCurrentUser(authState);
  }

  /// Получить токен
  String? getToken(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.getToken(authState);
  }

  /// Получить ID текущего пользователя
  String? getCurrentUserId(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.getCurrentUserId(authState);
  }

  /// Получить логин текущего пользователя
  String? getCurrentUserLogin(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.getCurrentUserLogin(authState);
  }

  /// Проверить, есть ли токен
  bool hasToken(Store<AppState> store) {
    final authState = store.state.authState;
    return AuthSelectors.hasToken(authState);
  }

  /// Очистить ошибку аутентификации
  void clearError(Store<AppState> store) {
    store.dispatch(thunks.clearError());
  }

  /// Сбросить состояние аутентификации
  void resetState(Store<AppState> store) {
    store.dispatch(thunks.resetState());
  }

  /// Получить статус входа в систему
  QueryStatus signInStatus(Store<AppState> store) {
    final fetchState = store.state.fetchState;
    final query = thunks.signInQuery;
    return fetchState.status(query.state.key);
  }

  /// Сбросить ошибку входа в систему
  void resetSignInError(Store<AppState> store) {
    final query = thunks.signInQuery.copyWith(
      thunks.signInQuery.state.copyWith(data: null),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Получить статус регистрации
  QueryStatus signUpStatus(Store<AppState> store) {
    final fetchState = store.state.fetchState;
    final query = thunks.signUpQuery;
    return fetchState.status(query.state.key);
  }

  /// Сбросить ошибку регистрации
  void resetSignUpError(Store<AppState> store) {
    final query = thunks.signUpQuery.copyWith(
      thunks.signUpQuery.state.copyWith(data: null),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Получить статус проверки аутентификации
  QueryStatus checkAuthStatus(Store<AppState> store) {
    final fetchState = store.state.fetchState;
    final query = thunks.checkAuthQuery;
    return fetchState.status(query.state.key);
  }

  /// Сбросить ошибку проверки аутентификации
  void resetCheckAuthError(Store<AppState> store) {
    final query = thunks.checkAuthQuery.copyWith(
      thunks.checkAuthQuery.state.copyWith(data: null),
    );
    fetchSlice.actions.clearError(store, query.state.key);
  }

  /// Получить состояние аутентификации
  AuthState getState(Store<AppState> store) {
    return store.state.authState;
  }

  /// Получить редюсер
  Reducer<AuthState> get reducer => (AuthState state, dynamic action) {
    if (action is AuthAction) {
      return authReducer(state, action);
    }
    return state;
  };

  /// Получить начальное состояние
  AuthState get initialState => AuthState.initial;
}
