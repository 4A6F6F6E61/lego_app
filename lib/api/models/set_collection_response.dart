import 'package:lego_app/api/models/set_collection_item.dart';

class SetCollectionResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<SetCollectionItem> results;

  SetCollectionResponse({required this.count, this.next, this.previous, required this.results});

  factory SetCollectionResponse.fromJson(Map<String, dynamic> json) {
    return SetCollectionResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List).map((item) => SetCollectionItem.fromJson(item)).toList(),
    );
  }
}
