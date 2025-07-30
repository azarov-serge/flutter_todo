import '../state/auth_state.dart';
import '../actions/auth_actions.dart';

/// Редюсер для аутентификации
AuthState authReducer(AuthState state, AuthAction action) {
  if (action is SetUserAction) {
    return state.copyWith(currentUser: action.user, isAuthenticated: true);
  }

  if (action is SetTokenAction) {
    return state.copyWith(token: action.token);
  }

  if (action is SetAuthenticatedAction) {
    return state.copyWith(isAuthenticated: action.isAuthenticated);
  }

  if (action is SignOutAction) {
    return state.copyWith(
      currentUser: null,
      isAuthenticated: false,
      token: null,
    );
  }

  if (action is ResetAuthStateAction) {
    return AuthState.initial;
  }

  return state;
}
