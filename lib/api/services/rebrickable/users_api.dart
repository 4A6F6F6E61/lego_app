import 'dart:developer' as dev;

import 'package:lego_app/api/api_client.dart';
import 'package:lego_app/api/models/main.dart';
import 'package:lego_app/api/services/rebrickable/common.dart';

final userApi = UsersApi._();

class UsersApi {
  const UsersApi._();
  Future<String> tokenCreate({
    required String apiKey,
    required String username,
    required String password,
  }) async {
    final response = await apiPost(
      rebrickableApiPath,
      '/users/_token/',
      authHeaderKey: apiKey,
      body: {'username': username, 'password': password},
      form: true,
    );
    return response['user_token'];
  }

  Future<SetCollectionResponse> getSetCollection({
    required String userToken,
    required String apiKey,
    int? page,
    int? pageSize,
    String? setNum,
    num? themeId,
    num? minYear,
    num? maxYear,
    int? minParts,
    int? maxParts,
    String? ordering,
    String? search,
  }) async {
    dev.log("Fetching set collection for user $userToken, page $page");
    final response = await apiGet(
      rebrickableApiPath,
      '/users/$userToken/sets/',
      authHeaderKey: apiKey,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'set_num': setNum,
        'theme_id': themeId,
        'min_year': minYear,
        'max_year': maxYear,
        'min_parts': minParts,
        'max_parts': maxParts,
        'ordering': ordering,
        'search': search,
      },
    );
    return SetCollectionResponse.fromJson(response);
  }
}
