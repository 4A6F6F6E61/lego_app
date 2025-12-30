import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/db.dart';
import 'package:lego_app/db/models/set_part.dart';
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
    final finishedColor = Theme.of(context).colorScheme.success;
    final spareColor = Theme.of(context).colorScheme.error;
    final startedColor = Theme.of(context).colorScheme.warning;
    final notStartedColor = Theme.of(context).colorScheme.surface;

    final inputController = useTextEditingController(text: part.quantityFound.toString());

    Future<void> updateQuantityFound(int quantity) async {
      if (quantity < 0 || quantity > part.quantityNeeded) {
        inputController.text = part.quantityFound.toString();
        return;
      }
      await supabase.from('set_parts').update({'quantity_found': quantity}).eq('id', part.id);
    }

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

    return YaruTranslucentContainer(
      clipBehavior: Clip.antiAlias,
      color: part.isFinished
          ? finishedColor
          : part.quantityFound > 0
          ? startedColor
          : part.isSpare
          ? spareColor
          : notStartedColor,
      border: Border.all(width: 2),
      child: InkWell(
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
                )
              : const Icon(Icons.extension),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(YaruIcons.minus),
                onPressed: () async {
                  await decreaseQuantityFound();
                },
              ),
              SizedBox(
                width: 55,
                child: TextFormField(
                  controller: inputController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onTap: () {
                    if (inputController.text == '0') {
                      inputController.text = '';
                    }
                  },
                  onChanged: (value) async {
                    final quantity = int.tryParse(value);
                    if (quantity != null) {
                      await updateQuantityFound(quantity);
                    } else {
                      inputController.text = part.quantityFound.toString();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(YaruIcons.plus),
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
