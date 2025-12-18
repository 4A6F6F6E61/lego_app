import 'package:lego_app/api/api_client.dart';
import 'package:lego_app/api/models/main.dart';

final userApi = UsersApi();

class UsersApi {
  // Future<void> login(String username, String password) async {
  //   if (username.isEmpty || password.isEmpty) {
  //     showSnack(context, 'Please enter both username and password');
  //     return;
  //   }
  //   try {
  //     final token = await userApi.tokenCreate(username.text, password.text);
  //     await ref.read(userTokenProvider.notifier).set(token);
  //     if (context.mounted) {
  //       context.go('/home');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       showSnack(context, 'Login failed: $e');
  //     }
  //     return;
  //   }
  // }

  Future<String> tokenCreate({
    required String apiKey,
    required String username,
    required String password,
  }) async {
    final response = await apiPost(
      '/api/v3/users/_token/',
      apiKey: apiKey,
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
    final response = await apiGet(
      '/api/v3/users/$userToken/sets/',
      apiKey: apiKey,
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
