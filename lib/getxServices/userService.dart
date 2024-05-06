import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';

class UserService extends GetxService {
  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  bool get _isMember => FirebaseAuth.instance.currentUser != null;

  final isMember = false.obs;

  late Member currentUser;
  bool hasInvitationCode = false;

  Duration get _timeout {
    if (Get.find<EnvironmentService>().flavor == BuildFlavor.development) {
      return const Duration(minutes: 3);
    }
    return const Duration(minutes: 1);
  }

  // for tooltip
  bool showPickTooltip = false;
  bool showCollectionTooltip = false;

  Future<UserService> init() async {
    await fetchUserData(isInit: true);
    isMember.value = _isMember;
    showPickTooltip =
        Get.find<HiveService>().tooltipBox.get('showPickTooltip') ?? true;
    showCollectionTooltip =
        Get.find<HiveService>().tooltipBox.get('showCollectionTooltip') ?? true;
    Timer.periodic(30.minutes, (timer) async => await fetchUserData());
    return this;
  }

  Future<void> fetchUserData({Member? member, bool isInit = false}) async {
    if (member != null) {
      currentUser = member;
    } else if (_isMember) {
      await Future.wait([
        _memberService.fetchMemberData().then((memberData) async {
          if (memberData != null) {
            currentUser = memberData;
          } else {
            await FirebaseAuth.instance.currentUser!.delete();
          }
        }).catchError((error) {
          print('Fetch user data failed: $error');
          currentUser = Get.find<HiveService>().localMember;
        }).timeout(
          _timeout,
          onTimeout: () {
            print('Fetch user data timeout');
            currentUser = Get.find<HiveService>().localMember;
          },
        ),
        if (!isInit) Get.find<PickAndBookmarkService>().fetchPickIds(),
      ]);
    } else {
      currentUser = await _visitorService.fetchMemberData().catchError((error) {
        print('Fetch visitor data failed: $error');
        return Get.find<HiveService>().localMember;
      }).timeout(
        _timeout,
        onTimeout: () {
          print('Fetch user data timeout');
          return Get.find<HiveService>().localMember;
        },
      );
    }
    isMember.value = _isMember;
    Get.find<HiveService>().updateLocalMember(currentUser);
    setUserId(currentUser.memberId);
  }

  bool isFollowingMember(Member member) {
    return currentUser.following
        .any((element) => element.memberId == member.memberId);
  }

  void addFollowingMember(Member member) {
    currentUser.following.addIf(
        !currentUser.following
            .any((element) => element.memberId == member.memberId),
        member);
  }

  void removeFollowingMember(String memberId) {
    currentUser.following
        .removeWhere((element) => element.memberId == memberId);
  }

  bool isFollowingPublisher(Publisher publisher) {
    return currentUser.followingPublisher
        .any((element) => element.id == publisher.id);
  }

  void addFollowPublisher(Publisher publisher) {
    currentUser.followingPublisher.addIf(
        !currentUser.followingPublisher
            .any((element) => element.id == publisher.id),
        publisher);
  }

  void removeFollowPublisher(String publisherId) {
    currentUser.followingPublisher
        .removeWhere((element) => element.id == publisherId);
  }

  Future<void> addVisitorFollowing(List<String> followingPublisherIds) async {
    List<Future> futureList = [];
    for (var publisherId in followingPublisherIds) {
      futureList.add(_memberService.addFollowPublisher(publisherId));
    }
    await Future.wait(futureList);

    await fetchUserData();
  }

  List<String> get followingMemberIds {
    return List<String>.from(currentUser.following.map((e) => e.memberId));
  }

  List<String> get followingPublisherIds {
    return List<String>.from(currentUser.followingPublisher.map((e) => e.id));
  }

  void addBlockMember(String blockMemberId) {
    currentUser.blockMemberIds ??= [];
    currentUser.blockMemberIds!.add(blockMemberId);
  }

  void removeBlockMember(String blockedMemberId) {
    currentUser.blockMemberIds
        ?.removeWhere((element) => element == blockedMemberId);
  }

  bool isBlockMember(String memberId) {
    return currentUser.blockMemberIds?.contains(memberId) ?? false;
  }

  bool isBlocked(String viewMemberId) {
    return currentUser.blockedMemberIds?.contains(viewMemberId) ?? false;
  }

  List<String> get blockAndBlockedIds {
    List<String> blockAndBlockedIds = [];
    if (currentUser.blockMemberIds != null) {
      blockAndBlockedIds.addAll(currentUser.blockMemberIds!);
    }
    if (currentUser.blockedMemberIds != null) {
      blockAndBlockedIds.addAll(currentUser.blockedMemberIds!);
    }
    return blockAndBlockedIds;
  }

  Locale get appLocaleSetting {
    String? languageCode =
        Get.find<SharedPreferencesService>().prefs.getString('languageSetting');
    switch (languageCode) {
      case 'enUS':
        return const Locale('en', 'US');
      case 'zhTW':
        return const Locale('zh', 'TW');
      case 'zhCN':
        return const Locale('zh', 'CN');
      default:
        return Get.deviceLocale ?? const Locale('en', 'US');
    }
  }

  ThemeMode get appearanceSetting {
    String? appearanceCode = Get.find<SharedPreferencesService>()
        .prefs
        .getString('appearanceSetting');
    switch (appearanceCode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
