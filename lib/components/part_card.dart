import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lego_app/db/models/set_part.dart';
import 'package:lego_app/providers/db_providers.dart';
import 'package:lego_app/tabs/sets/details/part_detail_dialog.dart';
import 'package:lego_app/util.dart';
import 'package:yaru/yaru.dart';

class PartCard extends HookWidget {
  const PartCard({super.key, required this.part});

  final SetPart part;

  Future<void> showPartDetails(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PartDetailDialog(part: part),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finishedColor = Colors.green;
    final spareColor = Theme.of(context).colorScheme.error;
    final startedColor = Colors.amber;
    final notStartedColor = Theme.of(context).colorScheme.surface;

    final inputController = useTextEditingController(text: part.quantityFound.toString());
    final focusNode = useFocusNode();

    Future<void> updateQuantityFound(int quantity) {
      if (quantity < 0) {
        return Future.value();
      }
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
            updateQuantityFound(quantity);
          } else {
            inputController.text = part.quantityFound.toString();
          }
        }
      }

      focusNode.addListener(handleFocusChange);
      return () => focusNode.removeListener(handleFocusChange);
    });

    Future<void> increaseQuantityFound() async {
      if (part.isFinished) {
        return;
      }
      inputController.text = (part.quantityFound + 1).toString();
      await updateQuantityFound(part.quantityFound + 1);
    }

    Future<void> decreaseQuantityFound() async {
      if (part.quantityFound <= 0) {
        return;
      }
      inputController.text = (part.quantityFound - 1).toString();
      await updateQuantityFound(part.quantityFound - 1);
    }

    const borderRadius = BorderRadius.all(Radius.circular(8));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: part.isFinished
            ? finishedColor.withOpacity(0.2)
            : part.quantityFound > 0
            ? startedColor.withOpacity(0.2)
            : part.isSpare
            ? spareColor.withOpacity(0.2)
            : notStartedColor.withOpacity(0.2),
        border: Border.all(
          color: part.isFinished
              ? finishedColor
              : part.quantityFound > 0
              ? startedColor
              : part.isSpare
              ? spareColor
              : notStartedColor,
        ),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () async {
          await showPartDetails(context);
        },
        child: YaruTile(
          title: Text(part.name ?? 'Unknown Part', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('Found: ${part.quantityFound} / ${part.quantityNeeded}'),
          leading: part.imgUrl != null
              ? CachedNetworkImage(
                  imageUrl: proxiedImageUrl(part.imgUrl!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                )
              : const Icon(Icons.extension),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () async {
                  await decreaseQuantityFound();
                },
              ),
              SizedBox(
                width: 55,
                child: TextFormField(
                  controller: inputController,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onTap: () {
                    if (inputController.text == '0') {
                      inputController.text = '';
                    }
                  },
                  onChanged: (value) async {
                    final raw = value.trim();
                    if (raw.isEmpty) {
                      return;
                    }
                    final quantity = int.tryParse(raw);
                    if (quantity != null) {
                      await updateQuantityFound(quantity);
                    }
                  },
                  onFieldSubmitted: (value) async {
                    final quantity = int.tryParse(value.trim());
                    if (quantity != null) {
                      await updateQuantityFound(quantity);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await increaseQuantityFound();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
