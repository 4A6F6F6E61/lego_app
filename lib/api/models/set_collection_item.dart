import 'package:lego_app/api/models/lego_set.dart';

class SetCollectionItem {
  final int listId;
  final int quantity;
  final bool includeSpares;
  final RebrickableLegoSet set;

  SetCollectionItem({
    required this.listId,
    required this.quantity,
    required this.includeSpares,
    required this.set,
  });

  factory SetCollectionItem.fromJson(Map<String, dynamic> json) {
    return SetCollectionItem(
      listId: json['list_id'],
      quantity: json['quantity'],
      includeSpares: json['include_spares'],
      set: RebrickableLegoSet.fromJson(json['set']),
    );
  }
}
