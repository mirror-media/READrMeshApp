import 'package:readr/models/baseModel.dart';

class Member {
  final String? email;
  final String? firebaseId;
  final String memberId;
  final String nickname;
  final String? name;
  final int? followerCount;
  final int? pickCount;
  final int? commentCount;

  Member({
    this.firebaseId,
    required this.memberId,
    required this.nickname,
    this.email,
    this.name,
    this.followerCount,
    this.pickCount,
    this.commentCount,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? name;
    String? firebaseId;
    String? email;
    int? followerCount;
    int? pickCount;
    int? commentCount;

    if (BaseModel.hasKey(json, 'name')) {
      name = json['name'];
    }

    if (BaseModel.hasKey(json, 'firebaseId')) {
      firebaseId = json['firebaseId'];
    }

    if (BaseModel.hasKey(json, 'email')) {
      email = json['email'];
    }

    if (BaseModel.hasKey(json, 'followerCount')) {
      followerCount = json['followerCount'];
    }

    if (BaseModel.hasKey(json, 'pickCount')) {
      pickCount = json['pickCount'];
    }

    if (BaseModel.hasKey(json, 'commentCount')) {
      commentCount = json['commentCount'];
    }

    return Member(
      memberId: json['id'],
      firebaseId: firebaseId,
      email: email,
      nickname: json['nickname'],
      name: name,
      followerCount: followerCount,
      pickCount: pickCount,
      commentCount: commentCount,
    );
  }
}
