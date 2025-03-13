import 'package:readr/models/baseModel.dart';
import 'package:readr/models/member.dart';

class Comment {
  final String? id;
  final Member member;
  final String content;
  final Comment? parent;
  final Comment? root;
  final String state;
  final DateTime? publishDate;
  int likedCount;
  bool isLiked;
  bool isEdited;

  Comment({
    this.id,
    required this.member,
    required this.content,
    this.parent,
    this.root,
    required this.state,
    this.publishDate,
    this.likedCount = 0,
    this.isLiked = false,
    this.isEdited = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    int likedCount = 0;
    bool isLiked = false;
    bool isEdited = false;

    if (BaseModel.checkJsonKeys(json, ['likeCount'])) {
      likedCount = json['likeCount'];
    }

    /// because where set only count member id equals current user member id
    /// so if isLiked not 0, current user member id is in the list
    if (BaseModel.checkJsonKeys(json, ['isLiked'])) {
      if (json['isLiked'] != 0) {
        isLiked = true;
      }
    }

    if (BaseModel.checkJsonKeys(json, ['is_edited'])) {
      isEdited = json['is_edited'];
    }
    if (json["published_date"] == null) {
      print("published date is null" + json['id']);
    }

    return Comment(
      id: json['id'],
      member: Member.fromJson(json['member']),
      content: json['content'],
      state: json['state'] ?? "public",
      publishDate: json["published_date"] != null
          ? DateTime.parse(json["published_date"]).toLocal()
          : null,
      likedCount: likedCount,
      isLiked: isLiked,
      isEdited: isEdited,
    );
  }

  factory Comment.editComment(String newContent, Comment oldComment) {
    return Comment(
      id: oldComment.id,
      member: oldComment.member,
      content: newContent,
      state: oldComment.state,
      publishDate: oldComment.publishDate,
      likedCount: oldComment.likedCount,
      isLiked: oldComment.isLiked,
      isEdited: true,
      parent: oldComment.parent,
      root: oldComment.root,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          id == other.id &&
          member.memberId == other.member.memberId;

  @override
  int get hashCode => id.hashCode ^ member.memberId.hashCode;
}
