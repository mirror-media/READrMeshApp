import 'package:readr/models/baseModel.dart';

class Tag {
  String id;
  String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
      };
}
