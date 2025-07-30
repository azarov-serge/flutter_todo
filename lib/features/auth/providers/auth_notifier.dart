import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_models/todo_models.dart';
import 'package:auth_strategy_manager/auth_strategy_manager.dart';
import 'package:todo_api/todo_api.dart';

import 'auth_state.dart';
import 'auth_query.dart';
import '../../../shared/providers/request_provider.dart';
import '../../categories/providers/category_notifier.dart';

/// Notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthStrategyManager _authStrategyManager;
  final RequestNotifier _requestNotifier;
  final CategoryNotifier? _categoryNotifier; // Optional dependency

  AuthNotifier(
    this._authStrategyManager,
    this._requestNotifier, [
    this._categoryNotifier,
  ]) : super(AuthState.initial());

  /// Sign in user
  Future<void> signIn(SignInData signInData) async {
    final query = AuthQuery.signIn();
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Get strategy and sign in
      final strategy = _authStrategyManager.getStrategy();
      final user = await strategy.signIn<UserModel, SignInData>(signInData);

      // Update state on success
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: user,
        token: strategy.token,
      );

      // Notify CategoryNotifier about user change
      _categoryNotifier?.updateUserId(user.id);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      // Update state on error
      state = state.copyWith(isAuthenticated: false);

      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Sign up user
  Future<void> signUp(SignUpData signUpData) async {
    final query = AuthQuery.signUp();
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Get strategy and sign up
      final strategy = _authStrategyManager.getStrategy();
      final user = await strategy.signUp<UserModel, SignUpData>(signUpData);

      // Update state on success
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: user,
        token: strategy.token,
      );

      // Notify CategoryNotifier about user change
      _categoryNotifier?.updateUserId(user.id);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      // Update state on error
      state = state.copyWith(isAuthenticated: false);

      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Check authentication
  Future<void> checkAuth() async {
    final query = AuthQuery.checkAuth();
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Get strategy and check auth
      final strategy = _authStrategyManager.getStrategy();
      final isAuthenticated = await strategy.checkAuth();

      if (isAuthenticated) {
        // Get user data if authenticated
        final userApi = GetIt.instance.get<UserApi>();
        final userId = strategy.token;
        if (userId != null) {
          final user = await userApi.fetchItem(AuthQuery.fetchUser(userId));

          state = state.copyWith(
            isAuthenticated: true,
            currentUser: user,
            token: strategy.token,
          );

          // Notify CategoryNotifier about user change
          _categoryNotifier?.updateUserId(user.id);
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          currentUser: null,
          token: null,
        );

        // Notify CategoryNotifier about user logout
        _categoryNotifier?.updateUserId(null);
      }

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      // Update state on error
      state = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        token: null,
      );

      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    final query = AuthQuery.signOut();
    final requestKey = query.state.key;

    try {
      // Set loading state
      _requestNotifier.setLoading(requestKey);

      // Get strategy and sign out
      final strategy = _authStrategyManager.getStrategy();
      await strategy.signOut();

      // Update state
      state = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        token: null,
      );

      // Notify CategoryNotifier about user logout
      _categoryNotifier?.updateUserId(null);

      _requestNotifier.setSuccess(requestKey);
    } catch (e) {
      // Update state on error
      state = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        token: null,
      );

      _requestNotifier.setError(requestKey, e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = AuthState.initial();
  }
}

/// Provider for auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authStrategyManager = GetIt.instance.get<AuthStrategyManager>();
  final requestNotifier = ref.watch(requestNotifierProvider.notifier);
  final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);
  return AuthNotifier(authStrategyManager, requestNotifier, categoryNotifier);
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authNotifierProvider).isAuthenticated,
);

/// Provider for current user
final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authNotifierProvider).currentUser,
);
