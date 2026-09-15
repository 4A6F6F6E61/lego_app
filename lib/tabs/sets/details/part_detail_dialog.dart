import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/components/image_viewer.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/rebrickable_providers.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class PartDetailDialog extends HookConsumerWidget {
  const PartDetailDialog({super.key, required this.part});
  final SetPart part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(colorsProvider);
    final theme = Theme.of(context);
    final isSpareState = useState(part.isSpare);
    final isLostState = useState(part.isLost);

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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Part Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  M3EIconButton(
                    variant: M3EIconButtonVariant.tonal,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Part Image Tile
              Center(
                child: part.imgUrl != null
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => openImageViewer(
                            context,
                            imageUrl: part.imgUrl!,
                            title: part.name ?? 'Part ${part.partNum}',
                          ),
                          child: Tooltip(
                            message: 'Tap to enlarge',
                            child: Container(
                              width: 110,
                              height: 110,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CachedNetworkImage(
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
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 110,
                        height: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.extension_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 14),

              // Part Name
              Text(
                part.name ?? 'Unknown Part',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                'Part ID: ${part.id}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Color Chip & Spare Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                                width: 15,
                                height: 15,
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
                            color: getProgressColor(partProgress),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: M3EProgressIndicator.linearWavy(
                        value: partProgress,
                        color: getProgressColor(partProgress),
                        trackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                        strokeWidth: 3.5,
                        trackStrokeWidth: 3.5,
                      ),
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
                          value: isSpareState.value,
                          onChanged: (val) {
                            isSpareState.value = val;
                            ref
                                .read(setPartsNotifierProvider(part.setId).notifier)
                                .toggleSpare(part.id, val);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Unable to find',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        M3ESwitch(
                          value: isLostState.value,
                          onChanged: (val) {
                            isLostState.value = val;
                            ref
                                .read(setPartsNotifierProvider(part.setId).notifier)
                                .toggleLost(part.id, val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  M3EButton.outlined(
                    onPressed: () {
                      ref
                          .read(setPartsNotifierProvider(part.setId).notifier)
                          .updateQuantity(part.id, part.quantityNeeded);
                      context.pop();
                    },
                    child: const Text('Found All'),
                  ),
                  const SizedBox(width: 8),
                  M3EButton.filled(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
