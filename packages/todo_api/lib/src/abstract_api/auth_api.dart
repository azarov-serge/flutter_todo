import 'package:queries/queries.dart';
import 'package:todo_models/todo_models.dart';

abstract class AuthApi {
  /// Return userId or null
  Future<String?> checkAuth(Query<Null> query);

  /// Return userId
  Future<String> signIn(Query<SignInData> query);

  /// Return userId
  Future<String> signUp(Query<SignUpData> query);

  Future<void> signOut(Query<String> query);

  /// Refresh token
  Future<void> updateRefreshToken();
}
