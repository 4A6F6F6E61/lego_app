import 'package:lego_app/api/api_client.dart';

const String bricksetApiPath = 'https://brickset.com/api/v3.asmx/';

final bricksetApi = BricksetApi._();

class LegoInstruction {
  final String description;
  final String url;

  const LegoInstruction({
    required this.description,
    required this.url,
  });

  factory LegoInstruction.fromJson(Map<String, dynamic> json) {
    return LegoInstruction(
      description: (json['description'] as String?)?.trim().isNotEmpty == true
          ? (json['description'] as String).trim()
          : 'Instruction Booklet',
      url: json['URL'] as String? ?? '',
    );
  }
}

class BricksetApi {
  const BricksetApi._();

  Future<List<LegoInstruction>> getInstructions(
    String apiKey,
    String setNumber,
  ) async {
    final res = await apiGet(
      bricksetApiPath,
      '/getInstructions2',
      queryParameters: {'apiKey': apiKey, 'setNumber': setNumber},
    );
    final rawInstructions = res['instructions'] as List<dynamic>? ?? [];
    return rawInstructions
        .whereType<Map<String, dynamic>>()
        .map((item) => LegoInstruction.fromJson(item))
        .where((inst) => inst.url.isNotEmpty)
        .toList();
  }

  Future<String> getInstructions2(String apiKey, String setNumber) async {
    final instructions = await getInstructions(apiKey, setNumber);
    if (instructions.isEmpty) {
      throw Exception('No instructions found for set $setNumber');
    }
    return instructions.first.url;
  }
}
