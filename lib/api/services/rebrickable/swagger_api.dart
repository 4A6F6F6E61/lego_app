import 'package:lego_app/api/services/rebrickable/common.dart';

import '../../api_client.dart';

class SwaggerApi {
  Future<dynamic> swaggerList(String apiKey) async {
    return apiGet(rebrickableApiPath, '/swagger/', authHeaderKey: apiKey);
  }
}
