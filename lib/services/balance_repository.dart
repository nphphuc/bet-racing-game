import 'package:shared_preferences/shared_preferences.dart';

abstract class BalanceStorage {
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
}

class SharedPreferencesBalanceStorage implements BalanceStorage {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<int?> getInt(String key) => _preferences.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);
}

class BalanceRepository {
  BalanceRepository({BalanceStorage? storage})
    : _storage = storage ?? SharedPreferencesBalanceStorage();

  static const initialBalance = 100;
  final BalanceStorage _storage;

  String _key(String username) => 'balance:${username.trim()}';

  Future<int> load(String username) async {
    return await _storage.getInt(_key(username)) ?? initialBalance;
  }

  Future<void> save(String username, int balance) async {
    await _storage.setInt(_key(username), balance);
  }
}
