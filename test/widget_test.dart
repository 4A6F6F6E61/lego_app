import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lego_app/components/part_card.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
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
        ),
        SetPart(
          id: 3,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3003',
          colorId: 3,
          quantityNeeded: 2,
          quantityFound: 0,
          isSpare: true, // Should be ignored in progress calculation
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
        ),
      ];
      expect(calculateProgress(parts), 1.0);
      expect(parts.first.isFinished, isTrue);
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
}
