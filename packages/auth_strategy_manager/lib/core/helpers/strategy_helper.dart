import 'package:shared_preferences/shared_preferences.dart';

class StrategyHelper {
  static const String _typeKey = 'authStrategyName';

  String? _activeStrategyName;
  String _token = '';

  /// Token storage key (can be set via constructor)
  String tokenKey;

  SharedPreferences? _prefs;

  StrategyHelper({this.tokenKey = 'access'});

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final instance = _prefs;
    if (instance == null) {
      throw Exception('SharedPreferences is not inited');
    }

    return instance;
  }

  String? get activeStrategyName {
    return _activeStrategyName;
  }

  String get token {
    return _token;
  }

  Future<bool> setActiveStrategyName(String name) {
    _activeStrategyName = name;
    if (name.isEmpty) {
      return prefs.remove(_typeKey);
    }

    return prefs.setString(_typeKey, name);
  }

  Future<bool> setToken(String token) {
    _token = token;

    return prefs.setString(tokenKey, token);
  }

  Future<bool> clearStorage() {
    _activeStrategyName = null;
    return prefs.remove(_typeKey);
  }

  Future<bool> reset() {
    return clearStorage();
  }
}

final strategyHelper = StrategyHelper();
