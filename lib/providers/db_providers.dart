import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/lego_set.dart';

final setsProvider = StreamProvider<List<LegoSet>>((ref) {
  if (auth.currentUser == null) return Stream.value([]);

  return supabase
      .from('sets')
      .stream(primaryKey: ['id'])
      .eq('user_id', auth.currentUser!.id)
      .order('set_num', ascending: true)
      .map((data) => data.map((json) => LegoSet.fromJson(json)).toList());
});
