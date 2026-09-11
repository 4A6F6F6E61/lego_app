import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack(
  BuildContext context,
  String message,
) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(label: 'OK', onPressed: () {}),
    ),
  );
}

Future<void> syncRebrickable({required String apiKey, required String userToken}) async {
  if (auth.currentUser == null) {
    throw 'User not authenticated';
  }
  int currentPage = 1;
  while (true) {
    final setCollection = await userApi.getSetCollection(
      apiKey: apiKey,
      userToken: userToken,
      page: currentPage,
    );

    for (final setCollectionItem in setCollection.results) {
      final set = setCollectionItem.set;
      dev.log('Set: ${set.name} - ${set.setNum}');
      final setExists = await supabase
          .from('sets')
          .select()
          .eq('user_id', auth.currentUser!.id)
          .eq('set_num', set.setNum)
          .limit(1)
          .then((data) => data.isNotEmpty);
      if (setExists) {
        dev.log('  Set already exists in database, skipping...');
        continue;
      }
      final LegoSet dbSet = LegoSet(
        id: "", // .toJSON ignores this field and we don't know the id yet
        userId: auth.currentUser!.id,
        setNum: set.setNum,
        name: set.name,
        year: set.year,
        themeId: set.themeId,
        imgUrl: set.setImgUrl,
        createdAt: DateTime.now(),
        status: LegoSetStatus.backlog,
      );
      final id = await supabase
          .from('sets')
          .insert(dbSet.toJson())
          .select()
          .single()
          .then((data) => data['id'] as String);

      await syncSetParts(apiKey: apiKey, dbSetId: id, setNum: set.setNum);
    }

    if (setCollection.next == null) {
      break;
    }

    currentPage++;
    final nextPageSetCollection = await userApi.getSetCollection(
      apiKey: apiKey,
      userToken: userToken,
      page: currentPage,
    );
    if (nextPageSetCollection.results.isEmpty) {
      break;
    }
  }
}

Future<void> syncSetParts({
  required String apiKey,
  required String dbSetId,
  required String setNum,
}) async {
  var response = await legoApi.getSetParts(apiKey: apiKey, setNum: setNum);
  dev.inspect(response);
  var currentPage = 1;
  while (true) {
    Iterable<SetPart> setParts = (response['results'] as List).map(
      (rawPart) => SetPart.fromApiData(setId: dbSetId, userId: auth.currentUser!.id, rawPart),
    );
    try {
      await supabase.from('set_parts').insert(setParts.map((e) => e.toJson()).toList());
    } catch (e) {
      dev.log('    Error inserting parts: $e');
    }

    if (response['next'] != null) {
      currentPage++;
      try {
        response = await legoApi.getSetParts(apiKey: apiKey, setNum: setNum, page: currentPage);
        dev.inspect(response);
      } on ApiException catch (e) {
        if (e.statusCode == 429) {
          // Wait for 1 minute in case of rate limiting
          await Future.delayed(const Duration(minutes: 1));
          response = await legoApi.getSetParts(apiKey: apiKey, setNum: setNum, page: currentPage);
          dev.inspect(response);
        } else {
          rethrow;
        }
      }
    } else {
      break;
    }
  }
}

String proxiedImageUrl(String url) {
  if (kIsWeb) {
    return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
  }
  return url;
}

double calculateProgress(List<SetPart> parts) {
  final totalNeeded = parts.fold<int>(0, (sum, part) {
    if (part.isSpare) return sum;
    return sum + part.quantityNeeded;
  });
  final totalFound = parts.fold<int>(0, (sum, part) {
    if (part.isSpare) return sum;
    return sum + part.quantityFound;
  });
  return totalNeeded == 0 ? 0.0 : totalFound / totalNeeded;
}

Color getProgressColor(double progress) {
  final p = progress.clamp(0.0, 1.0);
  if (p <= 0.0) return const Color(0xFFEF4444); // Red
  if (p >= 1.0) return const Color(0xFF10B981); // Emerald Green
  if (p < 0.5) {
    final t = p / 0.5;
    return Color.lerp(const Color(0xFFEF4444), const Color(0xFFF59E0B), t)!; // Red -> Amber
  }
  final t = (p - 0.5) / 0.5;
  return Color.lerp(const Color(0xFFF59E0B), const Color(0xFF10B981), t)!; // Amber -> Emerald
}

class MissingPartsExportResult {
  final int? listId;
  final String listName;
  final int uniquePartsCount;
  final int totalQuantity;
  final String webUrl;
  final bool isLostParts;

  const MissingPartsExportResult({
    this.listId,
    required this.listName,
    required this.uniquePartsCount,
    required this.totalQuantity,
    required this.webUrl,
    this.isLostParts = false,
  });
}

Future<MissingPartsExportResult> exportMissingPartsToRebrickable({
  required String apiKey,
  required String userToken,
  required String listName,
  required List<SetPart> missingParts,
}) async {
  if (missingParts.isEmpty) {
    throw 'No missing parts to export.';
  }

  // 1. Group and aggregate quantities for parts with the same partNum and colorId
  final Map<String, ({String partNum, int colorId, int quantity})> aggregated = {};
  for (final part in missingParts) {
    final key = '${part.partNum}:${part.colorId}';
    final qty = (part.quantityNeeded - part.quantityFound) > 0
        ? (part.quantityNeeded - part.quantityFound)
        : 1;

    if (aggregated.containsKey(key)) {
      final existing = aggregated[key]!;
      aggregated[key] = (
        partNum: existing.partNum,
        colorId: existing.colorId,
        quantity: existing.quantity + qty,
      );
    } else {
      aggregated[key] = (
        partNum: part.partNum,
        colorId: part.colorId,
        quantity: qty,
      );
    }
  }

  // 2. Create the part list on Rebrickable
  final createRes = await userApi.createPartList(
    apiKey: apiKey,
    userToken: userToken,
    name: listName,
    isBuildable: true,
  );
  final listId = createRes['id'] as int;

  // 3. Add the parts to the part list in chunks (up to 50 parts per batch)
  final partsPayload = aggregated.values.map((item) => {
    'part_num': item.partNum,
    'color_id': item.colorId,
    'quantity': item.quantity,
  }).toList();

  const chunkSize = 50;
  for (var i = 0; i < partsPayload.length; i += chunkSize) {
    final chunk = partsPayload.sublist(
      i,
      i + chunkSize > partsPayload.length ? partsPayload.length : i + chunkSize,
    );
    await userApi.addPartsToPartList(
      apiKey: apiKey,
      userToken: userToken,
      listId: listId,
      parts: chunk,
    );
  }

  // 4. Retrieve user profile to construct the direct URL
  String webUrl = 'https://rebrickable.com/users/';
  try {
    final profile = await userApi.getUserProfile(apiKey: apiKey, userToken: userToken);
    final username = profile['username'] as String?;
    if (username != null && username.isNotEmpty) {
      webUrl = 'https://rebrickable.com/users/$username/partlists/$listId/';
    }
  } catch (e) {
    dev.log('Could not fetch user profile for username URL: $e');
  }

  final totalQuantity = aggregated.values.fold<int>(0, (sum, e) => sum + e.quantity);

  return MissingPartsExportResult(
    listId: listId,
    listName: listName,
    uniquePartsCount: aggregated.length,
    totalQuantity: totalQuantity,
    webUrl: webUrl,
  );
}

Future<MissingPartsExportResult> exportToLostParts({
  required String apiKey,
  required String userToken,
  required List<SetPart> missingParts,
}) async {
  if (missingParts.isEmpty) {
    throw 'No missing parts to export.';
  }

  // 1. Group and aggregate quantities for parts with the same inventory part id
  final Map<int, int> aggregated = {};
  for (final part in missingParts) {
    final qty = (part.quantityNeeded - part.quantityFound) > 0
        ? (part.quantityNeeded - part.quantityFound)
        : 1;
    aggregated[part.id] = (aggregated[part.id] ?? 0) + qty;
  }

  // 2. Add the parts to the lost parts list in chunks (up to 50 parts per batch)
  final partsPayload = aggregated.entries.map((entry) => {
    'inv_part_id': entry.key,
    'lost_quantity': entry.value,
  }).toList();

  const chunkSize = 50;
  for (var i = 0; i < partsPayload.length; i += chunkSize) {
    final chunk = partsPayload.sublist(
      i,
      i + chunkSize > partsPayload.length ? partsPayload.length : i + chunkSize,
    );
    await userApi.addLostParts(
      apiKey: apiKey,
      userToken: userToken,
      parts: chunk,
    );
  }

  // 3. Retrieve user profile to construct the direct URL
  String webUrl = 'https://rebrickable.com/users/';
  try {
    final profile = await userApi.getUserProfile(apiKey: apiKey, userToken: userToken);
    final username = profile['username'] as String?;
    if (username != null && username.isNotEmpty) {
      webUrl = 'https://rebrickable.com/users/$username/lostparts/';
    }
  } catch (e) {
    dev.log('Could not fetch user profile for username URL: $e');
  }

  final totalQuantity = aggregated.values.fold<int>(0, (sum, qty) => sum + qty);

  return MissingPartsExportResult(
    listId: null,
    listName: 'My Lost Parts',
    uniquePartsCount: aggregated.length,
    totalQuantity: totalQuantity,
    webUrl: webUrl,
    isLostParts: true,
  );
}
