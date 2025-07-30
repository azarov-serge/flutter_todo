import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/auth_query.dart';
import '../../../features/auth/views/auth_page/auth_page.dart';
import '../../../shared/providers/request_provider.dart';
import '../../../shared/ui_kit/ui_kit.dart';

/// Verifier widget for authentication verification
/// Shows loading indicator while checking authentication
/// Redirects to auth page if not authenticated
class Verifier extends ConsumerStatefulWidget {
  final Widget child;

  const Verifier({super.key, required this.child});

  @override
  ConsumerState<Verifier> createState() => _VerifierState();
}

class _VerifierState extends ConsumerState<Verifier> {
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    // Check authentication on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  /// Check authentication status
  Future<void> _checkAuth() async {
    if (!_hasCheckedAuth) {
      _hasCheckedAuth = true;

      await ref.read(authNotifierProvider.notifier).checkAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Get loading state from RequestNotifier using AuthQuery.checkAuth() key
    final checkAuthQuery = AuthQuery.checkAuth();
    final requestKey = checkAuthQuery.state.key;

    final requestState = ref.watch(requestStateProvider(requestKey));

    final isLoading = requestState.isLoading;
    // Show loading while checking authentication
    if (isLoading) {
      return const SplashScreen(
        message: 'Checking authentication...',
        spinnerSize: 28,
        spinnerColor: Colors.blue,
      );
    }

    // Show auth page if not authenticated
    if (!isAuthenticated) {
      return const AuthPage();
    }

    // Show child widget if authenticated
    return widget.child;
  }
}
