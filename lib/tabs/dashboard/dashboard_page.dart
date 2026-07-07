import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/components/set_card.dart';
import 'package:yaru/yaru.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: setsAsync.when(
        data: (sets) {
          final building = sets.where((s) => s.status == LegoSetStatus.currentlyBuilding).toList();
          final totalParts =
              0; // TODO: Calculate total parts if available in LegoSet model or fetch separately
          final totalSets = sets.length;
          final builtSets = sets.where((s) => s.status == LegoSetStatus.built).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Section
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Sets',
                      value: totalSets.toString(),
                      icon: Icons.collections,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Built Sets',
                      value: builtSets.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Actions Section
              const Text('Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  // TODO: Implement Rebrickable sync logic
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Not Implemented'),
                      content: const Text('This feature is coming soon!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const YaruTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Add missing parts to Rebrickable'),
                  subtitle: Text(
                    'Sync missing parts from your sets to your Rebrickable wanted list',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Currently Building Section
              if (building.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Currently Building',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/sets'),
                      child: const Text('View All Sets'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: building.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(width: 280, child: SetCard(set: building[index]));
                    },
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'No active builds',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/sets'),
                      child: const Text('View All Sets'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
