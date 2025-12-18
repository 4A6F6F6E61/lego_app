import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:yaru/yaru.dart';

class PartCard extends StatelessWidget {
  const PartCard({super.key, required this.part});

  final SetPart part;

  Future<void> _showPartDetails(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => _PartDetailDialog(part: part),
    );
  }

  Future<void> cycleQuantityFound() async {
    if (part.isFinished) {
      await supabase.from('set_parts').update({'quantity_found': 0}).eq('id', part.id);
      return;
    }

    await supabase
        .from('set_parts')
        .update({'quantity_found': part.quantityFound + 1})
        .eq('id', part.id);
  }

  @override
  Widget build(BuildContext context) {
    final finishedColor = Theme.of(context).colorScheme.success.withOpacity(0.38);
    return YaruBorderContainer(
      clipBehavior: Clip.antiAlias,
      color: part.isFinished ? finishedColor : null,
      child: InkWell(
        onTap: () async {
          await cycleQuantityFound();
        },
        child: YaruTile(
          title: Text(part.name ?? 'Unknown Part', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('Found: ${part.quantityFound} / ${part.quantityNeeded}'),
          leading: part.imgUrl != null
              ? CachedNetworkImage(
                  imageUrl: part.imgUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                )
              : const Icon(Icons.extension),
          trailing: YaruIconButton(
            icon: const Icon(YaruIcons.information),
            onPressed: () async {
              await _showPartDetails(context);
            },
          ),
        ),
      ),
    );
  }
}

class _PartDetailDialog extends StatelessWidget {
  const _PartDetailDialog({required this.part});
  final SetPart part;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Part Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          part.imgUrl != null
              ? CachedNetworkImage(imageUrl: part.imgUrl!)
              : const Icon(Icons.extension, size: 100),
          const SizedBox(height: 16),
          Text(part.name ?? 'Unknown Part', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Part ID: ${part.id}'),
          Text('Color ID: ${part.colorId}'),
        ],
      ),
      actions: [TextButton(onPressed: context.pop, child: const Text('Close'))],
    );
  }
}
