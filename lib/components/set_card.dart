import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lego_app/db/models/lego_set.dart';
import 'package:lego_app/util.dart';
import 'package:yaru/yaru.dart';

class SetCard extends StatelessWidget {
  const SetCard({super.key, required this.set});
  final LegoSet set;

  @override
  Widget build(BuildContext context) {
    Color cardColor = () {
      switch (set.status) {
        case LegoSetStatus.built:
          return Theme.of(context).colorScheme.success;
        case LegoSetStatus.currentlyBuilding:
          return Theme.of(context).colorScheme.warning;
        case LegoSetStatus.backlog:
          return Theme.of(context).colorScheme.primaryContainer;
      }
    }();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardColor.withAlpha(50),
        border: Border.all(color: cardColor, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.go('/sets/details/${set.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: set.imgUrl != null
                  ? CachedNetworkImage(
                      imageUrl: proxiedImageUrl(set.imgUrl!),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.broken_image, size: 50)),
                    )
                  : const Center(child: Icon(Icons.image_not_supported, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    set.setNum,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
