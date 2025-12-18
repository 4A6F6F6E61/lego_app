class RebrickableLegoSet {
  final String setNum;
  final String name;
  final int year;
  final int themeId;
  final int numParts;
  final String setImgUrl;
  final String setUrl;
  final DateTime lastModifiedDt;

  RebrickableLegoSet({
    required this.setNum,
    required this.name,
    required this.year,
    required this.themeId,
    required this.numParts,
    required this.setImgUrl,
    required this.setUrl,
    required this.lastModifiedDt,
  });

  factory RebrickableLegoSet.fromJson(Map<String, dynamic> json) {
    return RebrickableLegoSet(
      setNum: json['set_num'],
      name: json['name'],
      year: json['year'],
      themeId: json['theme_id'],
      numParts: json['num_parts'],
      setImgUrl: json['set_img_url'],
      setUrl: json['set_url'],
      lastModifiedDt: DateTime.parse(json['last_modified_dt']),
    );
  }
}
