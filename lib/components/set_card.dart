import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class SetCard extends ConsumerWidget {
  const SetCard({super.key, required this.set});
  final LegoSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final partsAsync = ref.watch(setPartsStreamProvider(set.id));

    final (statusLabel, statusColor, statusIcon) = switch (set.status) {
      LegoSetStatus.built => (
        'Built',
        const Color(0xFF10B981),
        Icons.check_circle_rounded,
      ),
      LegoSetStatus.currentlyBuilding => (
        'Building',
        const Color(0xFFF59E0B),
        Icons.handyman_rounded,
      ),
      LegoSetStatus.backlog => (
        'Backlog',
        const Color(0xFF3B82F6),
        Icons.inventory_2_outlined,
      ),
    };

    final progress = partsAsync.when(
      data: (parts) => calculateProgress(parts),
      loading: () => 0.0,
      error: (err, stack) => 0.0,
    );

    return M3ECard(
      variant: M3ECardVariant.filled,
      padding: EdgeInsets.zero,
      onPressed: () => context.go('/sets/details/${set.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    child: set.imgUrl != null
                        ? CachedNetworkImage(
                            imageUrl: proxiedImageUrl(set.imgUrl!),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox.square(
                                dimension: 24,
                                child: M3EProgressIndicator.circular(),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.extension_outlined, size: 40, color: Colors.grey),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.extension_outlined, size: 40, color: Colors.grey),
                          ),
                  ),
                  // Top overlay gradient for badges
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Set number badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${set.setNum}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Info panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    set.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (set.year != null) ...[
                        Icon(Icons.calendar_today_rounded, size: 12, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          '${set.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                      ],
                      if (partsAsync.value != null)
                        Text(
                          '${(progress * 100).toInt()}% found',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  if (set.status == LegoSetStatus.currentlyBuilding && partsAsync.value != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: M3EProgressIndicator.linearWavy(
                        value: progress,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
