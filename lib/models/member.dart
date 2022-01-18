import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/publisher.dart';

class Member {
  final String? email;
  final String? firebaseId;
  final String memberId;
  final String nickname;
  final String? name;
  final String? headshotUrl;
  final int? followerCount;
  final int? pickCount;
  final int? commentCount;
  final List<Member>? follower;
  final List<Category>? followingCategory;
  final List<Publisher>? followingPublisher;
  List<Member>? following;

  Member({
    this.firebaseId,
    required this.memberId,
    required this.nickname,
    this.email,
    this.name,
    this.headshotUrl,
    this.followerCount,
    this.pickCount,
    this.commentCount,
    this.follower,
    this.followingCategory,
    this.followingPublisher,
    this.following,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? name;
    String? firebaseId;
    String? email;
    int? followerCount;
    int? pickCount;
    int? commentCount;
    List<Member> follower = [];
    List<Category> followingCategory = [];
    List<Publisher> followingPublisher = [];
    List<Member> following = [];

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

    if (BaseModel.hasKey(json, 'following') && json['following'].isNotEmpty) {
      for (var member in json['following']) {
        following.add(Member.fromJson(member));
      }
    }

    if (BaseModel.hasKey(json, 'follower') && json['follower'].isNotEmpty) {
      for (var member in json['follower']) {
        follower.add(Member.fromJson(member));
      }
    }

    if (BaseModel.hasKey(json, 'following_category') &&
        json['following_category'].isNotEmpty) {
      for (var category in json['following_category']) {
        followingCategory.add(Category.fromNewProductJson(category));
      }
    }

    if (BaseModel.hasKey(json, 'follow_publisher') &&
        json['follow_publisher'].isNotEmpty) {
      for (var publisher in json['follow_publisher']) {
        followingPublisher.add(Publisher.fromJson(publisher));
      }
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
      following: following,
      followingCategory: followingCategory,
      followingPublisher: followingPublisher,
      follower: follower,
    );
  }

  factory Member.followedFollowing(
      Map<String, dynamic> json, String followerId, String followerNickname) {
    return Member(
      memberId: json['id'],
      nickname: json['nickname'],
      followerCount: json['followerCount'] ?? 0,
      follower: [Member(memberId: followerId, nickname: followerNickname)],
    );
  }

  factory Member.otherRecommend(Map<String, dynamic> json) {
    List<Member>? follower;
    if (json['follower'].isNotEmpty) {
      follower = [
        Member(
          memberId: json['follower'][0]['id'],
          nickname: json['follower'][0]['nickname'],
        )
      ];
    }
    return Member(
      memberId: json['id'],
      nickname: json['nickname'],
      followerCount: json['followerCount'] ?? 0,
      pickCount: json['pickCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      follower: follower,
    );
  }
}
