import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_models/todo_models.dart';

import '../../../../../shared/providers/query_factory.dart';
import '../../../providers/auth_notifier.dart';
import '../../../../../shared/providers/request_provider.dart';
import '../../../../../shared/ui_kit/error_wrapper/error_wrapper.dart';

/// Виджет формы входа
class SignInForm extends StatefulWidget {
  final TabController tabController;

  const SignInForm({super.key, required this.tabController});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  late TextEditingController _loginController;
  late TextEditingController _passwordController;

  // Состояния для валидации
  String? _loginError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final requestState = ref.watch(
          requestStateProvider(AuthQuery.signIn().state.key),
        );

        return ErrorWrapper(
          error: requestState.error,
          onClosePressed: () {
            // Clear error when dialog is closed
            ref
                .read(requestNotifierProvider.notifier)
                .clearError('auth_signin');
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Форма входа
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
                      // Заголовок формы
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Login to your account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Поле логина
                      TextField(
                        controller: _loginController,
                        enabled: !requestState.isLoading,
                        onChanged: (value) => _validateLogin(value),
                        decoration: InputDecoration(
                          labelText: 'Login',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                          errorText: _loginError,
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Поле пароля
                      TextField(
                        controller: _passwordController,
                        enabled: !requestState.isLoading,
                        obscureText: true,
                        onChanged: (value) => _validatePassword(value),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                          errorText: _passwordError,
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Кнопка входа
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: requestState.isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
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
                                  'Login',
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

                // Ссылка на регистрацию
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: requestState.isLoading
                          ? null
                          : () {
                              widget.tabController.animateTo(1);
                            },
                      child: const Text(
                        'Register',
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

  /// Вход в систему
  void _signIn() {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    // Запускаем валидацию всех полей
    _validateLogin(login);
    _validatePassword(password);

    // Проверяем, есть ли ошибки валидации
    if (_loginError != null || _passwordError != null) {
      _showValidationError('Please fix the validation errors');
      return;
    }

    // Создаем данные для входа
    final signInData = SignInData(login: login, password: password);

    // Выполняем вход через Riverpod
    final container = ProviderScope.containerOf(context);
    container.read(authNotifierProvider.notifier).signIn(signInData);
  }

  /// Показать ошибку валидации
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

  /// Валидация логина
  void _validateLogin(String value) {
    setState(() {
      if (value.isEmpty) {
        _loginError = 'Login is required';
      } else if (value.length < 3) {
        _loginError = 'Login must be at least 3 characters';
      } else {
        _loginError = null;
      }
    });
  }

  /// Валидация пароля
  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }
}
