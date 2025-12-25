import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';

final setsProvider = StreamProvider<List<LegoSet>>((ref) {
  if (auth.currentUser == null) return Stream.value([]);

  return supabase
      .from('sets')
      .stream(primaryKey: ['id'])
      .order('set_num', ascending: true)
      .map((data) => data.map((json) => LegoSet.fromJson(json)).toList());
});

final setPartsProvider = StreamProvider.family<List<SetPart>, String>((ref, setId) {
  if (auth.currentUser == null) return Stream.value([]);

  return supabase
      .from('set_parts')
      .stream(primaryKey: ['id'])
      .eq('set_id', setId)
      .order('part_num', ascending: true)
      .order('color_id', ascending: true)
      .map((data) => data.map((json) => SetPart.fromJson(json)).toList());
});

final setProvider = StreamProvider.family<LegoSet?, String>((ref, setId) {
  if (auth.currentUser == null) return Stream.value(null);

  return supabase
      .from('sets')
      .stream(primaryKey: ['id'])
      .eq('id', setId)
      .map((data) => data.isNotEmpty ? LegoSet.fromJson(data.first) : null);
});
