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

  Comment({
    required this.id,
    required this.member,
    required this.content,
    this.parent,
    this.root,
    required this.state,
    required this.publishDate,
    this.story,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    NewsListItem? story;
    if (BaseModel.checkJsonKeys(json, ['story'])) {
      story = NewsListItem.fromJson(json['story']);
    }
    return Comment(
      id: json['id'],
      member: Member.fromJson(json['member']),
      content: json['content'],
      state: json['state'],
      publishDate: DateTime.parse(json["published_date"]).toLocal(),
      story: story,
    );
  }
}
