import 'package:readr/models/baseModel.dart';
import 'package:readr/models/categoryList.dart';

class StoryListItem {
  String id;
  String name;
  String? slug;
  String? style;
  String? photoUrl;
  CategoryList? categoryList;
  DateTime publishTime;
  bool isProject;
  int? readingTime;
  StoryListItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.style,
    required this.photoUrl,
    required this.publishTime,
    this.categoryList,
    this.isProject = false,
    this.readingTime,
  });

  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    if (BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    String? photoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    CategoryList? allPostsCategory;
    if (json['categories'] != null) {
      allPostsCategory = CategoryList.fromJson(json['categories']);
    }

    int? readingTime;
    bool isProject = false;
    if (json['style'] == 'project3' ||
        json['style'] == 'embedded' ||
        json['style'] == 'report') {
      isProject = true;
    }
    if (json['wordCount'] != null) {
      readingTime = (((json['wordCount']) / 8) / 60).round();
    }
    DateTime publishTime = DateTime.now();
    if (json['publishTime'] != null) {
      publishTime = DateTime.parse(json['publishTime']).toLocal();
    }

    return StoryListItem(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      style: json['style'],
      photoUrl: photoUrl,
      categoryList: allPostsCategory,
      isProject: isProject,
      readingTime: readingTime,
      publishTime: publishTime,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
        'style': style,
        'photoUrl': photoUrl,
      };

  @override
  // ignore: recursive_getters
  int get hashCode => hashCode;

  @override
  bool operator ==(covariant StoryListItem other) {
    // compare this to other
    return slug == other.slug;
  }
}
