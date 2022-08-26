import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';
import 'package:readr/services/visitorService.dart';

enum FollowableItemType {
  member,
  publisher,
}

abstract class FollowableItem {
  final String id;
  final String name;
  final String descriptionText;
  final bool isFollowed;
  final String lookmoreText;
  final FollowableItemType type;
  final String tag;
  FollowableItem(
    this.id,
    this.name,
    this.descriptionText,
    this.isFollowed,
    this.lookmoreText,
    this.type,
    this.tag,
  );

  void addFollow();
  void removeFollow();
  Future<void> onTap();
  Widget defaultProfilePhotoWidget();
  Widget profilePhotoWidget();
}

class MemberFollowableItem implements FollowableItem {
  final Member member;
  MemberFollowableItem(this.member);

  @override
  String get descriptionText {
    String description = 'defaultDescription'.tr;
    if (member.follower != null && member.follower!.isNotEmpty) {
      String followerName = member.follower![0].nickname;
      if (member.followerCount! == 1) {
        description = '$followerName${'singleFollower'.tr}';
      } else {
        description =
            '$followerName ${'andOther'.tr} ${member.followerCount! - 1} ${'multiFollower'.tr}';
      }
    }
    return description;
  }

  @override
  FollowableItemType get type => FollowableItemType.member;

  @override
  String get id => member.memberId;

  @override
  String get name => member.nickname;

  @override
  bool get isFollowed => Get.find<UserService>().isFollowingMember(member);

  @override
  String get lookmoreText => 'lookmoreMemberText'.tr;

  @override
  String get tag => 'member${member.memberId}';

  @override
  void addFollow() {
    Get.find<UserService>().addFollowingMember(member);
    Get.find<PubsubService>().addFollow(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: member.memberId,
      objective: FollowObjective.member,
    );
  }

  @override
  void removeFollow() {
    Get.find<UserService>().removeFollowingMember(member.memberId);
    Get.find<PubsubService>().removeFollow(
      memberId: Get.find<UserService>().currentUser.memberId,
      targetId: member.memberId,
      objective: FollowObjective.member,
    );
  }

  @override
  Future<void> onTap() async {
    Get.to(() => PersonalFilePage(viewMember: member));
  }

  @override
  Widget profilePhotoWidget() {
    return ProfilePhotoWidget(member, 26);
  }

  @override
  Widget defaultProfilePhotoWidget() {
    return ProfilePhotoWidget(
      member,
      32,
      textSize: 30,
      key: ValueKey(member.hashCode),
    );
  }
}

class PublisherFollowableItem implements FollowableItem {
  final Publisher publisher;
  PublisherFollowableItem(this.publisher);

  @override
  String get descriptionText {
    String description = 'defaultDescription'.tr;
    if (publisher.follower != null && publisher.follower!.isNotEmpty) {
      String followerName = publisher.follower![0].nickname;
      if (publisher.followerCount == 1) {
        description = '$followerName${'singleFollower'.tr}';
      } else {
        description =
            '$followerName ${'andOther'.tr} ${publisher.followerCount - 1} ${'multiFollower'.tr}';
      }
    }
    return description;
  }

  @override
  FollowableItemType get type => FollowableItemType.publisher;

  @override
  String get id => publisher.id;

  @override
  String get name => publisher.title;

  @override
  String get tag => 'publisher${publisher.id}';

  @override
  bool get isFollowed =>
      Get.find<UserService>().isFollowingPublisher(publisher);

  @override
  void addFollow() {
    Get.find<UserService>().addFollowPublisher(publisher);
    if (Get.find<UserService>().isMember.isTrue) {
      Get.find<PubsubService>().addFollow(
        memberId: Get.find<UserService>().currentUser.memberId,
        targetId: publisher.id,
        objective: FollowObjective.publisher,
      );
    } else {
      VisitorService().addFollowPublisher(publisher.id);
    }
  }

  @override
  void removeFollow() {
    Get.find<UserService>().removeFollowingMember(publisher.id);
    if (Get.find<UserService>().isMember.isTrue) {
      Get.find<PubsubService>().removeFollow(
        memberId: Get.find<UserService>().currentUser.memberId,
        targetId: publisher.id,
        objective: FollowObjective.publisher,
      );
    } else {
      VisitorService().removeFollowPublisher(publisher.id);
    }
  }

  @override
  String get lookmoreText => 'lookmorePublisherText'.tr;

  @override
  Future<void> onTap() async {
    Get.to(() => PublisherPage(
          publisher,
        ));
  }

  @override
  Widget profilePhotoWidget() {
    return PublisherLogoWidget(publisher, size: 48);
  }

  @override
  Widget defaultProfilePhotoWidget() {
    return PublisherLogoWidget(
      publisher,
      size: 60,
      key: ValueKey(publisher.hashCode),
    );
  }
}
