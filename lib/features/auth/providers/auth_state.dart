import 'package:todo_models/todo_models.dart';

/// State for authentication feature
/// Loading and error states are managed by RequestNotifier
class AuthState {
  final bool isAuthenticated;
  final UserModel? currentUser;
  final String? token;

  const AuthState({this.isAuthenticated = false, this.currentUser, this.token});

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Copy with changes
  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? currentUser,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, currentUser: $currentUser, token: $token)';
  }
}
