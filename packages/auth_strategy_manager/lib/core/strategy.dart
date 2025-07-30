abstract class Strategy {
  String get name;
  String? get token;
  bool get isAuthenticated;

  Future<bool> checkAuth();
  Future<T> signIn<T, D>([D? config]);
  Future<T> signUp<T, D>([D? config]);
  Future<void> signOut();
  Future<void> refreshToken<T>([T? args]);
  void clear();
}
