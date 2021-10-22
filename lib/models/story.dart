import 'package:readr/models/baseModel.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/peopleList.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/models/tagList.dart';

class Story {
  final String? style;
  final String? name;
  final ParagraphList? brief;
  final ParagraphList? contentApiData;
  final String? publishTime;
  final String? updatedAt;

  final String? heroImage;
  final String? heroVideo;
  final String? heroCaption;

  final CategoryList? categoryList;

  final PeopleList? writers;
  final PeopleList? photographers;
  final PeopleList? cameraOperators;
  final PeopleList? designers;
  final PeopleList? engineers;
  final PeopleList? vocals;
  final String? otherbyline;

  final TagList? tags;
  final StoryListItemList? relatedStories;

  Story({
    this.style,
    this.name,
    this.brief,
    this.contentApiData,
    this.publishTime,
    this.updatedAt,
    this.heroImage,
    this.heroVideo,
    this.heroCaption,
    this.categoryList,
    this.writers,
    this.photographers,
    this.cameraOperators,
    this.designers,
    this.engineers,
    this.vocals,
    this.otherbyline,
    this.tags,
    this.relatedStories,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    ParagraphList brief = ParagraphList();
    if (BaseModel.hasKey(json, 'briefApiData') &&
        json["briefApiData"] != 'NaN') {
      brief = ParagraphList.parseResponseBody(json['briefApiData']);
    }

    ParagraphList contentApiData = ParagraphList();
    if (BaseModel.hasKey(json, 'contentApiData') &&
        json["contentApiData"] != 'NaN') {
      contentApiData = ParagraphList.parseResponseBody(json["contentApiData"]);
    }

    String? photoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'mobile'])) {
      photoUrl = json['heroImage']['mobile'];
    }

    String? videoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroVideo', 'url'])) {
      videoUrl = json['heroVideo']['url'];
    }

    return Story(
      style: json['style'],
      name: json[BaseModel.nameKey],
      brief: brief,
      contentApiData: contentApiData,
      publishTime: json['publishTime'],
      updatedAt: json['updatedAt'],
      heroImage: photoUrl,
      heroVideo: videoUrl,
      heroCaption: json['heroCaption'],
      categoryList: CategoryList.fromJson(json['categories']),
      writers: PeopleList.fromJson(json['writers']),
      photographers: PeopleList.fromJson(json['photographers']),
      cameraOperators: PeopleList.fromJson(json['cameraOperators']),
      designers: PeopleList.fromJson(json['designers']),
      engineers: PeopleList.fromJson(json['engineers']),
      vocals: PeopleList.fromJson(json['vocals']),
      otherbyline: json['otherbyline'],
      tags: TagList.fromJson(json['tags']),
      relatedStories: StoryListItemList.fromJson(json['relatedPosts']),
    );
  }
}
