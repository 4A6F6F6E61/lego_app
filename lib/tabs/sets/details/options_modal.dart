import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/components/confirm_action_dialog.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class OptionsModal extends HookConsumerWidget {
  const OptionsModal({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final theme = Theme.of(context);

    Future<void> setCompleted() async {
      if (loading.value) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmActionDialog(
          title: 'Set All as Completed',
          content:
              'Are you sure you want to mark all parts in this set as found? This action cannot be undone.',
          confirmLabel: 'Mark All Found',
        ),
      );

      if (confirm != true) return;

      try {
        loading.value = true;
        await ref.read(setAllPartsToFoundProvider(setId).future);
        if (context.mounted) Navigator.of(context).pop();
      } finally {
        loading.value = false;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: SizedBox.square(
                  dimension: 32,
                  child: M3EProgressIndicator.circular(),
                ),
              ),
            )
          else ...[
            M3ECard(
              variant: M3ECardVariant.filled,
              color: theme.colorScheme.surfaceContainer,
              border: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
              onPressed: setCompleted,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.done_all_rounded,
                        color: Color(0xFF10B981),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark All Parts as Found',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sets quantity found to 100% for all pieces',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
