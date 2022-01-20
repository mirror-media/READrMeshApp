import 'package:readr/models/baseModel.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';

class Comment {
  final String id;
  final Member member;
  final String content;
  final Comment? parent;
  final Comment? root;
  final String state;
  final DateTime publishDate;
  final NewsListItem? story;
  int likedCount;
  bool isLiked;

  Comment({
    required this.id,
    required this.member,
    required this.content,
    this.parent,
    this.root,
    required this.state,
    required this.publishDate,
    this.story,
    this.likedCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    NewsListItem? story;
    int likedCount = 0;
    bool isLiked = false;

    if (BaseModel.checkJsonKeys(json, ['story'])) {
      story = NewsListItem.fromJson(json['story']);
    }

    if (BaseModel.checkJsonKeys(json, ['likeCount'])) {
      likedCount = json['likeCount'];
    }

    /// because where set only count member id equals current user member id
    /// so if isLiked not 0, current user member id is in the list
    if (BaseModel.checkJsonKeys(json, ['isLiked'])) {
      isLiked = true;
    }

    return Comment(
      id: json['id'],
      member: Member.fromJson(json['member']),
      content: json['content'],
      state: json['state'],
      publishDate: DateTime.parse(json["published_date"]).toLocal(),
      story: story,
      likedCount: likedCount,
      isLiked: isLiked,
    );
  }
}
