import 'package:readr/models/baseModel.dart';

class Tag {
  String id;
  String name;
  String slug;

  Tag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
      };
}
