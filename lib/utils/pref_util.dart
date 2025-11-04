import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  static Future<String> read(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key) ?? "";
  }

  static write(String key, String data) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(key, data);
  }

  static writeBool(String key, bool data) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool(key, data);
  }

  static Future<bool?> readBool(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static writeInt(String key, int data) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt(key, data);
  }
}
