import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lego_app/api/services/brickognize_api.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/tabs/scanner/scanner_page.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Brickognize Models & Parsing Tests', () {
    test('BrickognizeItem.fromJson parses item correctly', () {
      final json = {
        'id': '3001',
        'name': 'Brick 2 x 4',
        'img_url': 'https://storage.googleapis.com/brickognize-static/thumbnails/v2.23/part/3001/0.webp',
        'category': 'Brick',
        'type': 'part',
        'score': 0.840456,
        'external_sites': [
          {
            'name': 'bricklink',
            'url': 'https://www.bricklink.com/v2/catalog/catalogitem.page?P=3001',
          },
        ],
      };

      final item = BrickognizeItem.fromJson(json);
      expect(item.id, '3001');
      expect(item.name, 'Brick 2 x 4');
      expect(item.category, 'Brick');
      expect(item.type, 'part');
      expect(item.score, closeTo(0.84, 0.01));
      expect(item.externalSites.length, 1);
      expect(item.externalSites.first.name, 'bricklink');
      expect(item.externalSites.first.url, contains('3001'));
    });

    test('BrickognizeColor.fromJson parses color correctly', () {
      final json = {
        'id': '85',
        'name': 'Dark Bluish Gray',
        'score': 0.6638,
      };

      final color = BrickognizeColor.fromJson(json);
      expect(color.id, '85');
      expect(color.name, 'Dark Bluish Gray');
      expect(color.score, closeTo(0.66, 0.01));
    });

    test('BrickognizeBoundingBox.fromJson parses coordinates correctly', () {
      final json = {
        'left': 5.98,
        'upper': 6.45,
        'right': 291.53,
        'lower': 213.25,
        'image_width': 300.0,
        'image_height': 224.0,
        'score': 0.937,
      };

      final box = BrickognizeBoundingBox.fromJson(json);
      expect(box.left, closeTo(5.98, 0.01));
      expect(box.imageWidth, 300.0);
      expect(box.score, closeTo(0.937, 0.001));
    });

    test('BrickognizePredictionResult.fromJson parses full prediction payload', () {
      final json = {
        'listing_id': 'res-f73bc486',
        'bounding_box': {
          'left': 1.0,
          'upper': 2.0,
          'right': 30.0,
          'lower': 40.0,
          'image_width': 100.0,
          'image_height': 100.0,
          'score': 0.95,
        },
        'items': [
          {
            'id': '3001',
            'name': 'Brick 2 x 4',
            'img_url': 'https://example.com/3001.webp',
            'category': 'Brick',
            'type': 'part',
            'score': 0.92,
            'external_sites': [],
          },
          {
            'id': '3002',
            'name': 'Brick 2 x 3',
            'img_url': 'https://example.com/3002.webp',
            'category': 'Brick',
            'type': 'part',
            'score': 0.45,
            'external_sites': [],
          },
        ],
        'colors': [
          {
            'id': '85',
            'name': 'Dark Bluish Gray',
            'score': 0.75,
          },
        ],
      };

      final result = BrickognizePredictionResult.fromJson(json);
      expect(result.listingId, 'res-f73bc486');
      expect(result.items.length, 2);
      expect(result.items[0].id, '3001');
      expect(result.items[1].id, '3002');
      expect(result.colors.length, 1);
      expect(result.colors[0].name, 'Dark Bluish Gray');
      expect(result.boundingBox, isNotNull);
    });
  });

  group('BrickognizeApi HTTP Client Tests', () {
    test('predict calls predict endpoint and parses results successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('/predict/parts/'));
        expect(request.url.queryParameters['predict_color'], 'true');

        final responseBody = jsonEncode({
          'listing_id': 'test-123',
          'items': [
            {
              'id': '3001',
              'name': 'Brick 2 x 4',
              'img_url': 'https://example.com/3001.webp',
              'category': 'Brick',
              'type': 'part',
              'score': 0.94,
              'external_sites': [
                {
                  'name': 'bricklink',
                  'url': 'https://www.bricklink.com/v2/catalog/catalogitem.page?P=3001',
                },
              ],
            },
          ],
          'colors': [
            {'id': '4', 'name': 'Red', 'score': 0.88},
          ],
        });

        return http.Response(responseBody, 200, headers: {'content-type': 'application/json'});
      });

      final api = BrickognizeApi(client: mockClient);
      final result = await api.predict(
        imageBytes: Uint8List.fromList([1, 2, 3, 4]),
        filename: 'brick.jpg',
      );

      expect(result.listingId, 'test-123');
      expect(result.items.length, 1);
      expect(result.items.first.id, '3001');
      expect(result.items.first.name, 'Brick 2 x 4');
      expect(result.colors.first.name, 'Red');
    });

    test('predict handles empty items response gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'listing_id': 'empty-1', 'items': [], 'colors': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = BrickognizeApi(client: mockClient);
      final result = await api.predict(
        imageBytes: Uint8List.fromList([0, 0, 0]),
        filename: 'empty.png',
      );

      expect(result.items, isEmpty);
      expect(result.colors, isEmpty);
    });
  });

  group('PartSetMatch Aggregation Tests', () {
    final testSet = LegoSet(
      id: 'set-123',
      userId: 'user-1',
      setNum: '7897-1',
      name: 'Passenger Train',
      year: 2006,
      themeId: 1,
      createdAt: DateTime.now(),
      status: LegoSetStatus.currentlyBuilding,
    );

    test('PartSetMatch calculates total quantities and completeness across colors', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-123',
          userId: 'user-1',
          partNum: '3001',
          colorId: 0, // Black
          quantityNeeded: 2,
          quantityFound: 2,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 2,
          setId: 'set-123',
          userId: 'user-1',
          partNum: '3001',
          colorId: 4, // Red
          quantityNeeded: 4,
          quantityFound: 1,
          isSpare: false,
          isLost: false,
        ),
      ];

      final match = PartSetMatch(set: testSet, parts: parts);
      expect(match.totalQuantityNeeded, 6);
      expect(match.totalQuantityFound, 3);
      expect(match.isFullyFound, isFalse);
    });

    test('PartSetMatch isFullyFound returns true when all parts found', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-123',
          userId: 'user-1',
          partNum: '3001',
          colorId: 0,
          quantityNeeded: 2,
          quantityFound: 2,
          isSpare: false,
          isLost: false,
        ),
      ];

      final match = PartSetMatch(set: testSet, parts: parts);
      expect(match.totalQuantityNeeded, 2);
      expect(match.totalQuantityFound, 2);
      expect(match.isFullyFound, isTrue);
    });
  });

  group('ScannerPage UI Tests', () {
    testWidgets('renders initial ScannerPage with capture actions and instructions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: M3ETheme(
            data: M3EThemeData.light(seedColor: const Color(0xFF0266C8)),
            child: const MaterialApp(
              home: ScannerPage(),
            ),
          ),
        ),
      );

      expect(find.text('Brickognize Scanner'), findsOneWidget);
      expect(find.text('LEGO Piece Recognition'), findsOneWidget);
      expect(find.text('Ready to Scan a Brick'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Pick Image'), findsOneWidget);
    });
  });

  group('Color Matching & Prioritization Tests', () {
    final mockColorsMap = <int, dynamic>{
      72: _MockRebrickableColor(id: 72, name: 'Dark Bluish Gray', rgb: '6C6E68'),
      4: _MockRebrickableColor(id: 4, name: 'Red', rgb: 'C91A09'),
      0: _MockRebrickableColor(id: 0, name: 'Black', rgb: '05131D'),
      15: _MockRebrickableColor(id: 15, name: 'White', rgb: 'FFFFFF'),
    };

    test('isColorMatch matches normalized color names across Rebrickable and Brickognize', () {
      // Brickognize uses BL color id (85) and name "Dark Bluish Gray"
      // Rebrickable uses color id (72) and name "Dark Bluish Gray"
      final predictedColor = BrickognizeColor(id: '85', name: 'Dark Bluish Gray', score: 0.9);

      // Matches by name even with different IDs
      expect(isColorMatch(72, predictedColor, mockColorsMap), isTrue);
      // Does not match Red or Black
      expect(isColorMatch(4, predictedColor, mockColorsMap), isFalse);
      expect(isColorMatch(0, predictedColor, mockColorsMap), isFalse);
    });

    test('isColorMatch normalizes hyphens, underscores and casing', () {
      final mapWithHyphens = <int, dynamic>{
        72: _MockRebrickableColor(id: 72, name: 'Dark-Bluish_Gray', rgb: '6C6E68'),
      };
      final predictedColor = BrickognizeColor(id: '85', name: 'dark bluish gray', score: 0.85);

      expect(isColorMatch(72, predictedColor, mapWithHyphens), isTrue);
    });

    test('isColorMatch falls back to ID match when colorInfo not found in map', () {
      final predictedColor = BrickognizeColor(id: '999', name: 'Custom Rare Color', score: 0.7);

      expect(isColorMatch(999, predictedColor, mockColorsMap), isTrue);
      expect(isColorMatch(888, predictedColor, mockColorsMap), isFalse);
    });

    test('isColorMatch returns false when predictedColor is null', () {
      expect(isColorMatch(72, null, mockColorsMap), isFalse);
    });

    test('BrickLink URL includes #C={colorId} when color is detected', () {
      const originalUrl = 'https://www.bricklink.com/v2/catalog/catalogitem.page?P=3001';
      final detectedColor = BrickognizeColor(id: '85', name: 'Dark Bluish Gray', score: 0.92);

      final base = originalUrl.split('#').first;
      final targetUrl = '$base#C=${detectedColor.id}';

      expect(targetUrl, 'https://www.bricklink.com/v2/catalog/catalogitem.page?P=3001#C=85');
    });

    test('Sets are sorted so sets containing the matching color appear first', () {
      final detectedColor = BrickognizeColor(id: '85', name: 'Dark Bluish Gray', score: 0.95);

      final set1 = LegoSet(
        id: 'set-1',
        userId: 'u1',
        setNum: '1001-1',
        name: 'Set without predicted color',
        createdAt: DateTime.now(),
        status: LegoSetStatus.built,
      );
      final set2 = LegoSet(
        id: 'set-2',
        userId: 'u1',
        setNum: '1002-1',
        name: 'Set with predicted color',
        createdAt: DateTime.now(),
        status: LegoSetStatus.built,
      );

      final match1 = PartSetMatch(
        set: set1,
        parts: [
          SetPart(
            id: 1,
            setId: 'set-1',
            userId: 'u1',
            partNum: '3001',
            colorId: 4, // Red
            quantityNeeded: 2,
            quantityFound: 0,
            isSpare: false,
            isLost: false,
          ),
        ],
      );

      final match2 = PartSetMatch(
        set: set2,
        parts: [
          SetPart(
            id: 2,
            setId: 'set-2',
            userId: 'u1',
            partNum: '3001',
            colorId: 72, // Dark Bluish Gray
            quantityNeeded: 2,
            quantityFound: 0,
            isSpare: false,
            isLost: false,
          ),
        ],
      );

      final list = [match1, match2];
      list.sort((a, b) {
        final aHasColor = a.parts.any((p) => isColorMatch(p.colorId, detectedColor, mockColorsMap));
        final bHasColor = b.parts.any((p) => isColorMatch(p.colorId, detectedColor, mockColorsMap));
        if (aHasColor && !bHasColor) return -1;
        if (!aHasColor && bHasColor) return 1;
        return a.set.name.compareTo(b.set.name);
      });

      expect(list.first.set.id, 'set-2');
      expect(list.last.set.id, 'set-1');
    });

    test('Parts within a set sort the matching color variant first', () {
      final detectedColor = BrickognizeColor(id: '85', name: 'Dark Bluish Gray', score: 0.95);

      final parts = [
        SetPart(
          id: 10,
          setId: 'set-1',
          userId: 'u1',
          partNum: '3001',
          colorId: 4, // Red
          quantityNeeded: 5,
          quantityFound: 2,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 11,
          setId: 'set-1',
          userId: 'u1',
          partNum: '3001',
          colorId: 72, // Dark Bluish Gray
          quantityNeeded: 3,
          quantityFound: 1,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 12,
          setId: 'set-1',
          userId: 'u1',
          partNum: '3001',
          colorId: 0, // Black
          quantityNeeded: 1,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
      ];

      parts.sort((a, b) {
        final aMatch = isColorMatch(a.colorId, detectedColor, mockColorsMap);
        final bMatch = isColorMatch(b.colorId, detectedColor, mockColorsMap);
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return a.colorId.compareTo(b.colorId);
      });

      expect(parts.first.colorId, 72); // Dark Bluish Gray is first!
    });
  });
}

class _MockRebrickableColor {
  final int id;
  final String name;
  final String rgb;

  _MockRebrickableColor({
    required this.id,
    required this.name,
    required this.rgb,
  });
}
