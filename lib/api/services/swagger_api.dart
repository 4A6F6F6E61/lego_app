import '../api_client.dart';

class SwaggerApi {
  final ApiClient _apiClient;
  SwaggerApi(this._apiClient);

  Future<dynamic> swaggerList() async {
    return _apiClient.get('/api/v3/swagger/');
  }
}
