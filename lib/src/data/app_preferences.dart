import 'package:shared_preferences/shared_preferences.dart';

abstract class IAppPreferences {
  Future<bool> setStringList(String key, List<String> list);
  Future<List<String>?> getStringList(String key);
}

class LocalAppPreferences implements IAppPreferences {
  LocalAppPreferences({SharedPreferences? sharedPreferences})
      : _preferences = sharedPreferences;

  late SharedPreferences? _preferences;

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      _preferences ??= await SharedPreferences.getInstance();

      return _preferences!.getStringList(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> list) async {
    try {
      _preferences ??= await SharedPreferences.getInstance();

      return await _preferences!.setStringList(key, list);
    } catch (e) {
      return false;
    }
  }
}
