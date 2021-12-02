import 'package:readr/models/baseModel.dart';

class People {
  String slug;
  String name;
  String? bio;
  String? photoUrl;

  People({
    required this.slug,
    required this.name,
    required this.bio,
    required this.photoUrl,
  });

  factory People.fromJson(Map<String, dynamic> json) {
    String? bio;
    if (json['bio'] != null) {
      bio = json['bio'];
    }
    String? photoUrl;
    if (json['image'] != null) {
      photoUrl = json['image']['urlMobileSized'];
    }

    return People(
      slug: json[BaseModel.slugKey],
      name: json[BaseModel.nameKey],
      bio: bio,
      photoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.slugKey: slug,
        BaseModel.nameKey: name,
      };
}
