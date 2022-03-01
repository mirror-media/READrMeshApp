import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';

abstract class FollowableItem {
  final String id;
  final String name;
  final String descriptionText;
  final bool isFollowed;
  final String lookmoreText;
  FollowableItem(
    this.id,
    this.name,
    this.descriptionText,
    this.isFollowed,
    this.lookmoreText,
  );

  Future<bool> addFollow();
  Future<bool> removeFollow();
  Future<void> onTap(BuildContext context);
  Widget defaultProfilePhotoWidget(BuildContext context);
  Widget profilePhotoWidget(BuildContext context, double size);
  void updateLocalList();
}

class MemberFollowableItem implements FollowableItem {
  final Member member;
  MemberFollowableItem(this.member);

  @override
  String get descriptionText {
    String description = '為你推薦';
    if (member.follower != null && member.follower!.isNotEmpty) {
      String followerName = member.follower![0].nickname;
      if (member.followerCount! == 1) {
        description = '$followerName的追蹤對象';
      } else {
        description = '$followerName 及其他 ${member.followerCount! - 1} 人的追蹤對象';
      }
    }
    return description;
  }

  @override
  String get id => member.memberId;

  @override
  String get name => member.nickname;

  @override
  bool get isFollowed => UserHelper.instance.isLocalFollowingMember(member);

  @override
  String get lookmoreText => '探索更多為你推薦的使用者';

  @override
  Future<bool> addFollow() async =>
      await UserHelper.instance.addFollowingMember(member.memberId);

  @override
  Future<bool> removeFollow() async =>
      await UserHelper.instance.removeFollowingMember(member.memberId);

  @override
  Future<void> onTap(BuildContext context) async {
    AutoRouter.of(context).push(PersonalFileRoute(viewMember: member));
  }

  @override
  Widget profilePhotoWidget(BuildContext context, double radius) {
    return ProfilePhotoWidget(member, radius);
  }

  @override
  Widget defaultProfilePhotoWidget(BuildContext context) {
    return ProfilePhotoWidget(member, 32);
  }

  @override
  void updateLocalList() {
    UserHelper.instance.updateLocalFollowingMember(member);
  }
}

class PublisherFollowableItem implements FollowableItem {
  final Publisher publisher;
  PublisherFollowableItem(this.publisher);

  @override
  String get descriptionText {
    String description = '為你推薦';
    if (publisher.follower != null && publisher.follower!.isNotEmpty) {
      String followerName = publisher.follower![0].nickname;
      if (publisher.followerCount! == 1) {
        description = '$followerName的追蹤對象';
      } else {
        description =
            '$followerName 及其他 ${publisher.followerCount! - 1} 人的追蹤對象';
      }
    }
    return description;
  }

  @override
  String get id => publisher.id;

  @override
  String get name => publisher.title;

  @override
  bool get isFollowed =>
      UserHelper.instance.isLocalFollowingPublisher(publisher);

  @override
  Future<bool> addFollow() async =>
      await UserHelper.instance.addFollowPublisher(publisher.id);

  @override
  Future<bool> removeFollow() async =>
      await UserHelper.instance.removeFollowPublisher(publisher.id);

  @override
  String get lookmoreText => '探索更多為你推薦的媒體';

  @override
  Future<void> onTap(BuildContext context) async {
    AutoRouter.of(context).push(PublisherRoute(
      publisher: publisher,
    ));
  }

  @override
  Widget profilePhotoWidget(BuildContext context, double size) {
    return PublisherLogoWidget(publisher, size: size);
  }

  @override
  Widget defaultProfilePhotoWidget(BuildContext context) {
    return PublisherLogoWidget(publisher, size: 60);
  }

  @override
  void updateLocalList() {
    UserHelper.instance.updateLocalFollowingPublisher(publisher);
  }
}
