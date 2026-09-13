import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/util.dart';
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

class PartSortNotifier extends Notifier<PartSortOption> {
  static const _key = 'partSortOption';

  @override
  PartSortOption build() {
    _load();
    return PartSortOption.color;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_key);
    if (val == PartSortOption.type.name) {
      state = PartSortOption.type;
    } else if (val == PartSortOption.color.name) {
      state = PartSortOption.color;
    }
  }

  Future<void> set(PartSortOption option) async {
    state = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, option.name);
  }
}

final partSortProvider = NotifierProvider<PartSortNotifier, PartSortOption>(
  PartSortNotifier.new,
);
