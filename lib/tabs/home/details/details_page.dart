import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/home/details/part_card.dart';
import 'package:lego_app/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

class DetailsPage extends HookConsumerWidget {
  DetailsPage({super.key, required this.setId});

  final String setId;

  final GlobalKey _headerKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setAsync = ref.watch(setProvider(setId));
    final partsAsync = ref.watch(setPartsProvider(setId));
    final bricksetApiKey = ref.watch(bricksetApiKeyProvider);

    final headerHeight = useState<double>(170);
    final progress = useMemoized(() {
      final parts = partsAsync.value;
      if (parts == null || parts.isEmpty) return 0.0;
      return calculateProgress(parts);
    }, [partsAsync]);
    final progressBarColor = useMemoized(() {
      final scheme = Theme.of(context).colorScheme;
      if (progress <= 0.0) return scheme.error;
      if (progress >= 1.0) return scheme.success;
      if (progress < 0.5) {
        final t = progress / 0.5;
        return Color.lerp(scheme.error, scheme.warning, t)!;
      }
      final t = (progress - 0.5) / 0.5;
      return Color.lerp(scheme.warning, scheme.success, t)!;
    }, [progress]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _headerKey.currentContext;
      if (context != null) {
        final height = context.size?.height;
        if (height != null && height != headerHeight.value) {
          headerHeight.value = height;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Set Details')),
      body: setAsync.when(
        data: (set) {
          if (set == null) return const Center(child: Text('Set not found'));

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 600 ? 1 : (width / 300).floor().clamp(2, 6);

              final headerCard = Card(
                margin: const .all(8),
                child: Padding(
                  padding: const .all(16),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          if (set.imgUrl != null)
                            CachedNetworkImage(
                              imageUrl: proxiedImageUrl(set.imgUrl!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  set.name,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  maxLines: 2,
                                  overflow: .ellipsis,
                                ),
                                Text('Set: ${set.setNum}'),
                                Text('Year: ${set.year ?? "Unknown"}'),
                                Text('Parts: ${partsAsync.value?.length ?? "Unknown"}'),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final key = bricksetApiKey.value;
                                  if (key == null || key.isEmpty) {
                                    showSnack(context, 'Please set Brickset API Key in settings');
                                    return;
                                  }
                                  try {
                                    final url = await bricksetApi.getInstructions2(key, set.setNum);

                                    await launchUrl(Uri.parse(url));
                                  } catch (e) {
                                    if (context.mounted) {
                                      showSnack(context, 'Error: $e');
                                    }
                                  }
                                },
                                icon: const Icon(Icons.menu_book),
                                label: const Text('Instructions'),
                              ),
                              const SizedBox(height: 8),
                              YaruPopupMenuButton<LegoSetStatus>(
                                initialValue: set.status,
                                onSelected: (LegoSetStatus? newValue) {
                                  if (newValue != null) {
                                    updateSetStatus(set.id, newValue);
                                  }
                                },
                                itemBuilder: (context) {
                                  return [
                                    for (final value in LegoSetStatus.values)
                                      PopupMenuItem(value: value, child: Text(value.name)),
                                  ];
                                },
                                child: Text(set.status.name),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const .only(top: 16),
                        child: YaruLinearProgressIndicator(
                          value: progress,
                          semanticsLabel: 'Progress',
                          strokeWidth: 8,
                          color: progressBarColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              return Stack(
                children: [
                  Offstage(
                    child: SingleChildScrollView(
                      child: Container(
                        width: width,
                        padding: EdgeInsets.zero,
                        child: Container(key: _headerKey, child: headerCard),
                      ),
                    ),
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        expandedHeight: headerHeight.value,
                        collapsedHeight: headerHeight.value,
                        toolbarHeight: headerHeight.value,
                        elevation: 0,
                        floating: true,
                        snap: true,
                        flexibleSpace: headerCard,
                      ),
                      partsAsync.when(
                        data: (parts) {
                          if (parts.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(child: Text('No parts found for this set')),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((context, index) {
                                final part = parts[index];
                                return PartCard(part: part);
                              }, childCount: parts.length),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 16 / 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                            ),
                          );
                        },
                        loading: () => const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => SliverFillRemaining(
                          child: Center(child: Text('Error loading parts: $error')),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading set: $error')),
      ),
    );
  }
}
