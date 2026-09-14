import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/db/db.dart';
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

Future<Map<String, dynamic>> syncRebrickable({
  required String apiKey,
  required String userToken,
}) async {
  if (auth.currentUser == null) {
    throw 'User not authenticated';
  }

  final response = await supabase.functions.invoke(
    'sync-rebrickable',
    body: {
      'apiKey': apiKey,
      'userToken': userToken,
    },
  );

  if (response.status != 200) {
    final errorData = response.data;
    final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
    throw errorMessage ?? 'Failed to synchronize with Rebrickable (status ${response.status})';
  }

  return (response.data as Map?)?.cast<String, dynamic>() ?? {};
}

Future<Map<String, dynamic>> syncSetParts({
  required String apiKey,
  required String setNum,
  String? dbSetId,
}) async {
  if (auth.currentUser == null) {
    throw 'User not authenticated';
  }

  final response = await supabase.functions.invoke(
    'sync-rebrickable',
    body: {
      'apiKey': apiKey,
      'setNum': setNum,
    },
  );

  if (response.status != 200) {
    final errorData = response.data;
    final errorMessage = errorData is Map ? errorData['error'] ?? errorData['message'] : null;
    throw errorMessage ?? 'Failed to synchronize set $setNum (status ${response.status})';
  }

  return (response.data as Map?)?.cast<String, dynamic>() ?? {};
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

enum PartSortOption {
  color,
  type;

  String get label => switch (this) {
    PartSortOption.color => 'Color',
    PartSortOption.type => 'Type',
  };
}

int compareNatural(String a, String b) {
  final strA = a.toLowerCase();
  final strB = b.toLowerCase();
  if (strA == strB) return 0;

  final regex = RegExp(r'(\d+)|(\D+)');
  final matchesA = regex.allMatches(strA).map((m) => m.group(0)!).toList();
  final matchesB = regex.allMatches(strB).map((m) => m.group(0)!).toList();

  final minLen = matchesA.length < matchesB.length ? matchesA.length : matchesB.length;
  for (var i = 0; i < minLen; i++) {
    final tokenA = matchesA[i];
    final tokenB = matchesB[i];

    final numA = int.tryParse(tokenA);
    final numB = int.tryParse(tokenB);

    if (numA != null && numB != null) {
      final numCompare = numA.compareTo(numB);
      if (numCompare != 0) return numCompare;
    } else {
      final strCompare = tokenA.compareTo(tokenB);
      if (strCompare != 0) return strCompare;
    }
  }
  return matchesA.length.compareTo(matchesB.length);
}

List<SetPart> sortParts(List<SetPart> parts, PartSortOption sortOption) {
  final list = List<SetPart>.of(parts);
  list.sort((a, b) {
    if (sortOption == PartSortOption.type) {
      // Primary sort: Type (part name, fallback to partNum)
      final nameA = (a.name?.trim().isNotEmpty == true ? a.name!.trim() : a.partNum);
      final nameB = (b.name?.trim().isNotEmpty == true ? b.name!.trim() : b.partNum);
      final typeCompare = compareNatural(nameA, nameB);
      if (typeCompare != 0) return typeCompare;

      // Secondary sort: partNum if names were identical
      final partNumCompare = compareNatural(a.partNum, b.partNum);
      if (partNumCompare != 0) return partNumCompare;

      // Tertiary sort: colorId
      return a.colorId.compareTo(b.colorId);
    } else {
      // Primary sort: Color (colorId, like it is right now)
      final colorCompare = a.colorId.compareTo(b.colorId);
      if (colorCompare != 0) return colorCompare;

      // Secondary sort: Type (part name / partNum)
      final nameA = (a.name?.trim().isNotEmpty == true ? a.name!.trim() : a.partNum);
      final nameB = (b.name?.trim().isNotEmpty == true ? b.name!.trim() : b.partNum);
      final typeCompare = compareNatural(nameA, nameB);
      if (typeCompare != 0) return typeCompare;

      return compareNatural(a.partNum, b.partNum);
    }
  });
  return list;
}
