class SetPart {
  final int id;
  final String setId;
  final String userId;
  final String partNum;
  final int colorId;
  final String? name;
  final String? imgUrl;
  final int quantityNeeded;
  final int quantityFound;
  // TODO: Is spare is not working right now.
  final bool isSpare;
  final bool isLost;

  bool get isFinished => quantityNeeded <= quantityFound;

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
    required this.isLost,
  });

  SetPart copyWith({
    int? id,
    String? setId,
    String? userId,
    String? partNum,
    int? colorId,
    String? name,
    String? imgUrl,
    int? quantityNeeded,
    int? quantityFound,
    bool? isSpare,
    bool? isLost,
  }) {
    return SetPart(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      userId: userId ?? this.userId,
      partNum: partNum ?? this.partNum,
      colorId: colorId ?? this.colorId,
      name: name ?? this.name,
      imgUrl: imgUrl ?? this.imgUrl,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      quantityFound: quantityFound ?? this.quantityFound,
      isSpare: isSpare ?? this.isSpare,
      isLost: isLost ?? this.isLost,
    );
  }

  factory SetPart.fromJson(Map<String, dynamic> json) {
    return SetPart(
      id: json['id'] as int,
      setId: json['set_id'] as String,
      userId: json['user_id'] as String,
      partNum: json['part_num'] as String,
      colorId: json['color_id'] as int,
      name: json['name'] as String?,
      imgUrl: json['img_url'] as String?,
      quantityNeeded: json['quantity_needed'] as int,
      quantityFound: json['quantity_found'] as int,
      isSpare: json['is_spare'] as bool? ?? false,
      isLost: json['is_lost'] as bool? ?? false,
    );
  }

  factory SetPart.fromApiData(
    Map<String, dynamic> data, {
    required String setId,
    required String userId,
  }) {
    return SetPart(
      id: data['id'] as int,
      setId: setId,
      userId: userId,
      partNum: data['part']['part_num'] as String,
      colorId: data['color']['id'] as int,
      name: data['part']['name'] as String?,
      imgUrl: data['part']['part_img_url'] as String?,
      quantityNeeded: data['quantity'] as int,
      quantityFound: 0,
      isSpare: false,
      isLost: false,
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
      'is_lost': isLost,
    };
  }
}
