import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/components/part_card.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/sets/details/options_modal.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends HookConsumerWidget {
  const DetailsPage({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setAsync = ref.watch(setStreamProvider(setId));
    final partsAsync = ref.watch(setPartsStreamProvider(setId));
    final sortOption = ref.watch(partSortProvider);
    final theme = Theme.of(context);

    final searchQuery = useState<String>('');
    final selectedFilter = useState<String>(
      'all',
    ); // all, missing, found, spares
    final searchController = useTextEditingController();

    final progress = useMemoized(() {
      final parts = partsAsync.value;
      if (parts == null || parts.isEmpty) return 0.0;
      return calculateProgress(parts);
    }, [partsAsync.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Details'),
        actions: [
          M3EIconButton(
            variant: M3EIconButtonVariant.tonal,
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                backgroundColor: Colors.transparent,
                builder: (_) => OptionsModal(setId: setId),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: setAsync.when(
        data: (set) {
          if (set == null) {
            return const Center(child: Text('Set not found'));
          }

          final allParts = partsAsync.value ?? <SetPart>[];
          final totalNeeded = allParts.fold<int>(
            0,
            (sum, p) => p.isSpare ? sum : sum + p.quantityNeeded,
          );
          final totalFound = allParts.fold<int>(
            0,
            (sum, p) => p.isSpare ? sum : sum + p.quantityFound,
          );

          final query = searchQuery.value.trim().toLowerCase();
          final filteredParts = allParts.where((part) {
            // Search filter
            if (query.isNotEmpty) {
              final nameMatch = (part.name ?? '').toLowerCase().contains(query);
              final idMatch = part.id.toString().contains(query);
              if (!nameMatch && !idMatch) return false;
            }
            // Category filter
            if (selectedFilter.value == 'missing') {
              return !part.isFinished && !part.isSpare;
            } else if (selectedFilter.value == 'found') {
              return part.isFinished && !part.isSpare;
            } else if (selectedFilter.value == 'spares') {
              return part.isSpare;
            }
            return true;
          }).toList();
          final sortedParts = sortParts(filteredParts, sortOption);

          final missingCount = allParts
              .where((p) => !p.isFinished && !p.isSpare)
              .length;
          final foundCount = allParts
              .where((p) => p.isFinished && !p.isSpare)
              .length;
          final sparesCount = allParts.where((p) => p.isSpare).length;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // Hero Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: M3ECard(
                    variant: M3ECardVariant.filled,
                    color: theme.colorScheme.surfaceContainer,
                    border: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top row: image + details + instructions
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 600;
                              final imageWidget = Container(
                                width: isCompact ? 95 : 120,
                                height: isCompact ? 95 : 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: set.imgUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: proxiedImageUrl(set.imgUrl!),
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => const Center(
                                          child: SizedBox.square(
                                            dimension: 24,
                                            child:
                                                M3EProgressIndicator.circular(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.extension_outlined,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.extension_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                              );

                              final infoWidget = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    set.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Set #${set.setNum}',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (set.year != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Year: ${set.year}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${allParts.length} parts',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );

                              if (isCompact) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        imageWidget,
                                        const SizedBox(width: 16),
                                        Expanded(child: infoWidget),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: M3EButton.tonal(
                                        onPressed: () => _openInstructions(
                                          context,
                                          ref,
                                          set,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.menu_book_rounded,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text('View Instructions'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  imageWidget,
                                  const SizedBox(width: 20),
                                  Expanded(child: infoWidget),
                                  const SizedBox(width: 16),
                                  M3EButton.tonal(
                                    onPressed: () =>
                                        _openInstructions(context, ref, set),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.menu_book_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Instructions'),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Status Switcher Segmented Button
                          Text(
                            'Build Status',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          M3ESegmentedButton<LegoSetStatus>(
                            segments: const [
                              M3ESegment(
                                value: LegoSetStatus.backlog,
                                label: 'Backlog',
                                icon: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                ),
                              ),
                              M3ESegment(
                                value: LegoSetStatus.currentlyBuilding,
                                label: 'Building',
                                icon: Icon(Icons.handyman_rounded, size: 16),
                              ),
                              M3ESegment(
                                value: LegoSetStatus.built,
                                label: 'Built',
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                ),
                              ),
                            ],
                            selected: {set.status},
                            onSelectionChanged: (val) {
                              if (val.isNotEmpty) {
                                updateSetStatus(set.id, val.first);
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // Progress Bar & Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Parts Found: $totalFound / $totalNeeded',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: getProgressColor(progress),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: M3EProgressIndicator.linearWavy(
                              value: progress,
                              color: getProgressColor(progress),
                              trackColor: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.35),
                              strokeWidth: 4,
                              trackStrokeWidth: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Filter & Search Toolbar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search parts by name or ID...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          suffixIcon: searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    searchQuery.value = '';
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => searchQuery.value = v,
                      ),
                      const SizedBox(height: 12),
                      M3ESegmentedButton<String>(
                        segments: [
                          M3ESegment(
                            value: 'all',
                            label: 'All (${allParts.length})',
                          ),
                          M3ESegment(
                            value: 'missing',
                            label: 'Missing ($missingCount)',
                          ),
                          M3ESegment(
                            value: 'found',
                            label: 'Found ($foundCount)',
                          ),
                          M3ESegment(
                            value: 'spares',
                            label: 'Spares ($sparesCount)',
                          ),
                        ],
                        selected: {selectedFilter.value},
                        onSelectionChanged: (val) {
                          if (val.isNotEmpty) selectedFilter.value = val.first;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sort by:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
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
                              selected: {sortOption},
                              onSelectionChanged: (val) {
                                if (val.isNotEmpty) {
                                  ref.read(partSortProvider.notifier).set(val.first);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Parts Grid
              if (sortedParts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No parts found matching filter',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final crossAxisCount = width < 600
                        ? 1
                        : width < 1050
                        ? 2
                        : width < 1500
                        ? 3
                        : 4;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final part = sortedParts[index];
                          return PartCard(key: ValueKey(part.id), part: part);
                        }, childCount: sortedParts.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: 80,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                      ),
                    );
                  },
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
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
            child: Text(
              'Error loading set: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openInstructions(
    BuildContext context,
    WidgetRef ref,
    LegoSet set,
  ) async {
    final key = await ref.read(bricksetApiKeyProvider.future);
    if (key == null || key.isEmpty) {
      if (context.mounted) {
        showSnack(context, 'Please set Brickset API Key in Settings');
      }
      return;
    }
    try {
      final url = await bricksetApi.getInstructions2(key, set.setNum);
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        showSnack(context, 'Unable to open instructions');
      }
    } catch (e) {
      if (context.mounted) {
        showSnack(context, 'Error loading instructions: $e');
      }
    }
  }
}
