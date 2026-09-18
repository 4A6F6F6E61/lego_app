import 'dart:async';

import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_providers.g.dart';

@riverpod
Stream<List<LegoSet>> setsStream(Ref ref) {
  if (auth.currentUser == null) return Stream.value([]);

  return supabase
      .from('sets')
      .stream(primaryKey: ['id'])
      .order('set_num', ascending: true)
      .map((data) => data.map((json) => LegoSet.fromJson(json)).toList());
}

@riverpod
Stream<List<SetPart>> setPartsStream(Ref ref, String setId) {
  if (auth.currentUser == null) return Stream.value([]);

  return supabase
      .from('set_parts')
      .stream(primaryKey: ['id'])
      .eq('set_id', setId)
      .order('color_id', ascending: true)
      .map((data) {
        final result = data.map((json) => SetPart.fromJson(json)).toList();
        result.sort((a, b) {
          final colorCompare = a.colorId.compareTo(b.colorId);
          if (colorCompare != 0) return colorCompare;
          return a.partNum.compareTo(b.partNum);
        });
        return result;
      });
}

@riverpod
Future<List<SetPart>> setParts(Ref ref, String setId) async {
  if (auth.currentUser == null) return [];

  final response = await supabase
      .from('set_parts')
      .select()
      .eq('set_id', setId)
      .order('color_id', ascending: true)
      .order('part_num', ascending: true);

  return response.map((json) => SetPart.fromJson(json)).toList();
}

@riverpod
Future<List<SetPart>> allMissingParts(Ref ref) async {
  if (auth.currentUser == null) return [];

  final response = await supabase
      .from('set_parts')
      .select()
      .eq('user_id', auth.currentUser!.id)
      .eq('is_lost', true)
      .order('color_id', ascending: true)
      .order('part_num', ascending: true);

  return response.map((json) => SetPart.fromJson(json)).toList();
}

Future<List<SetPart>> fetchAllMissingParts() async {
  if (auth.currentUser == null) return [];
  final response = await supabase
      .from('set_parts')
      .select()
      .eq('user_id', auth.currentUser!.id)
      .eq('is_lost', true)
      .order('color_id', ascending: true)
      .order('part_num', ascending: true);

  return response.map((json) => SetPart.fromJson(json)).toList();
}

class PartSetMatch {
  final LegoSet set;
  final List<SetPart> parts;

  const PartSetMatch({
    required this.set,
    required this.parts,
  });

  int get totalQuantityNeeded =>
      parts.fold(0, (sum, p) => sum + p.quantityNeeded);
  int get totalQuantityFound =>
      parts.fold(0, (sum, p) => sum + p.quantityFound);
  bool get isFullyFound =>
      totalQuantityNeeded > 0 && totalQuantityFound >= totalQuantityNeeded;
}

@riverpod
Future<List<PartSetMatch>> matchingSetsForPart(Ref ref, String partNum) async {
  if (auth.currentUser == null || partNum.trim().isEmpty) return [];

  final cleaned = partNum.trim();

  final partsResponse = await supabase
      .from('set_parts')
      .select()
      .eq('user_id', auth.currentUser!.id)
      .ilike('part_num', cleaned)
      .order('color_id', ascending: true);

  final parts = (partsResponse as List)
      .map((json) => SetPart.fromJson(json as Map<String, dynamic>))
      .toList();
  if (parts.isEmpty) return [];

  final partsBySetId = <String, List<SetPart>>{};
  for (final part in parts) {
    partsBySetId.putIfAbsent(part.setId, () => []).add(part);
  }

  final setIds = partsBySetId.keys.toList();
  final setsResponse = await supabase
      .from('sets')
      .select()
      .inFilter('id', setIds);

  final sets = (setsResponse as List)
      .map((json) => LegoSet.fromJson(json as Map<String, dynamic>))
      .toList();

  final matches = <PartSetMatch>[];
  for (final legoSet in sets) {
    final setParts = partsBySetId[legoSet.id] ?? [];
    matches.add(PartSetMatch(set: legoSet, parts: setParts));
  }

  matches.sort((a, b) {
    final statusOrder = {
      LegoSetStatus.currentlyBuilding: 0,
      LegoSetStatus.backlog: 1,
      LegoSetStatus.built: 2,
    };
    final aOrder = statusOrder[a.set.status] ?? 99;
    final bOrder = statusOrder[b.set.status] ?? 99;
    if (aOrder != bOrder) return aOrder.compareTo(bOrder);
    return a.set.name.compareTo(b.set.name);
  });

  return matches;
}

@riverpod
Stream<LegoSet?> setStream(Ref ref, String setId) {
  if (auth.currentUser == null) return Stream.value(null);

  return supabase
      .from('sets')
      .stream(primaryKey: ['id'])
      .eq('id', setId)
      .map((data) => data.isNotEmpty ? LegoSet.fromJson(data.first) : null);
}

Future<void> updateSetStatus(String setId, LegoSetStatus status) async {
  await supabase.from('sets').update({'status': status.index}).eq('id', setId);
}

Future<void> flagPartAsSpare(int partId, bool isSpare) async {
  await supabase.from('set_parts').update({'is_spare': isSpare}).eq('id', partId);
}

Future<void> flagPartAsLost(int partId, bool isLost) async {
  await supabase.from('set_parts').update({'is_lost': isLost}).eq('id', partId);
}

Future<void> updatePartQuantityFound(int partId, int quantityFound) async {
  await supabase.from('set_parts').update({'quantity_found': quantityFound}).eq('id', partId);
}

@riverpod
Future<void> setAllPartsToFound(Ref ref, String setId) async {
  final response = await supabase.functions.invoke(
    'set-all-parts-found',
    body: {
      'setId': setId,
      'found': true,
    },
  );

  if (response.status != 200) {
    final errorData = response.data;
    final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
    throw errorMessage ?? 'Failed to mark all parts as found (status ${response.status})';
  }
}

Future<void> setAllPartsToNotFound(String setId) async {
  final response = await supabase.functions.invoke(
    'set-all-parts-found',
    body: {
      'setId': setId,
      'found': false,
    },
  );

  if (response.status != 200) {
    final errorData = response.data;
    final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
    throw errorMessage ?? 'Failed to reset parts (status ${response.status})';
  }
}

@Riverpod(name: 'setPartsNotifierProvider')
class SetPartsNotifier extends _$SetPartsNotifier {
  final Map<int, Timer> _debounceTimers = {};
  final Map<int, int> _pendingSyncs = {};

  @override
  Future<List<SetPart>> build(String setId) async {
    ref.onDispose(() {
      _flushAllTimers();
    });

    if (auth.currentUser == null) return [];

    final response = await supabase
        .from('set_parts')
        .select()
        .eq('set_id', setId)
        .order('color_id', ascending: true)
        .order('part_num', ascending: true);

    final parts = response.map((json) => SetPart.fromJson(json)).toList();
    parts.sort((a, b) {
      final colorCompare = a.colorId.compareTo(b.colorId);
      if (colorCompare != 0) return colorCompare;
      return a.partNum.compareTo(b.partNum);
    });
    return parts;
  }

  void _flushAllTimers() {
    for (final entry in _pendingSyncs.entries) {
      final partId = entry.key;
      final quantity = entry.value;
      supabase
          .from('set_parts')
          .update({'quantity_found': quantity})
          .eq('id', partId)
          .ignore();
    }
    _pendingSyncs.clear();
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  void updateQuantity(int partId, int quantity) {
    if (quantity < 0) return;
    final currentList = state.value;
    if (currentList == null) return;

    final index = currentList.indexWhere((p) => p.id == partId);
    if (index == -1) return;

    final oldPart = currentList[index];
    if (oldPart.quantityFound == quantity) return;

    final updatedPart = oldPart.copyWith(quantityFound: quantity);
    final newList = List<SetPart>.of(currentList);
    newList[index] = updatedPart;
    state = AsyncData(newList);

    _debounceSyncQuantity(partId, quantity);
  }

  void incrementQuantity(int partId) {
    final currentList = state.value;
    if (currentList == null) return;

    final index = currentList.indexWhere((p) => p.id == partId);
    if (index == -1) return;

    final part = currentList[index];
    if (part.isFinished) return;

    updateQuantity(partId, part.quantityFound + 1);
  }

  void decrementQuantity(int partId) {
    final currentList = state.value;
    if (currentList == null) return;

    final index = currentList.indexWhere((p) => p.id == partId);
    if (index == -1) return;

    final part = currentList[index];
    if (part.quantityFound <= 0) return;

    updateQuantity(partId, part.quantityFound - 1);
  }

  void _debounceSyncQuantity(int partId, int quantity) {
    _pendingSyncs[partId] = quantity;
    _debounceTimers[partId]?.cancel();
    _debounceTimers[partId] = Timer(const Duration(milliseconds: 350), () async {
      _debounceTimers.remove(partId);
      final syncQuantity = _pendingSyncs.remove(partId);
      if (syncQuantity != null) {
        try {
          await supabase
              .from('set_parts')
              .update({'quantity_found': syncQuantity})
              .eq('id', partId);
        } catch (_) {
          // Sync failure will be retried or preserved
        }
      }
    });
  }

  Future<void> toggleSpare(int partId, bool isSpare) async {
    final currentList = state.value;
    if (currentList == null) return;

    final index = currentList.indexWhere((p) => p.id == partId);
    if (index == -1) return;

    final updatedPart = currentList[index].copyWith(isSpare: isSpare);
    final newList = List<SetPart>.of(currentList);
    newList[index] = updatedPart;
    state = AsyncData(newList);

    try {
      await supabase.from('set_parts').update({'is_spare': isSpare}).eq('id', partId);
    } catch (_) {
      // Background sync
    }
  }

  Future<void> toggleLost(int partId, bool isLost) async {
    final currentList = state.value;
    if (currentList == null) return;

    final index = currentList.indexWhere((p) => p.id == partId);
    if (index == -1) return;

    final updatedPart = currentList[index].copyWith(isLost: isLost);
    final newList = List<SetPart>.of(currentList);
    newList[index] = updatedPart;
    state = AsyncData(newList);

    try {
      await supabase.from('set_parts').update({'is_lost': isLost}).eq('id', partId);
    } catch (_) {
      // Background sync
    }
  }

  Future<void> markAllFound() async {
    final currentList = state.value;
    if (currentList == null) return;

    _flushAllTimers();

    final newList = currentList.map((part) {
      if (part.isSpare || part.isLost) return part;
      return part.copyWith(quantityFound: part.quantityNeeded);
    }).toList();
    state = AsyncData(newList);

    final response = await supabase.functions.invoke(
      'set-all-parts-found',
      body: {
        'setId': setId,
        'found': true,
      },
    );

    if (response.status != 200) {
      final errorData = response.data;
      final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
      throw errorMessage ?? 'Failed to mark all parts as found (status ${response.status})';
    }
  }

  Future<void> resetAllParts() async {
    final currentList = state.value;
    if (currentList == null) return;

    _flushAllTimers();

    final newList = currentList.map((part) {
      return part.copyWith(quantityFound: 0);
    }).toList();
    state = AsyncData(newList);

    final response = await supabase.functions.invoke(
      'set-all-parts-found',
      body: {
        'setId': setId,
        'found': false,
      },
    );

    if (response.status != 200) {
      final errorData = response.data;
      final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
      throw errorMessage ?? 'Failed to reset parts (status ${response.status})';
    }
  }
}


