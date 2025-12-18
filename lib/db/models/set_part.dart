class SetPart {
  final String id;
  final String setId;
  final String userId;
  final String partNum;
  final int colorId;
  final String? name;
  final String? imgUrl;
  final int quantityNeeded;
  final int quantityFound;
  final bool isSpare;

  SetPart({
    required this.id,
    required this.setId,
    required this.userId,
    required this.partNum,
    required this.colorId,
    this.name,
    this.imgUrl,
    required this.quantityNeeded,
    required this.quantityFound,
    required this.isSpare,
  });

  factory SetPart.fromJson(Map<String, dynamic> json) {
    return SetPart(
      id: json['id'] as String,
      setId: json['set_id'] as String,
      userId: json['user_id'] as String,
      partNum: json['part_num'] as String,
      colorId: json['color_id'] as int,
      name: json['name'] as String?,
      imgUrl: json['img_url'] as String?,
      quantityNeeded: json['quantity_needed'] as int,
      quantityFound: json['quantity_found'] as int,
      isSpare: json['is_spare'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'set_id': setId,
      'user_id': userId,
      'part_num': partNum,
      'color_id': colorId,
      'name': name,
      'img_url': imgUrl,
      'quantity_needed': quantityNeeded,
      'quantity_found': quantityFound,
      'is_spare': isSpare,
    };
  }
}
