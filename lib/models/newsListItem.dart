import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';

class NewsListItem {
  final String id;
  final String title;
  final String url;
  final String? summary;
  final String? content;
  final Publisher? source;
  final Category? category;
  final DateTime publishedDate;
  final String heroImageUrl;
  int pickCount;
  final int commentCount;
  final bool payWall;
  final bool overlayAds;
  final List<Member> followingPickMembers;
  final List<Member> otherPickMembers;
  final List<Comment> followingComments;
  final List<Comment> otherComments;
  String? myPickId;

  NewsListItem({
    required this.id,
    required this.title,
    required this.url,
    this.summary,
    this.content,
    this.source,
    this.category,
    required this.publishedDate,
    required this.heroImageUrl,
    this.payWall = false,
    this.overlayAds = false,
    this.pickCount = 0,
    this.commentCount = 0,
    required this.followingPickMembers,
    required this.otherPickMembers,
    required this.followingComments,
    required this.otherComments,
    this.myPickId,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    Publisher? source;
    Category? category;
    bool payWall = false;
    bool overlayAds = false;
    int pickCount = 0;
    int commentCount = 0;
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    List<Comment> followingComments = [];
    List<Comment> otherComments = [];
    String? myPickId;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['category'])) {
      category = Category.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['paywall'])) {
      payWall = json['paywall'];
    }

    if (BaseModel.checkJsonKeys(json, ['pickCount'])) {
      pickCount = json['pickCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['commentCount'])) {
      commentCount = json['commentCount'];
    }

    if (BaseModel.checkJsonKeys(json, ['followingPicks']) &&
        json['followingPicks'].isNotEmpty) {
      for (var pick in json['followingPicks']) {
        followingPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherPicks']) &&
        json['otherPicks'].isNotEmpty) {
      for (var pick in json['otherPicks']) {
        otherPickMembers.add(Member.fromJson(pick['member']));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['followingComments']) &&
        json['followingComments'].isNotEmpty) {
      for (var comment in json['followingPicks']) {
        followingComments.add(Comment.fromJson(comment));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['otherComments']) &&
        json['otherComments'].isNotEmpty) {
      for (var comment in json['otherComments']) {
        otherComments.add(Comment.fromJson(comment));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['myPickId']) &&
        json['myPickId'].isNotEmpty) {
      myPickId = json['myPickId'][0]['id'];
    }

    return NewsListItem(
      id: json["id"],
      title: json["title"],
      url: json["url"],
      summary: json["summary"],
      source: source,
      category: category,
      publishedDate: DateTime.parse(json["published_date"]).toLocal(),
      heroImageUrl: json["og_image"],
      payWall: payWall,
      overlayAds: overlayAds,
      pickCount: pickCount,
      commentCount: commentCount,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      followingComments: followingComments,
      otherComments: otherComments,
      myPickId: myPickId,
    );
  }
}
