class LegoSet {
  final String id;
  final String userId;
  final String setNum;
  final String name;
  final int? year;
  final int? themeId;
  final int? numParts;
  final String? imgUrl;
  final DateTime createdAt;

  LegoSet({
    required this.id,
    required this.userId,
    required this.setNum,
    required this.name,
    this.year,
    this.themeId,
    this.numParts,
    this.imgUrl,
    required this.createdAt,
  });

  factory LegoSet.fromJson(Map<String, dynamic> json) {
    return LegoSet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      setNum: json['set_num'] as String,
      name: json['name'] as String,
      year: json['year'] as int?,
      themeId: json['theme_id'] as int?,
      numParts: json['num_parts'] as int?,
      imgUrl: json['img_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'set_num': setNum,
      'name': name,
      'year': year,
      'theme_id': themeId,
      'num_parts': numParts,
      'img_url': imgUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
