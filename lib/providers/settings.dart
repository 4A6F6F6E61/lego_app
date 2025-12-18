import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';

@riverpod
class UserToken extends _$UserToken {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> set(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    state = AsyncValue.data(token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    state = const AsyncValue.data(null);
  }
}

@riverpod
class RebrickableApiKey extends _$RebrickableApiKey {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('rebrickableApiKey');
  }

  Future<void> set(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rebrickableApiKey', apiKey);
    state = AsyncValue.data(apiKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rebrickableApiKey');
    state = const AsyncValue.data(null);
  }
}
