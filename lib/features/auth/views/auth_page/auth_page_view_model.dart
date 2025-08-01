import 'package:flutter/material.dart';

/// ViewModel for AuthPageView UI logic
/// Handles TabController and UI state management
class AuthPageViewModel extends ChangeNotifier {
  late TabController _tabController;

  TabController get tabController => _tabController;

  /// Initialize TabController
  void initializeTabController(TickerProvider vsync) {
    _tabController = TabController(length: 2, vsync: vsync);
    _tabController.addListener(() {
      notifyListeners();
    });
  }

  /// Get current tab index
  int get currentIndex => _tabController.index;

  /// Check if current tab is sign in
  bool get isSignInTab => currentIndex == 0;

  /// Check if current tab is sign up
  bool get isSignUpTab => currentIndex == 1;

  /// Switch to sign in tab
  void switchToSignIn() {
    _tabController.animateTo(0);
  }

  /// Switch to sign up tab
  void switchToSignUp() {
    _tabController.animateTo(1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
