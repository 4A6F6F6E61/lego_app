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

Future<void> updatePartQuantityFound(int partId, int quantityFound) async {
  await supabase.from('set_parts').update({'quantity_found': quantityFound}).eq('id', partId);
}

@riverpod
Future<void> setAllPartsToFound(Ref ref, String setId) async {
  final parts = await ref.read(setPartsProvider(setId).future);
  for (final part in parts) {
    await supabase
        .from('set_parts')
        .update({'quantity_found': part.quantityNeeded})
        .eq('id', part.id);
  }
}

Future<void> setAllPartsToNotFound(String setId) async {
  await supabase.from('set_parts').update({'quantity_found': 0}).eq('set_id', setId);
}
