import 'package:readr/models/baseModel.dart';

class People {
  String? slug;
  String name;

  People({
    required this.slug,
    required this.name,
  });

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      slug: json[BaseModel.slugKey],
      name: json[BaseModel.nameKey],
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.slugKey: slug,
        BaseModel.nameKey: name,
      };
}
