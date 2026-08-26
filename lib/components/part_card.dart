import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/providers/rebrickable_providers.dart';
import 'package:lego_app/tabs/sets/details/part_detail_dialog.dart';
import 'package:lego_app/util.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class PartCard extends HookConsumerWidget {
  const PartCard({super.key, required this.part});

  final SetPart part;

  Future<void> showPartDetails(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PartDetailDialog(part: part),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorsAsync = ref.watch(colorsProvider);

    final isFinished = part.isFinished;
    final isStarted = part.quantityFound > 0 && !isFinished;
    final isSpare = part.isSpare;

    final (statusColor, statusBgColor) = switch ((isFinished, isStarted, isSpare)) {
      (true, _, _) => (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.12)),
      (_, true, _) => (const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.12)),
      (_, _, true) => (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.10)),
      _ => (
        theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        theme.colorScheme.surfaceContainer,
      ),
    };

    final inputController = useTextEditingController(text: part.quantityFound.toString());
    final focusNode = useFocusNode();

    Future<void> updateQuantity(int quantity) {
      if (quantity < 0) return Future.value();
      return updatePartQuantityFound(part.id, quantity);
    }

    useEffect(() {
      inputController.text = part.quantityFound.toString();
      return null;
    }, [part.quantityFound]);

    useEffect(() {
      void handleFocusChange() {
        if (!focusNode.hasFocus) {
          final raw = inputController.text.trim();
          if (raw.isEmpty) {
            inputController.text = part.quantityFound.toString();
            return;
          }
          final quantity = int.tryParse(raw);
          if (quantity != null) {
            updateQuantity(quantity);
          } else {
            inputController.text = part.quantityFound.toString();
          }
        }
      }

      focusNode.addListener(handleFocusChange);
      return () => focusNode.removeListener(handleFocusChange);
    });

    Future<void> increaseQuantity() async {
      if (part.isFinished) return;
      final next = part.quantityFound + 1;
      inputController.text = next.toString();
      await updateQuantity(next);
    }

    Future<void> decreaseQuantity() async {
      if (part.quantityFound <= 0) return;
      final prev = part.quantityFound - 1;
      inputController.text = prev.toString();
      await updateQuantity(prev);
    }

    Color? legoColor;
    String? colorName;
    if (colorsAsync.hasValue) {
      final colorInfo = colorsAsync.value![part.colorId];
      if (colorInfo != null) {
        colorName = colorInfo.name;
        legoColor = Color(int.parse('FF${colorInfo.rgb}', radix: 16));
      }
    }

    return M3ECard(
      variant: M3ECardVariant.filled,
      color: statusBgColor,
      borderRadius: BorderRadius.circular(14),
      border: BorderSide(
        color: statusColor.withValues(alpha: isFinished || isStarted || isSpare ? 0.8 : 0.25),
        width: isFinished || isStarted ? 1.5 : 1.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      onPressed: () => showPartDetails(context),
      child: Row(
        children: [
          // Left Part Image with Color Dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: part.imgUrl != null
                    ? CachedNetworkImage(
                        imageUrl: proxiedImageUrl(part.imgUrl!),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: SizedBox.square(
                            dimension: 16,
                            child: M3EProgressIndicator.circular(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.extension_outlined, size: 22, color: Colors.grey),
                      )
                    : const Icon(Icons.extension_outlined, size: 22, color: Colors.grey),
              ),
              if (legoColor != null)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: legoColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // Middle Part Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        part.name ?? 'Part #${part.id}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSpare) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SPARE',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (colorName != null) ...[
                      Flexible(
                        child: Text(
                          colorName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,

                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '${part.quantityFound}/${part.quantityNeeded}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                    if (isFinished) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Stepper Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                icon: const Icon(Icons.remove_rounded, size: 16),
                onPressed: part.quantityFound > 0 ? decreaseQuantity : () {},
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: TextFormField(
                  controller: inputController,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  onTap: () {
                    if (inputController.text == '0') inputController.text = '';
                  },
                  onChanged: (value) async {
                    final raw = value.trim();
                    if (raw.isNotEmpty) {
                      final q = int.tryParse(raw);
                      if (q != null) await updateQuantity(q);
                    }
                  },
                  onFieldSubmitted: (value) async {
                    final q = int.tryParse(value.trim());
                    if (q != null) await updateQuantity(q);
                  },
                ),
              ),
              const SizedBox(width: 4),
              M3EIconButton(
                variant: isFinished ? M3EIconButtonVariant.tonal : M3EIconButtonVariant.filled,
                icon: const Icon(Icons.add_rounded, size: 16),
                onPressed: !isFinished ? increaseQuantity : () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
