import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:todo_models/todo_models.dart';

import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/auth_slice/auth_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'package:flutter_todo/shared/ui_kit/error_wrapper/error_wrapper.dart';

/// Виджет формы регистрации
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

  // Состояния для валидации
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
    return StoreConnector<AppState, SignUpFormViewModel>(
      converter: (store) => SignUpFormViewModel.fromStore(store),
      builder: (context, viewModel) {
        return ErrorWrapper(
          error: viewModel.error,
          onClosePressed: () {
            // Clear error when dialog is closed
            final store = StoreProvider.of<AppState>(context, listen: false);
            final authSlice = getIt.get<AuthSlice>();
            authSlice.resetSignUpError(store);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Форма регистрации
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign up for a new account',
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
                        enabled: !viewModel.isFetching,
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
                        enabled: !viewModel.isFetching,
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
                      const SizedBox(height: 12),

                      // Поле подтверждения пароля
                      TextField(
                        controller: _confirmPasswordController,
                        enabled: !viewModel.isFetching,
                        obscureText: true,
                        onChanged: (value) => _validateConfirmPassword(value),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
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
                          errorText: _confirmPasswordError,
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Кнопка регистрации
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: viewModel.isFetching ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isFetching
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

                // Ссылка на вход
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: viewModel.isFetching
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

  /// Регистрация в системе
  void _signUp() {
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Запускаем валидацию всех полей
    _validateLogin(login);
    _validatePassword(password);
    _validateConfirmPassword(confirmPassword);

    // Проверяем, есть ли ошибки валидации
    if (_loginError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      _showValidationError('Please fix the validation errors');
      return;
    }

    // Создаем данные для регистрации
    final signUpData = SignUpData(login: login, password: password);

    // Выполняем регистрацию через Redux с fetch_slice
    final store = StoreProvider.of<AppState>(context, listen: false);
    final authSlice = getIt.get<AuthSlice>();
    store.dispatch(authSlice.thunks.signUp(signUpData));
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
      // Также валидируем подтверждение пароля
      _validateConfirmPassword(_confirmPasswordController.text);
    });
  }

  /// Валидация подтверждения пароля
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

/// ViewModel для SignUpForm
class SignUpFormViewModel {
  final bool isFetching;
  final String? error;
  final bool hasError;

  SignUpFormViewModel({
    required this.isFetching,
    required this.error,
    required this.hasError,
  });

  factory SignUpFormViewModel.fromStore(Store<AppState> store) {
    final authSlice = getIt.get<AuthSlice>();
    final signUpStatus = authSlice.signUpStatus(store);

    return SignUpFormViewModel(
      isFetching: signUpStatus.isFetching,
      error: signUpStatus.error,
      hasError: signUpStatus.error.isNotEmpty,
    );
  }
}
