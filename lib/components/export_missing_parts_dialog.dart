import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/api/services/rebrickable/users_api.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/settings.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportMissingPartsDialog extends HookConsumerWidget {
  final List<SetPart>? initialParts;
  final String? defaultTitle;

  const ExportMissingPartsDialog({super.key, this.initialParts, this.defaultTitle});

  Widget _dialogWrapper({
    required BuildContext context,
    required List<Widget> children,
    double maxWidth = 440,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isExporting = useState(false);
    final exportResult = useState<MissingPartsExportResult?>(null);
    final errorMessage = useState<String?>(null);
    final selectedDestination = useState<String>('lost_parts');

    final partsFuture = useMemoized(() async {
      if (initialParts != null) return initialParts!;
      return await fetchAllMissingParts();
    });
    final partsSnapshot = useFuture(partsFuture);

    final credsFuture = useMemoized(() async {
      final apiKey = await ref.read(rebrickableApiKeyProvider.future);
      final token = await ref.read(userTokenProvider.future);
      return (apiKey: apiKey, token: token);
    });
    final credsSnapshot = useFuture(credsFuture);

    final lostPartsFuture = useMemoized(() async {
      final creds = await credsFuture;
      final k = creds.apiKey;
      final t = creds.token;
      if (k == null || k.isEmpty || t == null || t.isEmpty) {
        return null;
      }
      try {
        final res = await userApi.getLostParts(
          apiKey: k,
          userToken: t,
          pageSize: 1,
        );
        return res['count'] as int? ?? 0;
      } catch (e) {
        return null;
      }
    }, [credsFuture]);
    final lostPartsSnapshot = useFuture(lostPartsFuture);

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final initialName = defaultTitle ?? 'Missing Parts - $dateStr';
    final nameController = useTextEditingController(text: initialName);

    // Initial Loading State
    if (!partsSnapshot.hasData || !credsSnapshot.hasData) {
      return _dialogWrapper(
        context: context,
        children: const [
          SizedBox(height: 12),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(dimension: 36, child: M3EProgressIndicator.circular()),
                SizedBox(height: 16),
                Text('Checking missing parts & credentials...'),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      );
    }

    final creds = credsSnapshot.data!;
    final apiKey = creds.apiKey;
    final userToken = creds.token;

    // Credentials Missing State
    if (apiKey == null || apiKey.isEmpty || userToken == null || userToken.isEmpty) {
      return _dialogWrapper(
        context: context,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.vpn_key_rounded, color: Color(0xFFF59E0B), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rebrickable Setup Required',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'To export parts to a Rebrickable list, please configure your Rebrickable API Key and link your account in Settings first.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              M3EButton.text(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              M3EButton.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/settings');
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ],
      );
    }

    final missingParts = partsSnapshot.data!;

    // No Missing Parts State
    if (missingParts.isEmpty) {
      return _dialogWrapper(
        context: context,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Missing Parts',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No parts are currently marked as "Unable to find". Open any set details and toggle the "Unable to find" switch on missing pieces to export them here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              M3EButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        ],
      );
    }

    // Success State
    if (exportResult.value != null) {
      final res = exportResult.value!;
      final isLost = res.isLostParts;
      return _dialogWrapper(
        context: context,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLost ? 'Parts Added to Lost Parts!' : 'List Exported!',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isLost
                ? 'Successfully added ${res.totalQuantity} missing pieces (${res.uniquePartsCount} unique parts) to your Rebrickable "My Lost Parts" list.'
                : 'Successfully created Rebrickable Part List "${res.listName}" with ${res.totalQuantity} total pieces (${res.uniquePartsCount} unique parts).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            isLost
                ? 'You can now view your Lost Parts on Rebrickable and order replacements via BrickLink or BrickOwl.'
                : 'You can now view this list on Rebrickable to directly order parts from BrickLink or BrickOwl.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              M3EButton.outlined(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              M3EButton.filled(
                onPressed: () async {
                  await launchUrl(Uri.parse(res.webUrl), mode: LaunchMode.externalApplication);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(isLost ? 'Open My Lost Parts' : 'Open on Rebrickable'),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final totalQuantity = missingParts.fold<int>(0, (sum, p) {
      final diff = p.quantityNeeded - p.quantityFound;
      return sum + (diff > 0 ? diff : 1);
    });

    final isLostDestination = selectedDestination.value == 'lost_parts';

    // Form / Confirmation State
    return _dialogWrapper(
      context: context,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_checkout_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Export Missing Parts',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            M3EIconButton(
              variant: M3EIconButtonVariant.tonal,
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: isExporting.value ? () {} : () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Export Destination',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        M3ESegmentedButton<String>(
          segments: const [
            M3ESegment(
              value: 'lost_parts',
              label: 'My Lost Parts',
            ),
            M3ESegment(
              value: 'custom_list',
              label: 'New Custom List',
            ),
          ],
          selected: {selectedDestination.value},
          onSelectionChanged: (val) {
            if (!isExporting.value && val.isNotEmpty) {
              selectedDestination.value = val.first;
              errorMessage.value = null;
            }
          },
        ),
        const SizedBox(height: 16),
        if (isLostDestination) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ready to export $totalQuantity missing pieces (${missingParts.length} entries) directly to Rebrickable\'s "My Lost Parts" collection.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (lostPartsSnapshot.connectionState == ConnectionState.waiting) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  SizedBox.square(dimension: 16, child: M3EProgressIndicator.circular()),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Checking existing Rebrickable "My Lost Parts"...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (lostPartsSnapshot.hasData && (lostPartsSnapshot.data ?? 0) > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'List Already Contains Parts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your Rebrickable "My Lost Parts" list currently has ${lostPartsSnapshot.data} item(s). Exporting will append these $totalQuantity missing pieces to your existing list.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (lostPartsSnapshot.hasData && lostPartsSnapshot.data == 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 20, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your Rebrickable "My Lost Parts" list is currently empty. These $totalQuantity missing pieces will be added to it.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ready to export $totalQuantity missing pieces (${missingParts.length} entries) to a new custom Rebrickable list for ordering.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          M3ETextField(
            controller: nameController,
            enabled: !isExporting.value,
            label: 'Rebrickable Part List Name',
            leading: const Icon(Icons.label_outline_rounded),
            variant: M3ETextFieldVariant.filled,
          ),
        ],
        if (errorMessage.value != null) ...[
          const SizedBox(height: 12),
          Text(errorMessage.value!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
        ],
        if (isExporting.value) ...[
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const SizedBox.square(dimension: 28, child: M3EProgressIndicator.circular()),
                const SizedBox(height: 8),
                Text(
                  isLostDestination
                      ? 'Adding parts to "My Lost Parts"...'
                      : 'Creating list on Rebrickable...',
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            M3EButton.text(
              onPressed: isExporting.value ? () {} : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            M3EButton.filled(
              onPressed: isExporting.value
                  ? () {}
                  : () async {
                      if (isLostDestination) {
                        isExporting.value = true;
                        errorMessage.value = null;

                        try {
                          final res = await exportToLostParts(
                            apiKey: apiKey,
                            userToken: userToken,
                            missingParts: missingParts,
                          );
                          exportResult.value = res;
                        } catch (e) {
                          errorMessage.value = 'Export failed: $e';
                        } finally {
                          isExporting.value = false;
                        }
                      } else {
                        final listName = nameController.text.trim();
                        if (listName.isEmpty) {
                          errorMessage.value = 'Please provide a list name.';
                          return;
                        }
                        isExporting.value = true;
                        errorMessage.value = null;

                        try {
                          final res = await exportMissingPartsToRebrickable(
                            apiKey: apiKey,
                            userToken: userToken,
                            listName: listName,
                            missingParts: missingParts,
                          );
                          exportResult.value = res;
                        } catch (e) {
                          errorMessage.value = 'Export failed: $e';
                        } finally {
                          isExporting.value = false;
                        }
                      }
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isLostDestination ? 'Add to My Lost Parts' : 'Create List & Export',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
