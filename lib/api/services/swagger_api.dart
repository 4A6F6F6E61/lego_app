import '../api_client.dart';

class SwaggerApi {
  Future<dynamic> swaggerList(String apiKey) async {
    return apiGet('/api/v3/swagger/', apiKey: apiKey);
  }
}
