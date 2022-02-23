import 'package:readr/models/annotation.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/publisher.dart';

class NewsStoryItem {
  final String id;
  final String title;
  final Publisher? source;
  final List<Member> followingPickMembers;
  final List<Member> otherPickMembers;
  final List<Comment> popularComments;
  final List<Comment> allComments;
  int pickCount;
  String? myPickId;
  String? bookmarkId;
  String? contentApiData;
  List<String>? contentAnnotationData;

  NewsStoryItem({
    required this.id,
    required this.title,
    this.source,
    required this.followingPickMembers,
    required this.otherPickMembers,
    required this.popularComments,
    required this.allComments,
    this.pickCount = 0,
    this.myPickId,
    this.bookmarkId,
    this.contentApiData,
    this.contentAnnotationData,
  });

  factory NewsStoryItem.fromJson(Map<String, dynamic> json) {
    Publisher? source;
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    List<Comment> allComments = [];
    List<Comment> popularComments = [];
    String? myPickId;
    int pickCount = 0;
    String? bookmarkId;
    bool fullContent = false;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['followingPickMembers']) &&
        json['followingPickMembers'].isNotEmpty) {
      for (var pick in json['followingPickMembers']) {
        followingPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherPickMembers']) &&
        json['otherPickMembers'].isNotEmpty) {
      for (var pick in json['otherPickMembers']) {
        otherPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['comment']) &&
        json['comment'].isNotEmpty) {
      for (var comment in json['comment']) {
        allComments.add(Comment.fromJson(comment));
      }
      popularComments = allComments;
      popularComments.sort((a, b) => b.likedCount.compareTo(a.likedCount));
      popularComments.take(3);
      if (popularComments[0].likedCount == 0) {
        popularComments = [];
      }
    }

    if (BaseModel.checkJsonKeys(json, ['myPickId']) &&
        json['myPickId'].isNotEmpty) {
      myPickId = json['myPickId'][0]['id'];
    }

    if (BaseModel.checkJsonKeys(json, ['bookmarkId']) &&
        json['bookmarkId'].isNotEmpty) {
      bookmarkId = json['bookmarkId'][0]['id'];
    }

    if (BaseModel.checkJsonKeys(json, ['pickCount'])) {
      pickCount = json['pickCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_content'])) {
      fullContent = json['full_content'];
    }

    String? contentApiData;
    // ParagraphList contentApiData = ParagraphList();
    List<String>? contentAnnotationData = [];
    if (BaseModel.hasKey(json, 'content') && fullContent) {
      contentApiData = json["content"];
      // contentApiData = ParagraphList.parseResponseBody(json["content"]);
      // for (var paragraph in contentApiData) {
      //   if (paragraph.type == 'annotation' && paragraph.contents!.isNotEmpty) {
      //     List<String> sourceData =
      //         Annotation.parseSourceData(paragraph.contents![0].data);
      //     String? annotationData = Annotation.getAnnotation(sourceData);
      //     if (annotationData != null) {
      //       contentAnnotationData.add(annotationData);
      //     }
      //   }
      // }
    }

    return NewsStoryItem(
      id: json['id'],
      title: json['title'],
      source: source,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      popularComments: popularComments,
      allComments: allComments,
      myPickId: myPickId,
      pickCount: pickCount,
      bookmarkId: bookmarkId,
      contentApiData: contentApiData,
      contentAnnotationData: contentAnnotationData,
    );
  }
}
