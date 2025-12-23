import 'package:lego_app/api/api_client.dart';

const String bricksetApiPath = 'https://brickset.com/api/v3.asmx/';

final bricksetApi = BricksetApi._();

class BricksetApi {
  const BricksetApi._();

  Future<String> getInstructions2(String apiKey, String setNumber) async {
    final res = await apiGet(
      bricksetApiPath,
      '/getInstructions2',
      queryParameters: {'apiKey': apiKey, 'setNumber': setNumber},
    );
    final instructions = res['instructions'] as List<dynamic>;
    if (instructions.isEmpty) {
      throw Exception('No instructions found for set $setNumber');
    }
    final firstInstruction = instructions.first as Map<String, dynamic>;
    // TODO: I assume here that the first instruction is the correct one (international?), but maybe we should verify that?
    return firstInstruction['URL'] as String;
  }
}
