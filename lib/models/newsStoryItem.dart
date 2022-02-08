import 'package:readr/models/baseModel.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
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
    );
  }
}
