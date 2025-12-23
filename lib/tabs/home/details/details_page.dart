import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/tabs/home/details/part_card.dart';
import 'package:yaru/yaru.dart';

class DetailsPage extends ConsumerWidget {
  const DetailsPage({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(setPartsProvider(setId));
    return Scaffold(
      appBar: AppBar(title: Text('Set Details: ${setId}')),
      body: partsAsync.when(
        data: (parts) {
          if (parts.isEmpty) {
            return const Center(child: Text('No parts found for this set'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 600 ? 1 : (width / 300).floor().clamp(2, 6);

              return YaruScrollViewUndershoot.builder(
                builder: (context, controller) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 16 / 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    controller: controller,
                    itemCount: parts.length,
                    itemBuilder: (context, index) {
                      final part = parts[index];
                      return PartCard(part: part);
                    },
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
