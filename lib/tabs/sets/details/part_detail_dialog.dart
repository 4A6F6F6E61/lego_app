import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/rebrickable_providers.dart';
import 'package:lego_app/util.dart';

class PartDetailDialog extends ConsumerWidget {
  const PartDetailDialog({super.key, required this.part});
  final SetPart part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(colorsProvider);

    return AlertDialog(
      title: const Text("Part Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          part.imgUrl != null
              ? CachedNetworkImage(imageUrl: proxiedImageUrl(part.imgUrl!))
              : const Icon(Icons.extension, size: 100),
          const SizedBox(height: 16),
          Text(
            part.name ?? 'Unknown Part',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('Part ID: ${part.id}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Color: '),
              colorsAsync.when(
                data: (colors) {
                  final color = colors[part.colorId];
                  if (color == null) return Text('${part.colorId}');
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(int.parse('FF${color.rgb}', radix: 16)),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(color.name),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => Text('ERROR ${part.colorId}'),
              ),
            ],
          ),
          Text('Quantity Needed: ${part.quantityNeeded}'),
          Text('Quantity Found: ${part.quantityFound}'),
          Text('Is Spare: ${part.isSpare ? "Yes" : "No"}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            updatePartQuantityFound(part.id, part.quantityNeeded);
            context.pop();
          },
          child: const Text('Found all'),
        ),
        TextButton(
          onPressed: () {
            flagPartAsSpare(part.id, part.isSpare ? false : true);
            context.pop();
          },
          child: const Text('Toggle Spare'),
        ),
        TextButton(onPressed: context.pop, child: const Text('Close')),
      ],
    );
  }
}
