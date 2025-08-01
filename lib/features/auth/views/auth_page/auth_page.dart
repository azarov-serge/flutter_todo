import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/features/auth/providers/auth_notifier.dart';
import 'package:flutter_todo/features/auth/providers/auth_query.dart';
import 'package:flutter_todo/shared/providers/request_provider.dart';
import 'package:flutter_todo/shared/ui_kit/splash_screen/splash_screen.dart';
import 'package:flutter_todo/app/routes.dart';
import 'package:flutter_todo/features/auth/views/auth_page/auth_page_view.dart';

/// Smart wrapper that handles authentication logic and redirects
/// Separates business logic from UI presentation
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _hasRedirected = false;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final checkAuthQuery = AuthQuery.checkAuth();
    final requestState = ref.watch(
      requestStateProvider(checkAuthQuery.state.key),
    );
    final isLoading = requestState.isLoading;

    // Show splash screen during authentication check
    if (isLoading) {
      return const SplashScreen(message: 'Checking authentication...');
    }

    // Redirect to home if authenticated
    if (isAuthenticated && !_hasRedirected) {
      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      });
      return const SplashScreen(message: 'Redirecting to home...');
    }

    // Reset redirect flag when not authenticated
    if (!isAuthenticated) {
      _hasRedirected = false;
    }

    // Show auth page if not authenticated
    return const AuthPageView();
  }
}
