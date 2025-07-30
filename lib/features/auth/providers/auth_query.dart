import 'package:queries/queries.dart';

/// Query factory for authentication operations
class AuthQuery {
  /// Query for user sign in
  static Query<String> signIn() {
    return Query<String>(
      state: QueryState(baseUrl: '/auth/signin', method: 'POST'),
    );
  }

  /// Query for user sign up
  static Query<String> signUp() {
    return Query<String>(
      state: QueryState(baseUrl: '/auth/signup', method: 'POST'),
    );
  }

  /// Query for checking authentication status
  static Query<String> checkAuth() {
    return Query<String>(
      state: QueryState(baseUrl: '/auth/check', method: 'GET'),
    );
  }

  /// Query for user sign out
  static Query<String> signOut() {
    return Query<String>(
      state: QueryState(baseUrl: '/auth/signout', method: 'POST'),
    );
  }

  /// Query for fetching user data
  static Query<String> fetchUser(String userId) {
    return Query<String>(
      state: QueryState(baseUrl: '/user', method: 'GET', urlParam: userId),
    );
  }
}
