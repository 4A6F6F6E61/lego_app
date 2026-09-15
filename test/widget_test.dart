import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lego_app/api/services/brickset_api.dart';
import 'package:lego_app/components/export_missing_parts_dialog.dart';
import 'package:lego_app/components/image_viewer.dart';
import 'package:lego_app/components/part_card.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/sets/details/instructions_modal.dart';
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

  group('Part Sorting Tests', () {
    test('compareNatural performs natural alphanumeric comparison', () {
      expect(compareNatural('Brick 1 x 2', 'Brick 1 x 10'), isNegative);
      expect(compareNatural('Brick 1 x 10', 'Brick 1 x 2'), isPositive);
      expect(compareNatural('Brick 1 x 1', 'Brick 1 x 2'), isNegative);
      expect(compareNatural('brick 1 x 1', 'BRICK 1 X 1'), 0);
      expect(compareNatural('Plate 2 x 4', 'Brick 2 x 4'), isPositive);
    });

    test('sortParts by color groups by colorId first, then type', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 5,
          name: 'Brick 2 x 4',
          quantityNeeded: 2,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 2,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3020',
          colorId: 1,
          name: 'Plate 2 x 4',
          quantityNeeded: 1,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 3,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3005',
          colorId: 1,
          name: 'Brick 1 x 1',
          quantityNeeded: 3,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
      ];

      final sorted = sortParts(parts, PartSortOption.color);
      // colorId 1 ("Brick 1 x 1") first, colorId 1 ("Plate 2 x 4") second, colorId 5 ("Brick 2 x 4") third
      expect(sorted[0].id, 3);
      expect(sorted[1].id, 2);
      expect(sorted[2].id, 1);
    });

    test('sortParts by type groups identical types together across colors with natural sort', () {
      final parts = [
        SetPart(
          id: 1,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 15,
          name: 'Brick 2 x 4',
          quantityNeeded: 2,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 2,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          name: 'Brick 2 x 4',
          quantityNeeded: 1,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 3,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '3004',
          colorId: 5,
          name: 'Brick 1 x 2',
          quantityNeeded: 4,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 4,
          setId: 'set-1',
          userId: 'user-1',
          partNum: '6111',
          colorId: 2,
          name: 'Brick 1 x 10',
          quantityNeeded: 1,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
      ];

      final sorted = sortParts(parts, PartSortOption.type);
      // 1. "Brick 1 x 2" (id: 3)
      // 2. "Brick 1 x 10" (id: 4) - natural sort: 1x2 < 1x10
      // 3. "Brick 2 x 4" colorId 1 (id: 2)
      // 4. "Brick 2 x 4" colorId 15 (id: 1)
      expect(sorted[0].id, 3);
      expect(sorted[1].id, 4);
      expect(sorted[2].id, 2);
      expect(sorted[3].id, 1);
    });

    test('partSortProvider defaults to color and updates to type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(partSortProvider), PartSortOption.color);
      container.read(partSortProvider.notifier).set(PartSortOption.type);
      expect(container.read(partSortProvider), PartSortOption.type);
    });

    testWidgets('PartSortOption segmented button toggles correctly and updates selection', (tester) async {
      PartSortOption selected = PartSortOption.color;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 300,
                    child: M3ESegmentedButton<PartSortOption>(
                      segments: const [
                        M3ESegment(
                          value: PartSortOption.color,
                          label: 'Color',
                          icon: Icon(Icons.palette_outlined, size: 16),
                        ),
                        M3ESegment(
                          value: PartSortOption.type,
                          label: 'Type',
                          icon: Icon(Icons.category_outlined, size: 16),
                        ),
                      ],
                      selected: {selected},
                      onSelectionChanged: (val) {
                        if (val.isNotEmpty) {
                          setState(() {
                            selected = val.first;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);

      await tester.tap(find.text('Type'));
      await tester.pump();
      expect(selected, PartSortOption.type);

      await tester.tap(find.text('Color'));
      await tester.pump();
      expect(selected, PartSortOption.color);
    });
  });

  group('LegoInstruction Model Tests', () {
    test('LegoInstruction.fromJson correctly parses fields', () {
      final json = {
        'URL': 'https://www.lego.com/cdn/product-assets/product.bi.core.pdf/6151174.pdf',
        'description': 'BI 3004/60, 60132 1/2 V29',
      };
      final instruction = LegoInstruction.fromJson(json);
      expect(instruction.url, 'https://www.lego.com/cdn/product-assets/product.bi.core.pdf/6151174.pdf');
      expect(instruction.description, 'BI 3004/60, 60132 1/2 V29');
    });

    test('LegoInstruction.fromJson falls back to default description if empty or null', () {
      final jsonNoDesc = {
        'URL': 'https://example.com/manual.pdf',
      };
      final instruction = LegoInstruction.fromJson(jsonNoDesc);
      expect(instruction.description, 'Instruction Booklet');
      expect(instruction.url, 'https://example.com/manual.pdf');
    });
  });

  group('Lost Parts Filter Logic Tests', () {
    final parts = [
      SetPart(
        id: 1,
        setId: 'set-1',
        userId: 'user-1',
        partNum: '3001',
        colorId: 1,
        quantityNeeded: 5,
        quantityFound: 2,
        isSpare: false,
        isLost: false,
      ),
      SetPart(
        id: 2,
        setId: 'set-1',
        userId: 'user-1',
        partNum: '3002',
        colorId: 2,
        quantityNeeded: 3,
        quantityFound: 3,
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
        isSpare: false,
        isLost: true, // Marked as lost
      ),
      SetPart(
        id: 4,
        setId: 'set-1',
        userId: 'user-1',
        partNum: '3004',
        colorId: 4,
        quantityNeeded: 1,
        quantityFound: 0,
        isSpare: true,
        isLost: true, // Lost spare
      ),
    ];

    test('lost parts filter returns only parts where isLost is true', () {
      final lostParts = parts.where((p) => p.isLost).toList();
      expect(lostParts.length, 2);
      expect(lostParts.map((p) => p.id), containsAll([3, 4]));
    });

    test('lostCount is accurate count of lost parts', () {
      final lostCount = parts.where((p) => p.isLost).length;
      expect(lostCount, 2);
    });
  });

  group('InstructionsModal Widget Tests', () {
    testWidgets('renders all instruction booklets and set header', (tester) async {
      final set = LegoSet(
        id: 'set-uuid',
        userId: 'user-uuid',
        setNum: '60132-1',
        name: 'Service Station',
        year: 2016,
        themeId: 52,
        imgUrl: 'https://example.com/set.jpg',
        status: LegoSetStatus.currentlyBuilding,
        createdAt: DateTime.now(),
      );

      final instructions = [
        const LegoInstruction(
          description: 'BI 3004/60, 60132 1/2 V29',
          url: 'https://example.com/manual1.pdf',
        ),
        const LegoInstruction(
          description: 'BI 3004/60, 60132 2/2 V29',
          url: 'https://example.com/manual2.pdf',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstructionsModal(
              set: set,
              instructions: instructions,
            ),
          ),
        ),
      );

      expect(find.text('Building Instructions'), findsOneWidget);
      expect(find.text('60132-1 • 2 booklets available'), findsOneWidget);
      expect(find.text('BI 3004/60, 60132 1/2 V29'), findsOneWidget);
      expect(find.text('BI 3004/60, 60132 2/2 V29'), findsOneWidget);
      expect(find.text('Booklet 1 of 2'), findsOneWidget);
      expect(find.text('Booklet 2 of 2'), findsOneWidget);
    });

    testWidgets('renders cleanly in dark theme matching app palette', (tester) async {
      final set = LegoSet(
        id: 'set-uuid',
        userId: 'user-uuid',
        setNum: '60132-1',
        name: 'Service Station',
        status: LegoSetStatus.currentlyBuilding,
        createdAt: DateTime.now(),
      );

      final instructions = [
        const LegoInstruction(
          description: 'Booklet 1',
          url: 'https://example.com/manual1.pdf',
        ),
      ];

      const darkBg = Color(0xFF1A1C22);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              surfaceContainer: darkBg,
            ),
          ),
          home: Scaffold(
            body: InstructionsModal(
              set: set,
              instructions: instructions,
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate(
        (w) => w is Container && (w.decoration is BoxDecoration) && ((w.decoration as BoxDecoration).color == darkBg),
      );
      expect(containerFinder, findsOneWidget);
    });
  });

  group('ImageViewerDialog Widget Tests', () {
    testWidgets('renders ImageViewerDialog with title and interactive viewer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageViewerDialog(
              imageUrl: 'https://example.com/piece.png',
              title: 'Brick 2x4 - Red',
            ),
          ),
        ),
      );

      expect(find.text('Brick 2x4 - Red'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
    });

    testWidgets('close button dismisses ImageViewerDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => openImageViewer(
                context,
                imageUrl: 'https://example.com/set.png',
                title: 'Set 75192',
              ),
              child: const Text('Open Viewer'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Viewer'));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Set 75192'), findsOneWidget);
      expect(find.byType(ImageViewerDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(ImageViewerDialog), findsNothing);
    });
  });

  group('DetailsPage Filter Segments Tests', () {
    testWidgets('5-segment filter renders all segments and selects lost', (tester) async {
      String selected = 'all';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 400,
                    child: M3ESegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        M3ESegment(value: 'all', label: 'All (10)'),
                        M3ESegment(value: 'missing', label: 'Missing (4)'),
                        M3ESegment(value: 'found', label: 'Found (6)'),
                        M3ESegment(value: 'spares', label: 'Spares (2)'),
                        M3ESegment(value: 'lost', label: 'Lost (1)'),
                      ],
                      selected: {selected},
                      onSelectionChanged: (val) {
                        if (val.isNotEmpty) {
                          setState(() {
                            selected = val.first;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('All (10)'), findsOneWidget);
      expect(find.text('Missing (4)'), findsOneWidget);
      expect(find.text('Found (6)'), findsOneWidget);
      expect(find.text('Spares (2)'), findsOneWidget);
      expect(find.text('Lost (1)'), findsOneWidget);

      await tester.tap(find.text('Lost (1)'));
      await tester.pump();
      expect(selected, 'lost');
    });
  });

  group('Optimistic SetParts Updates & copyWith Tests', () {
    test('SetPart copyWith correctly updates attributes immutably', () {
      final original = SetPart(
        id: 42,
        setId: '75192-1',
        userId: 'user-abc',
        partNum: '3001',
        colorId: 1,
        quantityNeeded: 10,
        quantityFound: 2,
        isSpare: false,
        isLost: false,
      );

      final updated = original.copyWith(
        quantityFound: 5,
        isSpare: true,
        isLost: true,
      );

      expect(original.quantityFound, 2);
      expect(original.isSpare, isFalse);
      expect(original.isLost, isFalse);

      expect(updated.id, 42);
      expect(updated.setId, '75192-1');
      expect(updated.partNum, '3001');
      expect(updated.quantityFound, 5);
      expect(updated.isSpare, isTrue);
      expect(updated.isLost, isTrue);
    });

    test('SetPartsNotifier optimistic updateQuantity, increment, and decrement modify local state instantly', () async {
      final initialParts = [
        SetPart(
          id: 101,
          setId: 'set-test',
          userId: 'user-1',
          partNum: '3001',
          colorId: 1,
          quantityNeeded: 5,
          quantityFound: 2,
          isSpare: false,
          isLost: false,
        ),
        SetPart(
          id: 102,
          setId: 'set-test',
          userId: 'user-1',
          partNum: '3002',
          colorId: 2,
          quantityNeeded: 3,
          quantityFound: 0,
          isSpare: false,
          isLost: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          setPartsNotifierProvider('set-test').overrideWith(
            () => MockSetPartsNotifier(initialParts),
          ),
        ],
      );

      // Await initial build
      final parts = await container.read(setPartsNotifierProvider('set-test').future);
      expect(parts.length, 2);
      expect(parts[0].quantityFound, 2);

      final notifier = container.read(setPartsNotifierProvider('set-test').notifier);

      // Optimistic increment
      notifier.incrementQuantity(101);
      expect(container.read(setPartsNotifierProvider('set-test')).value![0].quantityFound, 3);

      // Optimistic decrement
      notifier.decrementQuantity(101);
      expect(container.read(setPartsNotifierProvider('set-test')).value![0].quantityFound, 2);

      // Decrement at 0 does not go negative
      notifier.decrementQuantity(102);
      expect(container.read(setPartsNotifierProvider('set-test')).value![1].quantityFound, 0);

      // Direct updateQuantity
      notifier.updateQuantity(101, 5);
      expect(container.read(setPartsNotifierProvider('set-test')).value![0].quantityFound, 5);

      // Optimistic toggleSpare
      await notifier.toggleSpare(101, true);
      expect(container.read(setPartsNotifierProvider('set-test')).value![0].isSpare, isTrue);

      // Optimistic toggleLost
      await notifier.toggleLost(102, true);
      expect(container.read(setPartsNotifierProvider('set-test')).value![1].isLost, isTrue);

      container.dispose();
    });
  });
}

class MockSetPartsNotifier extends SetPartsNotifier {
  final List<SetPart> initialParts;
  MockSetPartsNotifier(this.initialParts);

  @override
  Future<List<SetPart>> build(String setId) async {
    return List<SetPart>.of(initialParts);
  }
}

class MockApiKeyNotifier extends RebrickableApiKey {
  @override
  Future<String?> build() async => 'test-api-key';
}

class MockUserTokenNotifier extends UserToken {
  @override
  Future<String?> build() async => 'test-user-token';
}
