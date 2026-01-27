import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      action: SnackBarAction(label: 'Ok', onPressed: () {}),
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
