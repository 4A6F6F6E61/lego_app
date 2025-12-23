import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';

@riverpod
class UserToken extends _$UserToken {
  final String key = "userToken";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async => _set(state, key, value);
  Future<void> clear() async => _clear(state, key);
}

@riverpod
class RebrickableApiKey extends _$RebrickableApiKey {
  final String key = "rebrickableApiKey";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async => _set(state, key, value);
  Future<void> clear() async => _clear(state, key);
}

@riverpod
class BricksetApiKey extends _$BricksetApiKey {
  final String key = "bricksetApiKey";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async => _set(state, key, value);
  Future<void> clear() async => _clear(state, key);
}

Future<String?> _build(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> _set(AsyncValue<String?> state, String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
  state = AsyncValue.data(value);
}

Future<void> _clear(AsyncValue<String?> state, String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
  state = const AsyncValue.data(null);
}
