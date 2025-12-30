import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/components/set_card.dart';
import 'package:yaru/yaru.dart';

class SetsPage extends ConsumerWidget {
  const SetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Sets')),
      body: setsAsync.when(
        data: (sets) {
          if (sets.isEmpty) {
            return const Center(child: Text('No sets in collection'));
          }

          final backlog = sets.where((s) => s.status == LegoSetStatus.backlog).toList();
          final building = sets.where((s) => s.status == LegoSetStatus.currentlyBuilding).toList();
          final built = sets.where((s) => s.status == LegoSetStatus.built).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 600 ? 1 : (width / 300).floor().clamp(2, 6);

              return YaruScrollViewUndershoot.builder(
                builder: (context, controller) {
                  return CustomScrollView(
                    controller: controller,
                    slivers: [
                      if (building.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Currently Building',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 16 / 10,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => SetCard(set: building[index]),
                              childCount: building.length,
                            ),
                          ),
                        ),
                      ],
                      if (backlog.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Backlog',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 16 / 10,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => SetCard(set: backlog[index]),
                              childCount: backlog.length,
                            ),
                          ),
                        ),
                      ],
                      if (built.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Built',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 16 / 10,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => SetCard(set: built[index]),
                              childCount: built.length,
                            ),
                          ),
                        ),
                      ],
                      const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                    ],
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
