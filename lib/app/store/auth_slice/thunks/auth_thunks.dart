import 'package:flutter_todo/app/store/fetch_slice/fetch_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:todo_api/todo_api.dart';
import 'package:todo_models/todo_models.dart';
import 'package:auth_strategy_manager/auth_strategy_manager.dart';

import '../actions/auth_actions.dart';
import '../../app_slice/app_slice.dart';

/// Thunks для аутентификации
class AuthThunks {
  final FetchSlice fetchSlice = getIt.get<FetchSlice>();
  final AuthStrategyManager authStrategyManager = getIt
      .get<AuthStrategyManager>();
  final UserApi userApi = getIt.get<UserApi>();

  /// Query для входа в систему
  Query<SignInData> get signInQuery => Query<SignInData>(
    state: QueryState(baseUrl: '/auth/signin', method: 'POST'),
  );

  /// Query для регистрации
  Query<SignUpData> get signUpQuery => Query<SignUpData>(
    state: QueryState(baseUrl: '/auth/signup', method: 'POST'),
  );

  /// Query для проверки аутентификации
  Query<Null> get checkAuthQuery => Query<Null>(
    state: QueryState(baseUrl: '/auth/check', method: 'GET'),
  );

  /// Query для выхода из системы
  Query<String> get signOutQuery => Query<String>(
    state: QueryState(baseUrl: '/auth/signout', method: 'POST'),
  );

  /// Thunk для входа в систему
  ThunkAction<AppState> signIn(SignInData signInData) {
    return (Store<AppState> store) async {
      // Создаем query с данными для входа
      final query = signInQuery.copyWith(
        signInQuery.state.copyWith(data: signInData),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          try {
            final strategy = authStrategyManager.getStrategy();

            // Вызываем стратегию аутентификации
            final user = await strategy.signIn<UserModel, Query<SignInData>>(
              query,
            );

            // Диспатчим действия
            store.dispatch(SetUserAction(user));
            store.dispatch(SetTokenAction(strategy.token ?? ''));
            store.dispatch(SetAuthenticatedAction(true));
            store.dispatch(ClearAuthErrorAction());
          } catch (e) {
            store.dispatch(SetAuthenticatedAction(false));

            rethrow;
          }
        },
      );
    };
  }

  /// Thunk для регистрации
  ThunkAction<AppState> signUp(SignUpData signUpData) {
    return (Store<AppState> store) async {
      // Создаем query с данными для входа
      final query = signUpQuery.copyWith(
        signUpQuery.state.copyWith(data: signUpData),
      );

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          try {
            final strategy = authStrategyManager.getStrategy();
            // Вызываем стратегию аутентификации
            final user = await strategy.signUp<UserModel, Query<SignUpData>>(
              query,
            );

            // Диспатчим действия
            store.dispatch(SetUserAction(user));
            store.dispatch(SetTokenAction(strategy.token ?? ''));
            store.dispatch(SetAuthenticatedAction(true));
            store.dispatch(ClearAuthErrorAction());
          } catch (e) {
            store.dispatch(SetAuthErrorAction(e.toString()));
            store.dispatch(SetAuthenticatedAction(false));
            rethrow;
          }
        },
      );
    };
  }

  /// Thunk для проверки аутентификации
  ThunkAction<AppState> checkAuth() {
    return (Store<AppState> store) async {
      // Создаем query с данными для входа
      final query = checkAuthQuery;

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          try {
            final strategy = authStrategyManager.getStrategy();
            // Вызываем стратегию аутентификации
            final isAuthenticated = await strategy.checkAuth();

            if (isAuthenticated) {
              final userId = strategy.token;
              final user = await userApi.fetchItem(
                Query<String>(
                  state: QueryState(baseUrl: '/users/$userId', method: 'GET'),
                ),
              );
              store.dispatch(SetUserAction(user));
            }

            // Диспатчим действия
            store.dispatch(SetAuthenticatedAction(isAuthenticated));
            store.dispatch(ClearAuthErrorAction());
          } catch (e) {
            store.dispatch(SetAuthErrorAction(e.toString()));
            store.dispatch(SetAuthenticatedAction(false));
            rethrow;
          }
        },
      );
    };
  }

  /// Thunk для выхода из системы
  ThunkAction<AppState> signOut() {
    return (Store<AppState> store) async {
      // Создаем query с данными для входа
      final query = signOutQuery;

      await fetchSlice.thunks.request(
        store,
        key: query.state.key,
        operation: () async {
          try {
            final strategy = authStrategyManager.getStrategy();
            // Вызываем стратегию аутентификации
            await strategy.signOut();

            // Диспатчим действия
            store.dispatch(SetAuthenticatedAction(false));
            store.dispatch(ClearAuthErrorAction());
          } catch (e) {
            store.dispatch(SetAuthErrorAction(e.toString()));
            store.dispatch(SetAuthenticatedAction(false));
            rethrow;
          }
        },
      );
    };
  }

  /// Thunk для обновления токена
  ThunkAction<AppState> refreshToken() {
    return (Store<AppState> store) async {
      try {
        // Вызываем стратегию аутентификации
        final strategy = authStrategyManager.getStrategy();
        await strategy.refreshToken();

        // Обновляем токен в состоянии
        store.dispatch(SetTokenAction(strategy.token ?? ''));
        store.dispatch(ClearAuthErrorAction());
      } catch (e) {
        store.dispatch(SetAuthErrorAction(e.toString()));
        // Если не удалось обновить токен, выходим из системы
        store.dispatch(SignOutAction());
      }
    };
  }

  /// Thunk для очистки ошибки
  ThunkAction<AppState> clearError() {
    return (Store<AppState> store) async {
      store.dispatch(ClearAuthErrorAction());
    };
  }

  /// Thunk для сброса состояния аутентификации
  ThunkAction<AppState> resetState() {
    return (Store<AppState> store) async {
      final strategy = authStrategyManager.getStrategy();
      strategy.clear();
      store.dispatch(ResetAuthStateAction());
    };
  }
}
