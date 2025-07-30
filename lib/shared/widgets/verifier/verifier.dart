import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/auth_slice/auth_slice.dart';
import 'package:flutter_todo/app/routes.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:flutter_todo/shared/ui_kit/splash_screen/splash_screen.dart';
import 'package:todo_models/todo_models.dart';

/// Виджет для проверки авторизации пользователя
/// Если пользователь авторизован - показывает child
/// Если не авторизован - редиректит на страницу авторизации
class Verifier extends StatefulWidget {
  final Widget child;

  const Verifier({super.key, required this.child});

  @override
  State<Verifier> createState() => _VerifierState();
}

class _VerifierState extends State<Verifier> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Проверка авторизации
  void _checkAuth() async {
    final authSlice = getIt.get<AuthSlice>();
    authSlice.thunks.checkAuth();

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, VerifierViewModel>(
      converter: (store) => VerifierViewModel.fromStore(store),
      builder: (context, vm) {
        // Показываем SplashScreen во время проверки
        if (_isChecking) {
          return SplashScreen(message: 'Verifying authentication...');
        }

        // Если пользователь авторизован, показываем child
        if (vm.isAuthenticated) {
          return widget.child;
        }

        // Если пользователь не авторизован, редиректим на auth page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToAuth();
        });

        // Показываем SplashScreen во время редиректа
        return SplashScreen(message: 'Redirecting to login...');
      },
    );
  }

  /// Навигация на страницу авторизации
  void _navigateToAuth() {
    try {
      // Сначала пробуем локальную навигацию
      final navigator = Navigator.maybeOf(context);
      if (navigator != null) {
        navigator.pushReplacementNamed(AppRoutes.auth);
        return;
      }

      // Если локальная навигация недоступна, используем глобальный ключ
      _navigateWithGlobalKey();
    } catch (e) {
      _navigateWithGlobalKey();
    }
  }

  /// Навигация с использованием глобального ключа
  void _navigateWithGlobalKey() {
    try {
      if (getIt.isRegistered<GlobalKey<NavigatorState>>()) {
        final navigatorKey = getIt.get<GlobalKey<NavigatorState>>();
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushReplacementNamed(AppRoutes.auth);
          return;
        }
      }

      // Если глобальный ключ недоступен, пробуем с задержкой
      _retryNavigationWithDelay();
    } catch (e) {
      _retryNavigationWithDelay();
    }
  }

  /// Повторная попытка навигации с задержкой
  void _retryNavigationWithDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _navigateToAuth();
      }
    });
  }
}

/// ViewModel для Verifier виджета
class VerifierViewModel {
  final UserModel? currentUser;
  final bool isAuthenticated;
  final String? token;
  final String? error;
  final bool hasError;

  VerifierViewModel({
    required this.currentUser,
    required this.isAuthenticated,
    required this.token,
    required this.error,
    required this.hasError,
  });

  factory VerifierViewModel.fromStore(Store<AppState> store) {
    final authSlice = getIt.get<AuthSlice>();
    final authStatus = authSlice.checkAuthStatus(store);

    return VerifierViewModel(
      currentUser: authSlice.getState(store).currentUser,
      isAuthenticated: authSlice.getState(store).isAuthenticated,
      token: authSlice.getState(store).token,
      error: authStatus.error,
      hasError: authStatus.error.isNotEmpty,
    );
  }
}
