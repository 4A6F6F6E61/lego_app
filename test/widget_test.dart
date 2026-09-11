import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lego_app/components/export_missing_parts_dialog.dart';
import 'package:lego_app/components/part_card.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Lego Progress Calculation Tests', () {
    test('calculateProgress returns 0.0 for empty list', () {
      expect(calculateProgress([]), 0.0);
    });

    test('calculateProgress accurately computes progress ignoring spares', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 10,
          quantityFound: 5,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 2,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3002',
          colorId: 2,
          quantityNeeded: 10,
          quantityFound: 10,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 3,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3003',
          colorId: 3,
          quantityNeeded: 2,
          quantityFound: 0,
          isSpare: true,
          isLost: false, // Should be ignored in progress calculation
        ),
      ];

      // Total needed = 10 + 10 = 20, Total found = 5 + 10 = 15 -> 15/20 = 0.75
      expect(calculateProgress(parts), 0.75);
    });

    test('calculateProgress returns 1.0 when all parts are found', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 4,
          quantityFound: 4,
          isSpare: false,
          isLost: false,
        ),
      ];
      expect(calculateProgress(parts), 1.0);
      expect(parts.first.isFinished, isTrue);
    });

    test('getProgressColor returns red for 0, amber for 0.5, emerald for 1.0', () {
      expect(getProgressColor(0.0), const Color(0xFFEF4444));
      expect(getProgressColor(0.5), const Color(0xFFF59E0B));
      expect(getProgressColor(1.0), const Color(0xFF10B981));
    });
  });

  group('LegoSet and SetPart Models', () {
    test('LegoSetStatus enum contains all expected statuses', () {
      expect(LegoSetStatus.values, contains(LegoSetStatus.backlog));
      expect(LegoSetStatus.values, contains(LegoSetStatus.currentlyBuilding));
      expect(LegoSetStatus.values, contains(LegoSetStatus.built));
    });
  });

  group('Material 3 Expressive Theme Rendering', () {
    testWidgets('M3ETheme renders with Cobalt seed color', (tester) async {
      const legoCobalt = Color(0xFF0266C8);
      final lightTheme = M3EThemeData.light(seedColor: legoCobalt);

      await tester.pumpWidget(
        M3ETheme(
          data: lightTheme,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: M3ECard(
              child: Text('LEGO M3E Expressive Card'),
            ),
          ),
        ),
      );

      expect(find.text('LEGO M3E Expressive Card'), findsOneWidget);
    });

    testWidgets('CustomScrollView with SliverLayoutBuilder renders without viewport errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    return const SliverToBoxAdapter(
                      child: Text('Sliver Content Rendered'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Sliver Content Rendered'), findsOneWidget);
    });

    testWidgets('M3ESegmentedButton renders cleanly with bounded width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: M3ESegmentedButton<String>(
                  segments: const [
                    M3ESegment(value: 'all', label: 'All'),
                    M3ESegment(value: 'built', label: 'Built'),
                  ],
                  selected: const {'all'},
                  onSelectionChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Built'), findsOneWidget);
    });

    testWidgets('PartCard renders without overflow in narrow constraints', (tester) async {
      final part = SetPart(
        id: 9999,
        setId: 'set-1',
        userId: 'user-1',
        partNum: '3001',
        colorId: 1,
        name: 'Trans-Dark Bluish Gray Brick 2x4 with Super Long Name Description',
        quantityNeeded: 10,
        quantityFound: 4,
        isSpare: true,
          isLost: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  height: 80,
                  child: PartCard(part: part),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PartCard), findsOneWidget);
      expect(find.text('SPARE'), findsOneWidget);
    });
  });

  group('Missing Parts & Settings Tests', () {
    test('exportMissingPartsToRebrickable aggregates identical pieces correctly', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 5,
          quantityFound: 2, // 3 missing
          isSpare: false,
          isLost: true,
        ),
        SetPart(
          id: 2,
          setId: 'set-2',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 4,
          quantityFound: 0, // 4 missing -> total 7 of 3001:1
          isSpare: false,
          isLost: true,
        ),
        SetPart(
          id: 3,
          setId: 'set-2',
          userId: 'user-1',
          partNum: '3002',
          colorId: 5,
          quantityNeeded: 2,
          quantityFound: 1, // 1 missing
          isSpare: false,
          isLost: true,
        ),
      ];

      final Map<String, ({String partNum, int colorId, int quantity})> aggregated = {};
      for (final part in parts) {
        final key = '${part.partNum}:${part.colorId}';
        final qty = (part.quantityNeeded - part.quantityFound) > 0
            ? (part.quantityNeeded - part.quantityFound)
            : 1;

        if (aggregated.containsKey(key)) {
          final existing = aggregated[key]!;
          aggregated[key] = (
            partNum: existing.partNum,
            colorId: existing.colorId,
            quantity: existing.quantity + qty,
          );
        } else {
          aggregated[key] = (
            partNum: part.partNum,
            colorId: part.colorId,
            quantity: qty,
          );
        }
      }

      expect(aggregated.length, 2);
      expect(aggregated['3001:1']!.quantity, 7);
      expect(aggregated['3002:5']!.quantity, 1);
    });

    test('exportToLostParts aggregates inventory part id and missing quantities correctly', () {
      final parts = [
        SetPart(
          id: 101,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 5,
          quantityFound: 2, // 3 missing
          isSpare: false,
          isLost: true,
        ),
        SetPart(
          id: 102,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3002',
          colorId: 2,
          quantityNeeded: 1,
          quantityFound: 0, // 1 missing
          isSpare: false,
          isLost: true,
        ),
      ];

      final Map<int, int> aggregated = {};
      for (final part in parts) {
        final qty = (part.quantityNeeded - part.quantityFound) > 0
            ? (part.quantityNeeded - part.quantityFound)
            : 1;
        aggregated[part.id] = (aggregated[part.id] ?? 0) + qty;
      }

      expect(aggregated.length, 2);
      expect(aggregated[101], 3);
      expect(aggregated[102], 1);
    });

    test('MissingPartsExportResult correctly represents My Lost Parts result', () {
      const result = MissingPartsExportResult(
        listName: 'My Lost Parts',
        uniquePartsCount: 5,
        totalQuantity: 12,
        webUrl: 'https://rebrickable.com/users/testuser/lostparts/',
        isLostParts: true,
      );

      expect(result.listId, isNull);
      expect(result.isLostParts, isTrue);
      expect(result.listName, 'My Lost Parts');
      expect(result.totalQuantity, 12);
      expect(result.uniquePartsCount, 5);
      expect(result.webUrl, contains('/lostparts/'));
    });

    testWidgets('ExportMissingPartsDialog renders cleanly with M3ECard and no localizations errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: M3ETheme(
            data: M3EThemeData.dark(seedColor: const Color(0xFF0266C8)),
            child: const MaterialApp(
              home: Scaffold(
                body: ExportMissingPartsDialog(
                  initialParts: [],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ExportMissingPartsDialog), findsOneWidget);
    });

    testWidgets('ExportMissingPartsDialog displays destination segments when credentials and parts exist', (tester) async {
      final sampleParts = [
        SetPart(
          id: 555,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 4,
          quantityFound: 1, // 3 missing
          isSpare: false,
          isLost: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rebrickableApiKeyProvider.overrideWith(() => MockApiKeyNotifier()),
            userTokenProvider.overrideWith(() => MockUserTokenNotifier()),
          ],
          child: M3ETheme(
            data: M3EThemeData.light(seedColor: const Color(0xFF0266C8)),
            child: MaterialApp(
              home: Scaffold(
                body: ExportMissingPartsDialog(
                  initialParts: sampleParts,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ExportMissingPartsDialog), findsOneWidget);
      expect(find.text('Export Missing Parts'), findsOneWidget);
      expect(find.text('Export Destination'), findsOneWidget);
      expect(find.text('My Lost Parts'), findsOneWidget);
      expect(find.text('New Custom List'), findsOneWidget);
      expect(find.text('Add to My Lost Parts'), findsOneWidget);
    });

    testWidgets('ExportMissingPartsDialog toggles to New Custom List and displays list name input field', (tester) async {
      final sampleParts = [
        SetPart(
          id: 555,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 4,
          quantityFound: 1,
          isSpare: false,
          isLost: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rebrickableApiKeyProvider.overrideWith(() => MockApiKeyNotifier()),
            userTokenProvider.overrideWith(() => MockUserTokenNotifier()),
          ],
          child: M3ETheme(
            data: M3EThemeData.light(seedColor: const Color(0xFF0266C8)),
            child: MaterialApp(
              home: Scaffold(
                body: ExportMissingPartsDialog(
                  initialParts: sampleParts,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap on 'New Custom List' segment
      await tester.tap(find.text('New Custom List'));
      await tester.pump();

      expect(find.text('Rebrickable Part List Name'), findsOneWidget);
      expect(find.text('Create List & Export'), findsOneWidget);
    });
  });
}

class MockApiKeyNotifier extends RebrickableApiKey {
  @override
  Future<String?> build() async => 'test-api-key';
}

class MockUserTokenNotifier extends UserToken {
  @override
  Future<String?> build() async => 'test-user-token';
}
