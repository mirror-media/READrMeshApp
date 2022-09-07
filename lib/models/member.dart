import 'package:hive/hive.dart';
import 'package:readr/models/baseModel.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/publisher.dart';

part 'member.g.dart';

@HiveType(typeId: 0)
class Member {
  final String? email;
  final String? firebaseId;

  @HiveField(0)
  final String memberId;

  @HiveField(1)
  String nickname;

  final String? name;

  @HiveField(2)
  String? avatar;

  int? followerCount;
  int? pickCount;
  int? commentCount;
  List<Member>? follower;

  @HiveField(3)
  List<Publisher> followingPublisher;

  @HiveField(4)
  List<Member> following;

  final bool verified;
  String? intro;

  @HiveField(5)
  String customId;

  @HiveField(6)
  String? avatarImageId;

  int? followingCount;
  int? followingPublisherCount;
  int? bookmarkCount;
  bool isFollowing;

  @HiveField(7)
  List<String>? blockMemberIds;
  @HiveField(8)
  List<String>? blockedMemberIds;

  Member({
    this.firebaseId,
    required this.memberId,
    required this.nickname,
    this.email,
    this.name,
    required this.avatar,
    this.followerCount,
    this.pickCount,
    this.commentCount,
    this.follower,
    required this.followingPublisher,
    required this.following,
    this.verified = false,
    this.intro,
    this.followingCount,
    this.followingPublisherCount,
    this.bookmarkCount,
    required this.customId,
    this.isFollowing = false,
    this.avatarImageId,
    this.blockMemberIds,
    this.blockedMemberIds,
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
    String? avatar;
    bool verified = false;
    int? followingCount;
    int? followingPublisherCount;
    int? bookmarkCount;
    String? intro;
    String customId = '';
    bool isFollowing = false;
    String? avatarImageId;
    List<String>? blockMemberIds;
    List<String>? blockedMemberIds;

    if (BaseModel.hasKey(json, 'name')) {
      name = json['name'];
    }

    if (BaseModel.hasKey(json, 'firebaseId')) {
      firebaseId = json['firebaseId'];
    }

    if (BaseModel.hasKey(json, 'email')) {
      email = json['email'];
    }

    if (BaseModel.hasKey(json, 'verified')) {
      verified = json['verified'];
    }

    if (BaseModel.hasKey(json, 'avatar_image')) {
      avatarImageId = json['avatar_image']['id'];
      avatar = json['avatar_image']['resized']?['original'];
    } else if (BaseModel.hasKey(json, 'avatar') && json['avatar'] != "") {
      avatar = json['avatar'];
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

    if (BaseModel.hasKey(json, 'followingCount')) {
      followingCount = json['followingCount'];
    }

    if (BaseModel.hasKey(json, 'follow_publisherCount')) {
      followingPublisherCount = json['follow_publisherCount'];
    }

    if (BaseModel.hasKey(json, 'bookmarkCount')) {
      bookmarkCount = json['bookmarkCount'];
    }

    if (BaseModel.hasKey(json, 'customId')) {
      customId = json['customId'];
    }

    if (BaseModel.hasKey(json, 'intro')) {
      intro = json['intro'];
    }

    if (BaseModel.hasKey(json, 'isFollowing') &&
        json['isFollowing'].isNotEmpty) {
      isFollowing = true;
    }

    if (BaseModel.hasKey(json, 'block') && json['block'].isNotEmpty) {
      blockMemberIds = [];
      for (var item in json['block']) {
        blockMemberIds.add(item['id']);
      }
    }

    if (BaseModel.hasKey(json, 'blocked') && json['blocked'].isNotEmpty) {
      blockedMemberIds = [];
      for (var item in json['blocked']) {
        blockedMemberIds.add(item['id']);
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
      followingPublisher: followingPublisher,
      follower: follower,
      avatar: avatar,
      verified: verified,
      followingCount: followingCount,
      followingPublisherCount: followingPublisherCount,
      bookmarkCount: bookmarkCount,
      customId: customId,
      intro: intro,
      isFollowing: isFollowing,
      avatarImageId: avatarImageId,
      blockMemberIds: blockMemberIds,
      blockedMemberIds: blockedMemberIds,
    );
  }

  factory Member.followedFollowing(Map<String, dynamic> json) {
    String? avatar;
    String customId = '';
    if (BaseModel.hasKey(json, 'avatar_image')) {
      avatar = json['avatar_image']?['resized']?['original'];
    } else if (BaseModel.hasKey(json, 'avatar') && json['avatar'] != "") {
      avatar = json['avatar'];
    }

    if (BaseModel.hasKey(json, 'customId')) {
      customId = json['customId'];
    }
    return Member(
      memberId: json['id'],
      nickname: json['nickname'],
      followerCount: json['followerCount'] ?? 0,
      avatar: avatar,
      customId: customId,
      following: [],
      followingPublisher: [],
      follower: [
        Member(
          memberId: json['follower'][0]['id'],
          nickname: json['follower'][0]['nickname'],
          customId: '',
          avatar: null,
          following: [],
          followingPublisher: [],
        )
      ],
    );
  }

  factory Member.otherRecommend(Map<String, dynamic> json) {
    List<Member>? follower;
    if (json['follower'].isNotEmpty) {
      follower = [
        Member(
          memberId: json['follower'][0]['id'],
          nickname: json['follower'][0]['nickname'],
          customId: json['follower'][0]['customId'],
          avatar: null,
          following: [],
          followingPublisher: [],
        )
      ];
    }
    String? avatar;
    if (BaseModel.hasKey(json, 'avatar_image')) {
      avatar = json['avatar_image']?['resized']?['original'];
    } else if (BaseModel.hasKey(json, 'avatar') && json['avatar'] != "") {
      avatar = json['avatar'];
    }

    String customId = '';
    if (BaseModel.hasKey(json, 'customId')) {
      customId = json['customId'];
    }
    return Member(
      memberId: json['id'],
      nickname: json['nickname'],
      followerCount: json['followerCount'] ?? 0,
      pickCount: json['pickCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      follower: follower,
      customId: customId,
      avatar: avatar,
      following: [],
      followingPublisher: [],
    );
  }
}
