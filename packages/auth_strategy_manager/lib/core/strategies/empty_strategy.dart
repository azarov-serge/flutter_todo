import '../helpers/strategy_helper.dart';
import '../strategy.dart';

class EmptyStrategy implements Strategy {
  final StrategyHelper _helper = strategyHelper;

  @override
  String get name => 'empty';

  @override
  String? get token => null;

  @override
  bool get isAuthenticated => false;

  @override
  Future<bool> checkAuth() async => false;

  @override
  Future<T> signIn<T, D>([D? config]) async => false as T;

  @override
  Future<T> signUp<T, D>([D? config]) async => false as T;

  @override
  Future<void> signOut() async => _helper.clearStorage();

  @override
  Future<void> refreshToken<T>([T? args]) async {}

  @override
  void clear() => _helper.clearStorage();
}
