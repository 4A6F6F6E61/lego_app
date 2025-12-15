import '../api_client.dart';

final userApi = UsersApi._();

class UsersApi {
  UsersApi._();

  final ApiClient _apiClient = ApiClient();

  Future<String> tokenCreate(String username, String password) async {
    final response = await _apiClient.post(
      '/api/v3/users/_token/',
      body: {'username': username, 'password': password},
      form: true,
    );
    return response['user_token'];
  }

  Future<dynamic> badgesList({int? page, int? pageSize, String? ordering}) async {
    return _apiClient.get(
      '/api/v3/users/badges/',
      queryParameters: {'page': page, 'page_size': pageSize, 'ordering': ordering},
    );
  }

  Future<dynamic> badgesRead(String id, {String? ordering}) async {
    return _apiClient.get('/api/v3/users/badges/$id/', queryParameters: {'ordering': ordering});
  }

  Future<dynamic> profileRead(String userToken) async {
    return _apiClient.get('/api/v3/users/$userToken/profile/');
  }

  Future<dynamic> setsList(
    String userToken, {
    int? page,
    int? pageSize,
    String? setNum,
    num? themeId,
    num? minYear,
    num? maxYear,
    num? minParts,
    num? maxParts,
    String? ordering,
    String? search,
  }) async {
    return _apiClient.get(
      '/api/v3/users/$userToken/sets/',
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
  }

  Future<dynamic> setsCreate(
    String userToken,
    String setNum, {
    int? quantity,
    bool? includeSpares,
  }) async {
    return _apiClient.post(
      '/api/v3/users/$userToken/sets/',
      body: {'set_num': setNum, 'quantity': quantity, 'include_spares': includeSpares},
      form: true,
    );
  }

  Future<dynamic> partlistsList(String userToken, {int? page, int? pageSize}) async {
    return _apiClient.get(
      '/api/v3/users/$userToken/partlists/',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
  }

  Future<dynamic> partlistsCreate(
    String userToken,
    String name, {
    bool? isBuildable,
    int? numParts,
  }) async {
    return _apiClient.post(
      '/api/v3/users/$userToken/partlists/',
      body: {'name': name, 'is_buildable': isBuildable, 'num_parts': numParts},
      form: true,
    );
  }

  Future<dynamic> partlistsPartsList(
    String userToken,
    String listId, {
    int? page,
    int? pageSize,
    String? ordering,
  }) async {
    return _apiClient.get(
      '/api/v3/users/$userToken/partlists/$listId/parts/',
      queryParameters: {'page': page, 'page_size': pageSize, 'ordering': ordering},
    );
  }

  Future<dynamic> partlistsPartsCreate(
    String userToken,
    String listId, {
    required String partNum,
    required int quantity,
    required int colorId,
  }) async {
    return _apiClient.post(
      '/api/v3/users/$userToken/partlists/$listId/parts/',
      body: {'part_num': partNum, 'quantity': quantity, 'color_id': colorId},
      form: true,
    );
  }

  Future<dynamic> lostPartsList(
    String userToken, {
    int? page,
    int? pageSize,
    String? ordering,
  }) async {
    return _apiClient.get(
      '/api/v3/users/$userToken/lost_parts/',
      queryParameters: {'page': page, 'page_size': pageSize, 'ordering': ordering},
    );
  }

  Future<dynamic> lostPartsCreate(
    String userToken, {
    int? lostQuantity,
    required int invPartId,
  }) async {
    return _apiClient.post(
      '/api/v3/users/$userToken/lost_parts/',
      body: {'lost_quantity': lostQuantity, 'inv_part_id': invPartId},
      form: true,
    );
  }

  Future<dynamic> allpartsList(
    String userToken, {
    int? page,
    int? pageSize,
    String? partNum,
    int? partCatId,
    int? colorId,
  }) async {
    return _apiClient.get(
      '/api/v3/users/$userToken/allparts/',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'part_num': partNum,
        'part_cat_id': partCatId,
        'color_id': colorId,
      },
    );
  }
}
