import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/api/models/color.dart';
import 'package:lego_app/providers/settings.dart';

final colorsProvider = FutureProvider<Map<int, Color>>((ref) async {
  dev.log('Fetching colors from Rebrickable API');
  final apiKey = await ref.watch(rebrickableApiKeyProvider.future);
  if (apiKey == null) return {};

  final colors = <int, Color>{};
  int page = 1;

  while (true) {
    try {
      dev.log('Fetching colors page $page');
      final response = await legoApi.colorsList(apiKey: apiKey, page: page, pageSize: 1000);
      final results = response['results'] as List;

      for (final json in results) {
        final color = Color.fromJson(json);
        colors[color.id] = color;
      }

      dev.log('Fetched ${results.length} colors in page $page; next: ${response['next']}');
      if (response['next'] == null || response['next'] == '') break;
      page++;
    } catch (e) {
      dev.log('Error fetching colors page $page: $e');
      break;
    }
  }
  dev.log('Fetched ${colors.length} colors from Rebrickable API');

  return colors;
});
