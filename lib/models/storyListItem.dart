import 'package:readr/models/baseModel.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/models/tagList.dart';

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
  TagList? tags;
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
    this.tags,
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
    if (json['categories'] != null && json['categories'].length > 0) {
      allPostsCategory = CategoryList.fromJson(json['categories']);
    }

    int? readingTime = json['readingTime'];

    bool isProject = false;
    if (json['style'] == 'project3' ||
        json['style'] == 'embedded' ||
        json['style'] == 'report') {
      isProject = true;
    }
    DateTime publishTime = DateTime.now();
    if (json['publishTime'] != null) {
      publishTime = DateTime.parse(json['publishTime']).toLocal();
    }

    TagList? tags;
    if (json['tags'] != null && json['tags'].length > 0) {
      tags = TagList.fromJson(json['tags']);
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
      tags: tags,
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
