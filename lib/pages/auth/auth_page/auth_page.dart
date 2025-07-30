import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_todo/app/store/app_slice/app_slice.dart';
import 'package:flutter_todo/app/store/auth_slice/auth_slice.dart';
import 'package:flutter_todo/shared/get_it/get_it.dart';
import 'widgets/widgets.dart';

/// Страница аутентификации с возможностью входа и регистрации
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthPageViewModel>(
      converter: (store) => AuthPageViewModel.fromStore(store),
      builder: (context, viewModel) {
        // Проверяем аутентификацию при изменении состояния
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.isAuthenticated && !_hasRedirected) {
            _hasRedirected = true;
            _redirectToHome();
          }
        });

        return Scaffold(body: _buildContent());
      },
    );
  }

  /// Редирект на главную страницу
  void _redirectToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  /// Строим основной контент
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Заголовок
            _buildHeader(),

            // Табы для переключения между входом и регистрацией
            _buildTabBar(),

            // Контент табов
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SignInForm(tabController: _tabController),
                  SignUpForm(tabController: _tabController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Строим заголовок
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Логотип
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 35,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),

          // Название приложения
          const Text(
            'Todo App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          // Подзаголовок
          const Text(
            'Manage your tasks effectively',
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Строим табы
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorWeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.zero,
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Registration'),
        ],
      ),
    );
  }
}

/// ViewModel для AuthPage
class AuthPageViewModel {
  final bool isAuthenticated;

  AuthPageViewModel({required this.isAuthenticated});

  factory AuthPageViewModel.fromStore(Store<AppState> store) {
    final authSlice = getIt.get<AuthSlice>();
    final isAuthenticated = authSlice.isAuthenticated(store);

    return AuthPageViewModel(isAuthenticated: isAuthenticated);
  }
}
