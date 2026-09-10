import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class UserToken extends _$UserToken {
  final String key = "userToken";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async {
    await _set(key, value);
    state = AsyncValue.data(value);
  }
  Future<void> clear() async {
    await _clear(key);
    state = const AsyncValue.data(null);
  }
}

@Riverpod(keepAlive: true)
class RebrickableApiKey extends _$RebrickableApiKey {
  final String key = "rebrickableApiKey";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async {
    await _set(key, value);
    state = AsyncValue.data(value);
  }
  Future<void> clear() async {
    await _clear(key);
    state = const AsyncValue.data(null);
  }
}

@Riverpod(keepAlive: true)
class BricksetApiKey extends _$BricksetApiKey {
  final String key = "bricksetApiKey";
  @override
  Future<String?> build() async => _build(key);
  Future<void> set(String value) async {
    await _set(key, value);
    state = AsyncValue.data(value);
  }
  Future<void> clear() async {
    await _clear(key);
    state = const AsyncValue.data(null);
  }
}

Future<String?> _build(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> _set(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> _clear(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
