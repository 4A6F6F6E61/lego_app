import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Settings._();

  static late String? userToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
  }

  static Future<void> setUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    userToken = token;
  }

  static Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    userToken = null;
  }
}
