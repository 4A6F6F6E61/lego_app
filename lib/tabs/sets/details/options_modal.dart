import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/components/confirm_action_dialog.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:yaru/yaru.dart';

class OptionsModal extends HookConsumerWidget {
  const OptionsModal({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    void setCompleted() async {
      if (loading.value) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmActionDialog(
          title: 'Set as Completed',
          content:
              'Are you sure you want to mark all parts as completed? This action cannot be undone.',
        ),
      );

      if (confirm != true) {
        return;
      }
      try {
        loading.value = true;
        await ref.read(setAllPartsToFoundProvider(setId).future);
      } finally {
        loading.value = false;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: loading.value
            ? [
                const Center(
                  child: SizedBox.square(
                    dimension: 25,
                    child: YaruCircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ]
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Options', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(YaruIcons.checkmark),
                  title: const Text('Set as Completed'),
                  onTap: setCompleted,
                ),
              ],
      ),
    );
  }
}
