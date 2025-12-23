import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/tabs/home/details/part_card.dart';
import 'package:lego_app/util.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends ConsumerWidget {
  const DetailsPage({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setAsync = ref.watch(setProvider(setId));
    final partsAsync = ref.watch(setPartsProvider(setId));
    final bricksetApiKey = ref.watch(bricksetApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Set Details')),
      body: setAsync.when(
        data: (set) {
          if (set == null) return const Center(child: Text('Set not found'));

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 600 ? 1 : (width / 300).floor().clamp(2, 6);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 150,
                    collapsedHeight: 150,
                    toolbarHeight: 150,
                    elevation: 0,
                    floating: true,
                    snap: true,

                    flexibleSpace: Card(
                      margin: const .all(8),
                      child: Padding(
                        padding: const .all(16),
                        child: Row(
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
                          ],
                        ),
                      ),
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
