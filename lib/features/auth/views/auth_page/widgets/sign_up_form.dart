import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_models/todo_models.dart';

import '../../../providers/auth_query.dart';
import '../../../providers/auth_notifier.dart';
import '../../../../../shared/providers/request_provider.dart';
import '../../../../../shared/ui_kit/error_wrapper/error_wrapper.dart';

/// Sign up form widget
class SignUpForm extends StatefulWidget {
  final TabController tabController;

  const SignUpForm({super.key, required this.tabController});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  // Validation states
  String? _loginError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final requestState = ref.watch(
          requestStateProvider(AuthQuery.signUp().state.key),
        );

        return ErrorWrapper(
          error: requestState.error,
          onClosePressed: () {
            // Clear error when dialog is closed
            ref
                .read(requestNotifierProvider.notifier)
                .clearError('auth_signup');
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Sign up form
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form header
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Create a new account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Username field
                      TextField(
                        controller: _loginController,
                        onChanged: (value) => _validateLogin(value),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabled: !requestState.isLoading,
                          errorText: _loginError,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        onChanged: (value) => _validatePassword(value),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabled: !requestState.isLoading,
                          errorText: _passwordError,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password confirmation field
                      TextField(
                        controller: _confirmPasswordController,
                        onChanged: (value) => _validateConfirmPassword(value),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabled: !requestState.isLoading,
                          errorText: _confirmPasswordError,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign up button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: requestState.isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: requestState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Link to sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: requestState.isLoading
                          ? null
                          : () {
                              widget.tabController.animateTo(0);
                            },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sign up to the system
  void _signUp() {
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate all fields
    _validateLogin(login);
    _validatePassword(password);
    _validateConfirmPassword(confirmPassword);

    // Check if there are validation errors
    if (_loginError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      _showValidationError('Please fix the validation errors');
      return;
    }

    // Create sign up data
    final signUpData = SignUpData(login: login, password: password);

    // Perform sign up through Riverpod
    final container = ProviderScope.containerOf(context);
    container.read(authNotifierProvider.notifier).signUp(signUpData);
  }

  /// Show validation error
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Validate login
  void _validateLogin(String value) {
    setState(() {
      if (value.isEmpty) {
        _loginError = 'Username is required';
      } else if (value.length < 3) {
        _loginError = 'Username must be at least 3 characters';
      } else {
        _loginError = null;
      }
    });
  }

  /// Validate password
  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
      // Also validate password confirmation
      _validateConfirmPassword(_confirmPasswordController.text);
    });
  }

  /// Validate password confirmation
  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }
}
