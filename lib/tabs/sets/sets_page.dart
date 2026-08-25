import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/components/set_card.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class SetsPage extends HookConsumerWidget {
  const SetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsStreamProvider);
    final theme = Theme.of(context);

    final searchQuery = useState<String>('');
    final selectedFilter = useState<String>('all'); // all, building, backlog, built
    final searchController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEGO Sets'),
      ),
      body: setsAsync.when(
        data: (sets) {
          if (sets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Sets in Collection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sync your sets from Rebrickable in Settings to get started',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter by search query
          final query = searchQuery.value.trim().toLowerCase();
          final filteredSets = sets.where((s) {
            if (query.isEmpty) return true;
            return s.name.toLowerCase().contains(query) ||
                s.setNum.toLowerCase().contains(query);
          }).toList();

          final building = filteredSets.where((s) => s.status == LegoSetStatus.currentlyBuilding).toList();
          final backlog = filteredSets.where((s) => s.status == LegoSetStatus.backlog).toList();
          final built = filteredSets.where((s) => s.status == LegoSetStatus.built).toList();

          return CustomScrollView(
            slivers: [
              // Search & Filter header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // Search bar
                      TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search sets by name or #number...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          suffixIcon: searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    searchQuery.value = '';
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => searchQuery.value = value,
                      ),
                      const SizedBox(height: 12),
                      // Filter segmented button
                      M3ESegmentedButton<String>(
                        segments: [
                          M3ESegment(
                            value: 'all',
                            label: 'All (${filteredSets.length})',
                          ),
                          M3ESegment(
                            value: 'building',
                            label: 'Building (${building.length})',
                          ),
                          M3ESegment(
                            value: 'backlog',
                            label: 'Backlog (${backlog.length})',
                          ),
                          M3ESegment(
                            value: 'built',
                            label: 'Built (${built.length})',
                          ),
                        ],
                        selected: {selectedFilter.value},
                        onSelectionChanged: (val) {
                          if (val.isNotEmpty) selectedFilter.value = val.first;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Content based on filter
              if (filteredSets.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No matching sets found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (selectedFilter.value == 'all') ...[
                  if (building.isNotEmpty) ...[
                    _SectionHeader(title: 'Currently Building', count: building.length, color: const Color(0xFFF59E0B)),
                    _SetGridSliver(sets: building),
                  ],
                  if (backlog.isNotEmpty) ...[
                    _SectionHeader(title: 'Backlog', count: backlog.length, color: const Color(0xFF3B82F6)),
                    _SetGridSliver(sets: backlog),
                  ],
                  if (built.isNotEmpty) ...[
                    _SectionHeader(title: 'Built Sets', count: built.length, color: const Color(0xFF10B981)),
                    _SetGridSliver(sets: built),
                  ],
                ] else if (selectedFilter.value == 'building') ...[
                  _SetGridSliver(sets: building),
                ] else if (selectedFilter.value == 'backlog') ...[
                  _SetGridSliver(sets: backlog),
                ] else if (selectedFilter.value == 'built') ...[
                  _SetGridSliver(sets: built),
                ],
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
        loading: () => const Center(
          child: SizedBox.square(
            dimension: 36,
            child: M3EProgressIndicator.circular(),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading sets: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetGridSliver extends StatelessWidget {
  final List<LegoSet> sets;

  const _SetGridSliver({required this.sets});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final crossAxisCount = width < 500
            ? 1
            : width < 900
                ? 2
                : width < 1300
                    ? 3
                    : 4;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 16 / 11,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => SetCard(set: sets[index]),
              childCount: sets.length,
            ),
          ),
        );
      },
    );
  }
}
