import 'dart:developer' as dev;

import '../api_client.dart';

final legoApi = LegoApi();

class LegoApi {
  // Future<dynamic> colorsList({int? page, int? pageSize, String? ordering}) async {
  //   return apiGet(
  //     '/api/v3/lego/colors/',
  //     queryParameters: {'page': page, 'page_size': pageSize, 'ordering': ordering},
  //   );
  // }

  // Future<dynamic> colorsRead(String id, {String? ordering}) async {
  //   return apiGet('/api/v3/lego/colors/$id/', queryParameters: {'ordering': ordering});
  // }

  // Future<dynamic> elementsRead(String elementId) async {
  //   return apiGet('/api/v3/lego/elements/$elementId/');
  // }

  // Future<dynamic> minifigsList({
  //   int? page,
  //   int? pageSize,
  //   num? minParts,
  //   num? maxParts,
  //   String? inSetNum,
  //   String? inThemeId,
  //   String? ordering,
  //   String? search,
  // }) async {
  //   return apiGet(
  //     '/api/v3/lego/minifigs/',
  //     queryParameters: {
  //       'page': page,
  //       'page_size': pageSize,
  //       'min_parts': minParts,
  //       'max_parts': maxParts,
  //       'in_set_num': inSetNum,
  //       'in_theme_id': inThemeId,
  //       'ordering': ordering,
  //       'search': search,
  //     },
  //   );
  // }

  // Future<dynamic> minifigsRead(String setNum) async {
  //   return apiGet('/api/v3/lego/minifigs/$setNum/');
  // }

  // Future<dynamic> partsList({
  //   int? page,
  //   int? pageSize,
  //   String? partNum,
  //   String? partNums,
  //   String? partCatId,
  //   String? colorId,
  //   String? bricklinkId,
  //   String? brickowlId,
  //   String? legoId,
  //   String? ldrawId,
  //   String? ordering,
  //   String? search,
  // }) async {
  //   return apiGet(
  //     '/api/v3/lego/parts/',
  //     queryParameters: {
  //       'page': page,
  //       'page_size': pageSize,
  //       'part_num': partNum,
  //       'part_nums': partNums,
  //       'part_cat_id': partCatId,
  //       'color_id': colorId,
  //       'bricklink_id': bricklinkId,
  //       'brickowl_id': brickowlId,
  //       'lego_id': legoId,
  //       'ldraw_id': ldrawId,
  //       'ordering': ordering,
  //       'search': search,
  //     },
  //   );
  // }

  // Future<dynamic> partsRead(String partNum) async {
  //   return apiGet('/api/v3/lego/parts/$partNum/');
  // }

  // Future<dynamic> setsList({
  //   int? page,
  //   int? pageSize,
  //   String? themeId,
  //   num? minYear,
  //   num? maxYear,
  //   num? minParts,
  //   num? maxParts,
  //   String? ordering,
  //   String? search,
  // }) async {
  //   return apiGet(
  //     '/api/v3/lego/sets/',
  //     queryParameters: {
  //       'page': page,
  //       'page_size': pageSize,
  //       'theme_id': themeId,
  //       'min_year': minYear,
  //       'max_year': maxYear,
  //       'min_parts': minParts,
  //       'max_parts': maxParts,
  //       'ordering': ordering,
  //       'search': search,
  //     },
  //   );
  // }

  Future<dynamic> getSetParts({
    required String apiKey,
    required String setNum,
    int page = 1,
  }) async {
    dev.log("Fetching parts for set $setNum, page $page");
    return apiGet(
      apiKey: apiKey,
      '/api/v3/lego/sets/$setNum/parts/',
      queryParameters: {'page': page},
    );
  }
}
