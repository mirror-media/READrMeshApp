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
  final bool fullScreenAd;
  final bool fullContent;
  final List<Member> followingPickMembers;
  final List<Member> otherPickMembers;
  final Comment? showComment;
  final List<Comment> allComments;
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
    this.fullScreenAd = false,
    this.pickCount = 0,
    this.commentCount = 0,
    this.fullContent = false,
    required this.followingPickMembers,
    required this.otherPickMembers,
    this.showComment,
    required this.allComments,
    this.myPickId,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    Publisher? source;
    Category? category;
    bool payWall = false;
    bool fullContent = false;
    bool fullScreenAd = false;
    int pickCount = 0;
    int commentCount = 0;
    List<Member> followingPickMembers = [];
    List<Member> otherPickMembers = [];
    Comment? showComment;
    List<Comment> allComments = [];
    String? myPickId;

    if (BaseModel.checkJsonKeys(json, ['source'])) {
      source = Publisher.fromJson(json['source']);
    }

    if (BaseModel.checkJsonKeys(json, ['category'])) {
      category = Category.fromNewProductJson(json['category']);
    }

    if (BaseModel.checkJsonKeys(json, ['paywall'])) {
      payWall = json['paywall'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_content'])) {
      fullContent = json['full_content'];
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

    if (BaseModel.checkJsonKeys(json, ['followingComment']) &&
        json['followingComment'].isNotEmpty) {
      showComment = Comment.fromJson(json['followingComment'][0]);
    }

    if (BaseModel.checkJsonKeys(json, ['notFollowingComment']) &&
        json['notFollowingComment'].isNotEmpty) {
      showComment = Comment.fromJson(json['notFollowingComment'][0]);
    }

    if (BaseModel.checkJsonKeys(json, ['allComments']) &&
        json['allComments'].isNotEmpty) {
      for (var comment in json['allComments']) {
        allComments.add(Comment.fromJson(comment));
      }
    }

    if (BaseModel.checkJsonKeys(json, ['myPickId']) &&
        json['myPickId'].isNotEmpty) {
      myPickId = json['myPickId'][0]['id'];
    }

    if (BaseModel.checkJsonKeys(json, ['full_screen_ad'])) {
      if (json['full_screen_ad'] == 'all' ||
          json['full_screen_ad'] == 'mobile') {
        fullScreenAd = true;
      }
    }

    return NewsListItem(
      id: json["id"],
      title: json["title"],
      url: json["url"],
      source: source,
      category: category,
      publishedDate: DateTime.parse(json["published_date"]).toLocal(),
      heroImageUrl: json["og_image"],
      payWall: payWall,
      fullScreenAd: fullScreenAd,
      pickCount: pickCount,
      commentCount: commentCount,
      followingPickMembers: followingPickMembers,
      otherPickMembers: otherPickMembers,
      showComment: showComment,
      allComments: allComments,
      myPickId: myPickId,
    );
  }
}
