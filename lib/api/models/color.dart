/*
  Model class for the Rebrickable Color object. (Only a subset of needed fields included)
*/
class Color {
  final int id;
  final String name;
  final String rgb;
  final bool isTransparent;

  Color({required this.id, required this.name, required this.rgb, required this.isTransparent});

  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
      id: json['id'] as int,
      name: json['name'] as String,
      rgb: json['rgb'] as String,
      isTransparent: json['is_trans'] as bool,
    );
  }
}
