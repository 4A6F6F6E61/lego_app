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
      .order('part_num', ascending: true)
      .map((data) => data.map((json) => SetPart.fromJson(json)).toList());
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
