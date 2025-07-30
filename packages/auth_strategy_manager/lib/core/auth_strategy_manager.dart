import 'strategy.dart';
import 'helpers/strategy_helper.dart';
import 'strategies/empty_strategy.dart';

class AuthStrategyManager {
  int strategiesCount = 0;
  Map<String, Strategy> _strategies = {};
  final StrategyHelper _helper = strategyHelper;
  final Strategy _emptyStrategy = EmptyStrategy();

  AuthStrategyManager([List<Strategy>? strategies]) {
    if (strategies != null) {
      strategiesCount = strategies.length;
      _strategies = {for (final s in strategies) s.name: s};
    }
  }

  Future<void> init() async {
    await _helper.init();
  }

  Strategy getStrategy() {
    final name = _helper.activeStrategyName;
    if (_strategies.length == 1) {
      return _strategies.values.first;
    }

    if (name == null || !_strategies.containsKey(name)) {
      return _emptyStrategy;
    }
    return _strategies[name]!;
  }

  Future<bool> checkAuth() async {
    final names = _strategies.keys.toList();
    if (names.isEmpty) return false;
    if (names.length == 1) {
      return await _strategies[names[0]]!.checkAuth();
    }
    final results = await Future.wait(
      names.map(
        (index) => _strategies[index]!.checkAuth().then(
          (value) => {'status': 'fulfilled', 'value': value},
        ),
      ),
    );

    for (int index = 0; index < results.length; index++) {
      final result = results[index];
      if (result['status'] == 'fulfilled' && result['value'] == true) {
        _helper.setActiveStrategyName(names[index]);
        return true;
      }
    }
    return false;
  }

  Future<void> setStrategies(List<Strategy> strategies) async {
    strategiesCount = strategies.length;
    _strategies = {for (final s in strategies) s.name: s};
  }

  void use(String strategyName) {
    _helper.setActiveStrategyName(strategyName);
  }

  Future<void> clear() async {
    final strategy = await getStrategy();
    strategy.clear();
    _helper.setActiveStrategyName(_emptyStrategy.name);
  }
}
