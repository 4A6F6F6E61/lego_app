import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/components/part_card.dart';
import 'package:lego_app/tabs/sets/details/options_modal.dart';
import 'package:lego_app/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

class DetailsPage extends HookConsumerWidget {
  DetailsPage({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setAsync = ref.watch(setStreamProvider(setId));
    final partsAsync = ref.watch(setPartsStreamProvider(setId));
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Details'),
        actions: [
          IconButton(
            icon: const Icon(YaruIcons.view_more),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                builder: (_) => OptionsModal(setId: setId),
              );
            },
          ),
        ],
      ),
      body: setAsync.when(
        data: (set) {
          if (set == null) return const Center(child: Text('Set not found'));

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 600 ? 1 : (width / 300).floor().clamp(2, 6);

              const headerExtentPadding = 4.0;

              final headerCard = MeasureSize(
                onChange: (size) {
                  final contentHeight = (size.height - headerExtentPadding).clamp(
                    0.0,
                    double.infinity,
                  );
                  if (contentHeight > 0 && contentHeight != headerHeight.value) {
                    headerHeight.value = contentHeight;
                  }
                },
                child: Card(
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
                                      final url = await bricksetApi.getInstructions2(
                                        key,
                                        set.setNum,
                                      );

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
                ),
              );

              final headerExtent = headerHeight.value + headerExtentPadding;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: headerExtent,
                    collapsedHeight: headerExtent,
                    toolbarHeight: headerExtent,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    flexibleSpace: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(width: width, child: headerCard),
                    ),
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
                            return PartCard(key: ValueKey(part.id), part: part);
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

class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({super.key, required this.onChange, super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) => _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(BuildContext context, covariant _MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
