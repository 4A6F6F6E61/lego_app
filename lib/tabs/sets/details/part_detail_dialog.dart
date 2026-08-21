import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/rebrickable_providers.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class PartDetailDialog extends ConsumerWidget {
  const PartDetailDialog({super.key, required this.part});
  final SetPart part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(colorsProvider);
    final theme = Theme.of(context);

    Color? legoColor;
    String? colorName;
    if (colorsAsync.hasValue) {
      final colorInfo = colorsAsync.value![part.colorId];
      if (colorInfo != null) {
        colorName = colorInfo.name;
        legoColor = Color(int.parse('FF${colorInfo.rgb}', radix: 16));
      }
    }

    final double partProgress = part.quantityNeeded > 0
        ? (part.quantityFound / part.quantityNeeded).clamp(0.0, 1.0)
        : 0.0;

    return M3EDialog(
      title: 'Part Details',
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Part Image Card
            Center(
              child: Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: part.imgUrl != null
                    ? CachedNetworkImage(
                        imageUrl: proxiedImageUrl(part.imgUrl!),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: SizedBox.square(
                            dimension: 24,
                            child: M3EProgressIndicator.circular(),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.extension_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.extension_outlined, size: 48, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Part Name
            Text(
              part.name ?? 'Unknown Part',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Part ID: ${part.id}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Color Chip & Spare Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Color',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (legoColor != null)
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: legoColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            colorName ?? '${part.colorId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${part.quantityFound} of ${part.quantityNeeded} found',
                        style: TextStyle(
                          color: part.isFinished ? const Color(0xFF10B981) : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: M3EProgressIndicator.linearWavy(value: partProgress),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spare Part',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      M3ESwitch(
                        value: part.isSpare,
                        onChanged: (val) {
                          flagPartAsSpare(part.id, val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        M3EButton.outlined(
          onPressed: () {
            updatePartQuantityFound(part.id, part.quantityNeeded);
            context.pop();
          },
          child: const Text('Found All'),
        ),
        M3EButton.filled(
          onPressed: () => context.pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
