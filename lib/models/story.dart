import 'package:readr/models/annotation.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/peopleList.dart';

class Story {
  final String? style;
  final String? name;
  final ParagraphList? summaryApiData;
  final int readingTime;
  final ParagraphList? contentApiData;
  final List<String>? contentAnnotationData;
  final ParagraphList? citationApiData;
  final String? publishTime;
  final String? updatedAt;

  final String? heroImage;
  final String? heroVideo;
  final String? heroCaption;

  final List<Category>? categoryList;

  final PeopleList? writers;
  final PeopleList? photographers;
  final PeopleList? cameraOperators;
  final PeopleList? designers;
  final PeopleList? engineers;
  final PeopleList? dataAnalysts;
  final String? otherByline;

  final List<String> imageUrlList;

  Story({
    this.style,
    this.name,
    this.summaryApiData,
    this.readingTime = 10,
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
    this.dataAnalysts,
    this.otherByline,
    this.citationApiData,
    this.contentAnnotationData,
    required this.imageUrlList,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    ParagraphList summaryApiData = ParagraphList();
    List<String> imageUrlList = [];
    String? photoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'mobile'])) {
      photoUrl = json['heroImage']['mobile'];
      imageUrlList.add(photoUrl!);
    }

    if (BaseModel.hasKey(json, 'summaryApiData') &&
        json["summaryApiData"] != 'NaN') {
      summaryApiData = ParagraphList.parseResponseBody(json['summaryApiData']);
    }

    ParagraphList contentApiData = ParagraphList();
    List<String>? contentAnnotationData = [];
    if (BaseModel.hasKey(json, 'contentApiData') &&
        json["contentApiData"] != 'NaN') {
      contentApiData = ParagraphList.parseResponseBody(json["contentApiData"]);
      for (var paragraph in contentApiData) {
        if (paragraph.type == 'annotation' && paragraph.contents!.isNotEmpty) {
          List<String> sourceData =
              Annotation.parseSourceData(paragraph.contents![0].data);
          String? annotationData = Annotation.getAnnotation(sourceData);
          if (annotationData != null) {
            contentAnnotationData.add(annotationData);
          }
        } else if (paragraph.type == 'image' &&
            paragraph.contents!.isNotEmpty) {
          imageUrlList.add(paragraph.contents![0].data);
        } else if (paragraph.type == 'slideshow') {
          for (var content in paragraph.contents!) {
            imageUrlList.add(content.data);
          }
        }
      }
    }

    ParagraphList citationApiData = ParagraphList();
    if (BaseModel.hasKey(json, 'citationApiData') &&
        json["citationApiData"] != 'NaN') {
      citationApiData =
          ParagraphList.parseResponseBody(json["citationApiData"]);
    }

    String? videoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroVideo', 'url'])) {
      videoUrl = json['heroVideo']['url'];
    }
    int readingTime = json['readingTime'] ?? 10;

    return Story(
      style: json['style'],
      name: json[BaseModel.nameKey],
      summaryApiData: summaryApiData,
      readingTime: readingTime,
      contentApiData: contentApiData,
      publishTime: json['publishTime'],
      updatedAt: json['updatedAt'],
      heroImage: photoUrl,
      heroVideo: videoUrl,
      heroCaption: json['heroCaption'],
      categoryList: List<Category>.from(
          json['categories'].map((item) => Category.fromJson(item))),
      writers: PeopleList.fromJson(json['writers']),
      photographers: PeopleList.fromJson(json['photographers']),
      cameraOperators: PeopleList.fromJson(json['cameraOperators']),
      designers: PeopleList.fromJson(json['designers']),
      engineers: PeopleList.fromJson(json['engineers']),
      dataAnalysts: PeopleList.fromJson(json['dataAnalysts']),
      otherByline: json['otherByline'],
      citationApiData: citationApiData,
      contentAnnotationData: contentAnnotationData,
      imageUrlList: imageUrlList,
    );
  }
}
