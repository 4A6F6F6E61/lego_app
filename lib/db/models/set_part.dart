import 'package:lego_app/db/db.dart';

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
      id: json['id'] as int,
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
  /* {
      "id": 152135,
      "inv_part_id": 152135,
      "part": {
        "part_num": "99781",
        "name": "Bracket 1 x 2 - 1 x 2",
        "part_cat_id": 9,
        "part_url": "https://rebrickable.com/parts/99781/bracket-1-x-2-1-x-2/",
        "part_img_url": "https://cdn.rebrickable.com/media/parts/elements/6016172.jpg",
        "external_ids": {
          "BrickLink": [
            "99781"
          ],
          "BrickOwl": [
            "151397"
          ],
          "Brickset": [
            "99781"
          ],
          "LDraw": [
            "99781"
          ],
          "LEGO": [
            "99781"
          ]
        }
      }, */
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
