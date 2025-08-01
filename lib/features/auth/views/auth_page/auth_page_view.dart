import 'package:flutter/material.dart';
import 'package:flutter_todo/features/auth/views/auth_page/widgets/widgets.dart';
import 'package:flutter_todo/features/auth/views/auth_page/auth_page_view_model.dart';

/// Dumb UI component that only handles presentation
/// Business logic is handled by AuthPage
class AuthPageView extends StatefulWidget {
  const AuthPageView({super.key});

  @override
  State<AuthPageView> createState() => _AuthPageViewState();
}

class _AuthPageViewState extends State<AuthPageView>
    with TickerProviderStateMixin {
  late AuthPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthPageViewModel();
    _viewModel.initializeTabController(this);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // App title
              const Text(
                'Todo App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Manage your tasks efficiently',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _viewModel.tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tab bar view
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: TabBarView(
                    controller: _viewModel.tabController,
                    children: [
                      SignInForm(tabController: _viewModel.tabController),
                      SignUpForm(tabController: _viewModel.tabController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
