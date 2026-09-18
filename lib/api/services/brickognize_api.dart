import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

const String brickognizeApiPath = 'https://api.brickognize.com';

final brickognizeApi = BrickognizeApi();

class BrickognizeExternalSite {
  final String name;
  final String url;

  const BrickognizeExternalSite({
    required this.name,
    required this.url,
  });

  factory BrickognizeExternalSite.fromJson(Map<String, dynamic> json) {
    return BrickognizeExternalSite(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}

class BrickognizeItem {
  final String id;
  final String name;
  final String imgUrl;
  final String? category;
  final String type;
  final double score;
  final List<BrickognizeExternalSite> externalSites;

  const BrickognizeItem({
    required this.id,
    required this.name,
    required this.imgUrl,
    this.category,
    required this.type,
    required this.score,
    required this.externalSites,
  });

  factory BrickognizeItem.fromJson(Map<String, dynamic> json) {
    final sites = (json['external_sites'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((s) => BrickognizeExternalSite.fromJson(s))
            .toList() ??
        [];

    return BrickognizeItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Part',
      imgUrl: json['img_url'] as String? ?? '',
      category: json['category'] as String?,
      type: json['type'] as String? ?? 'part',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      externalSites: sites,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'img_url': imgUrl,
        'category': category,
        'type': type,
        'score': score,
        'external_sites': externalSites.map((e) => e.toJson()).toList(),
      };
}

class BrickognizeColor {
  final String id;
  final String name;
  final double score;

  const BrickognizeColor({
    required this.id,
    required this.name,
    required this.score,
  });

  factory BrickognizeColor.fromJson(Map<String, dynamic> json) {
    return BrickognizeColor(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
      };
}

class BrickognizeBoundingBox {
  final double left;
  final double upper;
  final double right;
  final double lower;
  final double imageWidth;
  final double imageHeight;
  final double score;

  const BrickognizeBoundingBox({
    required this.left,
    required this.upper,
    required this.right,
    required this.lower,
    required this.imageWidth,
    required this.imageHeight,
    required this.score,
  });

  factory BrickognizeBoundingBox.fromJson(Map<String, dynamic> json) {
    return BrickognizeBoundingBox(
      left: (json['left'] as num?)?.toDouble() ?? 0.0,
      upper: (json['upper'] as num?)?.toDouble() ?? 0.0,
      right: (json['right'] as num?)?.toDouble() ?? 0.0,
      lower: (json['lower'] as num?)?.toDouble() ?? 0.0,
      imageWidth: (json['image_width'] as num?)?.toDouble() ?? 0.0,
      imageHeight: (json['image_height'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BrickognizePredictionResult {
  final String listingId;
  final List<BrickognizeItem> items;
  final List<BrickognizeColor> colors;
  final BrickognizeBoundingBox? boundingBox;

  const BrickognizePredictionResult({
    required this.listingId,
    required this.items,
    this.colors = const [],
    this.boundingBox,
  });

  factory BrickognizePredictionResult.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((e) => BrickognizeItem.fromJson(e))
        .toList();

    final rawColors = (json['colors'] as List<dynamic>?) ?? [];
    final colors = rawColors
        .whereType<Map<String, dynamic>>()
        .map((e) => BrickognizeColor.fromJson(e))
        .toList();

    final boxJson = json['bounding_box'] as Map<String, dynamic>?;
    final boundingBox =
        boxJson != null ? BrickognizeBoundingBox.fromJson(boxJson) : null;

    return BrickognizePredictionResult(
      listingId: json['listing_id'] as String? ?? '',
      items: items,
      colors: colors,
      boundingBox: boundingBox,
    );
  }
}

class BrickognizeApi {
  final String baseUrl;
  final http.Client? _client;

  BrickognizeApi({
    this.baseUrl = brickognizeApiPath,
    http.Client? client,
  }) : _client = client;

  http.Client get _effectiveClient => _client ?? http.Client();

  MediaType _resolveMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    return MediaType('image', 'jpeg');
  }

  /// Calls Brickognize predict endpoint with image bytes
  Future<BrickognizePredictionResult> predict({
    required Uint8List imageBytes,
    String filename = 'piece.jpg',
    bool predictColor = true,
    int topK = 10,
    double minSimilarity = 0.2,
  }) async {
    // First try the specialized /predict/parts/ endpoint
    final partsUri = Uri.parse('$baseUrl/predict/parts/').replace(
      queryParameters: {
        if (predictColor) 'predict_color': 'true',
        'top_k_items': topK.toString(),
        if (predictColor) 'top_k_colors': '5',
        'min_similarity_items': minSimilarity.toString(),
      },
    );

    try {
      final result = await _executePredictRequest(
        uri: partsUri,
        imageBytes: imageBytes,
        filename: filename,
      );
      if (result.items.isNotEmpty) {
        return result;
      }
    } catch (_) {
      // Fall through to general predict endpoint
    }

    // Fallback to general /predict/ endpoint
    final generalUri = Uri.parse('$baseUrl/predict/').replace(
      queryParameters: {
        if (predictColor) 'predict_color': 'true',
        'top_k_items': topK.toString(),
        if (predictColor) 'top_k_colors': '5',
        'min_similarity_items': minSimilarity.toString(),
      },
    );

    return _executePredictRequest(
      uri: generalUri,
      imageBytes: imageBytes,
      filename: filename,
    );
  }

  /// Helper to predict from an XFile (ImagePicker result)
  Future<BrickognizePredictionResult> predictFromXFile(
    XFile file, {
    bool predictColor = true,
    int topK = 10,
    double minSimilarity = 0.2,
  }) async {
    final bytes = await file.readAsBytes();
    return predict(
      imageBytes: bytes,
      filename: file.name.isNotEmpty ? file.name : 'piece.jpg',
      predictColor: predictColor,
      topK: topK,
      minSimilarity: minSimilarity,
    );
  }

  Future<BrickognizePredictionResult> _executePredictRequest({
    required Uri uri,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';

    final mediaType = _resolveMediaType(filename);
    request.files.add(
      http.MultipartFile.fromBytes(
        'query_image',
        imageBytes,
        filename: filename,
        contentType: mediaType,
      ),
    );

    final streamedResponse = await _effectiveClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return const BrickognizePredictionResult(
          listingId: '',
          items: [],
          colors: [],
        );
      }
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return BrickognizePredictionResult.fromJson(jsonMap);
    }

    throw Exception(
      'Brickognize API request failed (${response.statusCode}): ${response.body}',
    );
  }
}
